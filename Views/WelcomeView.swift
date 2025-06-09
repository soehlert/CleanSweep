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
                    Text("Will create 6 default rules for your downloads folder (Music, Images, Documents, Videos, Archives, Code")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    Text("Start with no rules - you can add your own later")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(10)

            Button("Start Organizing Files!") {
                if useDefaultRules {
                    organizer.loadDefaultRules()
                }
                organizer.completeFirstRunSetup()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

