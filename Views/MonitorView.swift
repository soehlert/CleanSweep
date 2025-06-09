//
//  MonitorView.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/7/25.
//

import SwiftUI
import AppKit

struct MonitorView: View {
    @ObservedObject var organizer: FileOrganizer

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            watchedFolderSection
            monitoringSection

            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "eye.circle")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text("File Monitoring")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()
            }

            Text("Configure and control automatic file organization")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // Watched Folder Section
    private var watchedFolderSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Currently watching:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(organizer.watchedFolder.path)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }

                Spacer()

                Button("Change Folder") {
                    openFolderPicker()
                }
                .buttonStyle(.bordered)
            }
            .padding(20)
            .background(.regularMaterial)
            .cornerRadius(12)
        }
    }

    // Monitoring Section
    private var monitoringSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Circle()
                    .fill(organizer.isMonitoring ? .green : .gray)
                    .frame(width: 16, height: 16)
                    .animation(.easeInOut(duration: 0.3), value: organizer.isMonitoring)

                Text(organizer.isMonitoring ? "Monitoring Active" : "Monitoring Stopped")
                    .font(.title2)
                    .fontWeight(.medium)

                Spacer()
            }
            Text(organizer.isMonitoring ?
                 "CleanSweep is watching for new files and will organize them automatically." :
                 "Click Start to begin monitoring your watched folder for new files.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: toggleMonitoring) {
                HStack(spacing: 10) {
                    Image(systemName: organizer.isMonitoring ? "stop.fill" : "play.fill")
                        .font(.title3)

                    Text(organizer.isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(organizer.isMonitoring ? .red : .green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: organizer.isMonitoring)
        }
        .padding(20)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.title = "Choose Folder to Monitor"
        panel.prompt = "Select"

        if panel.runModal() == .OK {
            if let selectedURL = panel.url {
                organizer.setWatchedFolder(to: selectedURL)
            }
        }
    }
    private func toggleMonitoring() {
        if organizer.isMonitoring {
            organizer.stopMonitoring()
        } else {
            organizer.startMonitoring()
        }
    }
}

#Preview {
    MonitorView(organizer: FileOrganizer())
}
