//
//  RecentActivityView.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/8/25.
//


import SwiftUI

struct RecentActivityView: View {
    @ObservedObject var organizer: FileOrganizer

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection

            if organizer.recentMoves.isEmpty {
                emptyStateView
            } else {
                recentMovesListView
            }

            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text("Recent Activity")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                if !organizer.recentMoves.isEmpty {
                    Button("Clear All") {
                        withAnimation(.easeOut(duration: 0.3)) {
                            organizer.clearRecentMoves()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }

            Text("Files that have been automatically organized")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Recent Activity")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text("Files you add to your watched folder will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // Recent Moves List
    private var recentMovesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(organizer.recentMoves) { move in
                    RecentMoveRow(move: move)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// Recent Move Row
struct RecentMoveRow: View {
    let move: FileMove

    var body: some View {
        HStack(spacing: 16) {
            // File Icon
            Image(systemName: fileIcon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 30)

            // File Info
            VStack(alignment: .leading, spacing: 4) {
                Text(move.fileName)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("Moved to \(move.destinationFolder)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(move.displayTime)
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var fileIcon: String {
        let ext = URL(fileURLWithPath: move.fileName).pathExtension.lowercased()

        switch ext {
        case "mp3", "flac", "m4a", "wav", "aac":
            return "music.note"
        case "jpg", "jpeg", "png", "gif", "bmp":
            return "photo"
        case "pdf", "doc", "docx", "txt", "rtf":
            return "doc.text"
        case "mp4", "avi", "mkv", "mov", "wmv":
            return "video"
        case "zip", "rar", "7z", "tar", "gz":
            return "archivebox"
        default:
            return "doc"
        }
    }

    private var iconColor: Color {
        let ext = URL(fileURLWithPath: move.fileName).pathExtension.lowercased()

        switch ext {
        case "mp3", "flac", "m4a", "wav", "aac":
            return .purple
        case "jpg", "jpeg", "png", "gif", "bmp":
            return .blue
        case "pdf", "doc", "docx", "txt", "rtf":
            return .red
        case "mp4", "avi", "mkv", "mov", "wmv":
            return .orange
        case "zip", "rar", "7z", "tar", "gz":
            return .green
        default:
            return .gray
        }
    }
}

#Preview {
    RecentActivityView(organizer: FileOrganizer())
        .frame(width: 600, height: 400)
}
