import SwiftUI

struct AddRuleView: View {
    @ObservedObject var organizer: FileOrganizer
    @Environment(\.dismiss) private var dismiss

    @State private var folderName = ""
    @State private var fileExtensions = ""
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Organization Rule")
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
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
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

        // Check if folder already exists
        if organizer.rules.contains(where: { $0.folderName == trimmedFolder }) {
            showError("A rule for '\(trimmedFolder)' already exists")
            return
        }

        // Create and add the rule using the correct method signature
        let newRule = OrganizingRule(folderName: trimmedFolder, fileExtensions: extensions)
        organizer.addRule(newRule)
        dismiss()
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    AddRuleView(organizer: FileOrganizer())
}

