//
//  FileOrganizer.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/8/25.
//

import Foundation
import Combine

// Convenience functions to make life a little easier
extension SettingsManager {
    // Use the downloads directory by default
    private func getDefaultWatchedFolderPath() -> String {
        return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? NSHomeDirectory() + "/Downloads"
    }

    func saveSettingsSafely(_ settings: AppSettings) -> Bool {
        do {
            try saveSettings(settings)
            return true
        } catch {
            return false
        }
    }
}

class FileOrganizer: ObservableObject {
    @Published var statusMessage: String?
    @Published var isError: Bool = false
    @Published var isMonitoring = false
    @Published var recentMoves: [FileMove] = []
    @Published var rules: [OrganizingRule] = []
    @Published var watchedFolder: URL
    @Published var isFirstRun = true

    private let fileManager = FileManager.default
    private let maxRecentMoves = 10
    private let settingsManager = SettingsManager()
    private var fileSystemWatcher: DispatchSourceFileSystemObject?
    private var watchedFolderDescriptor: Int32 = -1

    // Single background queue for all file operations
    private let backgroundQueue = DispatchQueue(label: "com.cleansweep.fileorganizer", qos: .background)

    init() {
        self.watchedFolder = FileManager.default.urls(for: .downloadsDirectory,
                                                      in: .userDomainMask).first!

        loadSettings()

        if !isFirstRun {
            print("Starting monitoring because !isFirstRun is true")
            scanNow()
            startMonitoring()
        } else {
            print("NOT starting monitoring because isFirstRun is true")
        }
    }


    func completeFirstRunSetup() {
        isFirstRun = false
        saveSettings()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scanNow()
            self.startMonitoring()
        }
    }

    // Status Messages
    func showStatus(_ message: String, isError: Bool = false) {
        DispatchQueue.main.async {
            self.statusMessage = message
            self.isError = isError

            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if self.statusMessage == message {
                    self.statusMessage = nil
                }
            }
        }
    }

    private func loadSettings() {
        // Check if settings file exists first
        do {
            let settingsResult = try settingsManager.loadSettings()
            if let existingSettings = settingsResult {
                print("Found existing settings: isFirstRun = \(existingSettings.isFirstRun)")
                self.rules = existingSettings.rules
                self.watchedFolder = URL(fileURLWithPath: existingSettings.watchedFolderPath)
                self.isFirstRun = existingSettings.isFirstRun
                showStatus("Settings loaded")
            } else {
                print("No existing settings found, setting isFirstRun = true")
                self.rules = []
                self.isFirstRun = true
            }
        } catch {
            print("Error loading settings: \(error), setting isFirstRun = true")
            self.rules = []
            self.isFirstRun = true
        }
    }

    func saveSettings() {
        let settings = AppSettings(rules: rules, watchedFolderPath: watchedFolder.path, isFirstRun: isFirstRun)

        if settingsManager.saveSettingsSafely(settings) {
            showStatus("Settings saved successfully")
        } else {
            showStatus("Failed to save settings", isError: true)
        }
    }

    func setWatchedFolder(to folderURL: URL) {
        watchedFolder = folderURL
        saveSettings()
        showStatus("Changed watched folder to: \(watchedFolder.path)")
    }

    func clearAllSettings() {
        stopMonitoring()

        // Clear in-memory data
        rules.removeAll()
        isFirstRun = true

        // Delete the settings file
        do {
            try settingsManager.clearSettings()
            showStatus("Settings cleared! Restart app to see welcome screen.")
        } catch {
            showStatus("Failed to clear settings", isError: true)
        }
    }

    // Rule Management
    func addRule(_ rule: OrganizingRule) {
        rules.append(rule)
        saveSettings()
        showStatus("Rule added")
        scanNow()
    }

    func removeRule(at index: Int) {
        rules.remove(at: index)
        saveSettings()
        showStatus("Rule removed")
    }

    func loadDefaultRules() {
        rules = settingsManager.getDefaultRules()
        saveSettings()
        showStatus("Default rules loaded")
    }

    // Recent moves
    func addRecentMove(_ move: FileMove) {
        DispatchQueue.main.async {
            self.recentMoves.insert(move, at: 0)
            if self.recentMoves.count > self.maxRecentMoves {
                self.recentMoves.removeLast()
            }
        }
    }

    func clearRecentMoves() {
        recentMoves.removeAll()
    }

    // Monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }

        stopMonitoring()

        // Deal with files already in place
        scanFiles()

        watchedFolderDescriptor = open(watchedFolder.path, O_EVTONLY)

        guard watchedFolderDescriptor >= 0 else {
            showStatus("Failed to open directory for monitoring", isError: true)
            return
        }

        // Create event listener using our single background queue
        fileSystemWatcher = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: watchedFolderDescriptor,
            eventMask: .write,
            queue: backgroundQueue
        )

        fileSystemWatcher?.setEventHandler { [weak self] in
            // Add a small delay so we dont try to move a half finished file
            self?.backgroundQueue.asyncAfter(deadline: .now() + 0.5) {
                self?.scanFiles()
            }
        }

        fileSystemWatcher?.setCancelHandler { [weak self] in
            if let descriptor = self?.watchedFolderDescriptor, descriptor >= 0 {
                close(descriptor)
                self?.watchedFolderDescriptor = -1
            }
        }

        // Start monitoring
        fileSystemWatcher?.resume()

        DispatchQueue.main.async {
            self.isMonitoring = true
            self.showStatus("Monitoring started")
        }
    }

    func stopMonitoring() {
        fileSystemWatcher?.cancel()
        fileSystemWatcher = nil

        if watchedFolderDescriptor >= 0 {
            close(watchedFolderDescriptor)
            watchedFolderDescriptor = -1
        }

        DispatchQueue.main.async {
            self.isMonitoring = false
            self.showStatus("Monitoring stopped")
        }
    }

    func scanNow() {
        backgroundQueue.async {
            self.scanFiles()
        }
    }

    private func scanFiles() {
        do {
            let contents = try fileManager.contentsOfDirectory(at: watchedFolder, includingPropertiesForKeys: nil)
            let files = contents.filter { !$0.hasDirectoryPath && !$0.lastPathComponent.hasPrefix(".") }

            for fileURL in files {
                organizeFile(at: fileURL)
            }

        } catch {
            showStatus("Error scanning directory: \(error)", isError: true)
        }
    }

    // File Organization
    private func organizeFile(at fileURL: URL) {
        let fileExtension = fileURL.pathExtension.lowercased()
        let fileName = fileURL.lastPathComponent

        guard let matchingRule = rules.first(where: { $0.matches(fileExtension: ".\(fileExtension)") }) else {
            return
        }

        let watchedFolderName = watchedFolder.lastPathComponent
        let destinationFolder = watchedFolder.appendingPathComponent(matchingRule.folderName)

        do {
            try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
            let destinationURL = destinationFolder.appendingPathComponent(fileName)
            let finalDestination = getUniqueDestination(destinationURL)

            try fileManager.moveItem(at: fileURL, to: finalDestination)
            showStatus("Moved file: \(fileName) to \(watchedFolderName)/\(matchingRule.folderName)")

            let move = FileMove(fileName: fileName, fromPath: watchedFolder.path, toPath: finalDestination.path)
            addRecentMove(move)

        } catch {
            showStatus("Error moving \(fileName): \(error)", isError: true)
        }
    }

    private func getUniqueDestination(_ originalURL: URL) -> URL {
        var counter = 1
        var destinationURL = originalURL

        while fileManager.fileExists(atPath: destinationURL.path) {
            let nameWithoutExtension = originalURL.deletingPathExtension().lastPathComponent
            let fileExtension = originalURL.pathExtension
            let newName = "\(nameWithoutExtension)_\(counter).\(fileExtension)"
            destinationURL = originalURL.deletingLastPathComponent().appendingPathComponent(newName)
            counter += 1
        }

        return destinationURL
    }
}

