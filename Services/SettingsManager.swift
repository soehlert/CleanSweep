import Foundation

enum SettingsError: Error, LocalizedError {
    case cannotFindAppSupportDirectory
    case cannotCreateDirectory
    case cannotReadFile
    case cannotWriteFile
    case invalidData
    case invalidSettings

    var errorDescription: String? {
        switch self {
        case .cannotFindAppSupportDirectory:
            return "Could not locate Application Support directory"
        case .cannotCreateDirectory:
            return "Could not create settings directory"
        case .cannotReadFile:
            return "Could not read settings file"
        case .cannotWriteFile:
            return "Could not write settings file"
        case .invalidData:
            return "Settings file contains invalid data"
        case .invalidSettings:
            return "Settings validation failed"
        }
    }
}

class SettingsManager {
    private let settingsFileName = "CleanSweepSettings.json"
    private let fileManager = FileManager.default

    // Return an AppSettings object from our settings, nil, or a custom error from above
    func loadSettings() throws -> AppSettings? {
        let settingsURL = try getSettingsURL()

        guard fileManager.fileExists(atPath: settingsURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: settingsURL)
            let settings = try JSONDecoder().decode(AppSettings.self, from: data)
            return settings
        } catch {
            throw SettingsError.invalidData
        }
    }

    private func ensureSettingsDirectory() throws -> URL {
        guard let appSupportPath = fileManager.urls(for: .applicationSupportDirectory,
                                                   in: .userDomainMask).first else {
            throw SettingsError.cannotFindAppSupportDirectory
        }

        let appFolder = appSupportPath.appendingPathComponent("CleanSweep")

        do {
            try fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true)
            return appFolder
        } catch {
            throw SettingsError.cannotCreateDirectory
        }
    }

    private func validateSettings(_ settings: AppSettings) throws {
        // Allow empty rules as part of initial set up
        guard !settings.rules.isEmpty else {
            return
        }

        for rule in settings.rules {
            guard !rule.folderName.isEmpty && !rule.fileExtensions.isEmpty else {
                throw SettingsError.invalidSettings
            }

            for ext in rule.fileExtensions {
                guard ext.hasPrefix(".") && ext.count > 1 else {
                    throw SettingsError.invalidSettings
                }
            }
        }
    }

    func getDefaultRules() -> [OrganizingRule] {
        return [
            OrganizingRule(folderName: "Music",
                           fileExtensions: [".mp3", ".flac", ".m4a", ".wav", ".aac"]),
            OrganizingRule(folderName: "Images",
                           fileExtensions: [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff"]),
            OrganizingRule(folderName: "Documents",
                           fileExtensions: [".pdf", ".doc", ".docx", ".txt", ".rtf", ".pages"]),
            OrganizingRule(folderName: "Videos",
                           fileExtensions: [".mp4", ".avi", ".mkv", ".mov", ".wmv", ".m4v"]),
            OrganizingRule(folderName: "Archives",
                           fileExtensions: [".zip", ".rar", ".7z", ".tar", ".gz", ".dmg"]),
            OrganizingRule(folderName: "Code",
                           fileExtensions: [".swift", ".py", ".js", ".html", ".css", ".json"]),
        ]
    }

    func getSettingsURL() throws -> URL {
        let appFolder = try ensureSettingsDirectory()
        return appFolder.appendingPathComponent(settingsFileName)
    }

    private func createBackup(at settingsURL: URL) throws {
        guard fileManager.fileExists(atPath: settingsURL.path) else { return }

        let backupURL = settingsURL.appendingPathExtension("backup")

        if fileManager.fileExists(atPath: backupURL.path) {
            try fileManager.removeItem(at: backupURL)
        }

        try fileManager.copyItem(at: settingsURL, to: backupURL)
    }
    
    func saveSettings(_ settings: AppSettings) throws {
        print("Starting saveSettings...")

        do {
            try validateSettings(settings)
            print("Validation passed")

            let settingsURL = try getSettingsURL()
            print("Got settings URL: \(settingsURL.path)")

            try createBackup(at: settingsURL)
            print("Backup created")

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(settings)
            print("Encoded successfully")

            try data.write(to: settingsURL)
            print("Saved successfully")
        } catch {
            print("Save failed with error: \(error)")
            throw error
        }
    }
    
    func clearSettings() throws {
        let settingsURL = try getSettingsURL()
        if FileManager.default.fileExists(atPath: settingsURL.path) {
            try FileManager.default.removeItem(at: settingsURL)
        }
    }

}
