//
//  EditRuleView.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/10/25.
//


import SwiftUI

struct EditRuleView: View {
    @ObservedObject var organizer: FileOrganizer
    @Environment(\.dismiss) private var dismiss

    let ruleIndex: Int

    @State private var folderName = ""
    @State private var fileExtensions = ""
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit Organizing Rule")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Folder Name")
                    .font(.headline)

                TextField("e.g., Music, Documents, Images", text: $folderName)
                    .textFieldStyle(.roundedBorder)

                Text("Files will be moved to \(organizer.watchedFolder.path)/\(folderName.isEmpty ? "FolderName" : folderName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("File Extensions")
                    .font(.headline)

                TextField("e.g., .mp3, .flac, .wav", text: $fileExtensions)
                    .textFieldStyle(.roundedBorder)

                Text("Separate multiple extensions with commas")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    saveRule()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(folderName.isEmpty || fileExtensions.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
        .onAppear {
            loadExistingRule()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func loadExistingRule() {
        guard ruleIndex < organizer.rules.count else { return }
        let rule = organizer.rules[ruleIndex]
        folderName = rule.folderName
        fileExtensions = rule.fileExtensions.joined(separator: ", ")
    }

    private func parseExtensions(_ input: String) -> [String] {
        return input
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { ext in
                ext.hasPrefix(".") ? ext : ".\(ext)"
            }
            .filter { !$0.isEmpty && $0 != "." }
    }

    private func saveRule() {
        let trimmedFolder = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExtensions = fileExtensions.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedFolder.isEmpty else {
            showError("Please enter a folder name")
            return
        }

        guard !trimmedExtensions.isEmpty else {
            showError("Please enter at least one file extension")
            return
        }

        let extensions = parseExtensions(trimmedExtensions)

        guard !extensions.isEmpty else {
            showError("Please enter valid file extensions")
            return
        }

        // Check if folder name conflicts with existing rules (excluding current rule)
        let existingRule = organizer.rules.enumerated().first { index, rule in
            index != ruleIndex && rule.folderName == trimmedFolder
        }

        if existingRule != nil {
            showError("A rule for '\(trimmedFolder)' already exists")
            return
        }

        // Update the rule
        let updatedRule = OrganizingRule(folderName: trimmedFolder, fileExtensions: extensions)
        organizer.updateRule(at: ruleIndex, with: updatedRule)
        dismiss()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
