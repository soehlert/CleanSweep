import SwiftUI

struct WelcomeView: View {
    @ObservedObject var organizer: FileOrganizer
    @State private var useDefaultRules = true

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to CleanSweep!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Let's set up your file organization")
                .font(.title2)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Watched Folder:")
                    Text(organizer.watchedFolder.path)
                        .foregroundColor(.secondary)
                }

                Toggle("Use default organization rules", isOn: $useDefaultRules)

                if useDefaultRules {
                    Text("This will create 6 default rules for your downloads folder (Music, Images, Documents, Videos, Archives, Code)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(minWidth: 400, idealWidth: 450, maxWidth: 500, alignment: .leading)
                } else {
                    Text("Start with no rules - you can add your own later")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(minWidth: 450, idealWidth: 475, maxWidth: 500, alignment: .leading)
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(10)

            Button("Start Organizing Files") {
                if useDefaultRules {
                    organizer.loadDefaultRules()
                    // Only start monitoring if they chose default rules
                    organizer.completeFirstRunSetup()
                    organizer.showStatus("Starting monitoring")
                    // Switch to background mode after setup
                    NSApp.setActivationPolicy(.accessory)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        // Close the settings window
                        if let window = NSApp.windows.first(where: { $0.title == "CleanSweep Settings" }) {
                            window.orderOut(nil)
                            NSApp.setActivationPolicy(.accessory)
                        }
                    }
                } else {
                    organizer.isFirstRun = false
                    organizer.saveSettings()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

