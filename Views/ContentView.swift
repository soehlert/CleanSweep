//
//  ContentView.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var organizer = FileOrganizer()
    @State private var selectedTab = 0

    var body: some View {
        if organizer.isFirstRun {
            WelcomeView(organizer: organizer)
        } else {
            HStack(spacing: 0) {
                sidebarSection
                mainContentSection
            }
        }
    }

    // Sidebar Section
    private var sidebarSection: some View {
        VStack(spacing: 20) {
            HeaderView(selectedTab: selectedTab, organizer: organizer)

            Spacer()
        }
        .frame(width: 200)
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(.gray.opacity(0.3))
                .opacity(0.5),
            alignment: .trailing
        )
    }

    // Main Content Section
    private var mainContentSection: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                MonitorView(organizer: organizer)
                    .tabItem {
                        Image(systemName: "eye")
                        Text("Monitor")
                    }
                    .tag(0)

                RulesView(organizer: organizer)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Rules")
                    }
                    .tag(1)
                RecentActivityView(organizer: organizer)
                    .tabItem {
                        Image(systemName: "clock")
                        Text("Recent")
                    }
                    .tag(2)
            }
            .background(.background)
            .ignoresSafeArea(.all, edges: .bottom)

            if let statusMessage = organizer.statusMessage {
                statusMessageOverlay(message: statusMessage)
                    .zIndex(1)
            }
        }
        .clipped()
    }

    // Status Message Section
    private func statusMessageOverlay(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: organizer.isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(organizer.isError ? .red : .green)
                .font(.title3)

            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)

            Spacer()

            Button("×") {
                withAnimation(.easeOut(duration: 0.2)) {
                    organizer.statusMessage = nil
                }
            }
            .foregroundColor(.secondary)
            .buttonStyle(.borderless)
            .font(.title2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke((organizer.isError ? Color.red : Color.green).opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: organizer.statusMessage)
    }
    
}

#Preview {
    ContentView()
        .frame(width: 800, height: 600)
}

