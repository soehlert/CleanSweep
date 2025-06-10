import SwiftUI

struct HeaderView: View {
    let selectedTab: Int
    @ObservedObject var organizer: FileOrganizer

    private enum Layout {
        static let iconSize: CGFloat = 100
        static let dividerHeight: CGFloat = 1
        static let dividerOpacity: Double = 0.4
        static let spacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 8
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            appHeader
            divider
            contextualInfo
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                Button("Clear All Settings") {
                    organizer.clearAllSettings()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var appHeader: some View {
        VStack(spacing: 4) {
            Image("cleansweep")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Layout.iconSize * 1.2, height: Layout.iconSize * 1.2)
                .padding(.bottom, 2)
                .foregroundStyle(.blue)

            Text("CleanSweep")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Automatic file organization")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(.gray.opacity(Layout.dividerOpacity))
            .frame(height: Layout.dividerHeight)
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.top, 25)
            .padding(.bottom, 2)
    }

    private var contextualInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            let info = getTabInfo()

            if !info.title.isEmpty {
                Text(info.title)
                    .font(.title3)
                    .foregroundColor(.primary)

                if let dynamicInfo = info.dynamicInfo {
                    Text(dynamicInfo)
                        .font(.callout)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }

                Text(info.subtitle)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Layout.horizontalPadding)
    }

    private func getTabInfo() -> (title: String, subtitle: String, dynamicInfo: String?) {
        switch selectedTab {
        case 0:
            return (
                title: "File Monitoring",
                subtitle: "Configure rules in the Rules tab to customize file organization",
                dynamicInfo: nil
            )
        case 1:
            return (
                title: "Organizing Rules",
                subtitle: "The bold word of the rule represents the folder name to house those file extensions",
                dynamicInfo: "\(organizer.rules.count) rules configured"
            )
        case 2:
            return (
                title: "Recent Activity",
                subtitle: "View recently organized files",
                dynamicInfo: nil
            )
        default:
            return (title: "", subtitle: "", dynamicInfo: nil)
        }
    }
}

#Preview {
    HeaderView(selectedTab: 0, organizer: FileOrganizer())
        .frame(width: 250)
}

