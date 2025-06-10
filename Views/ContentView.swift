//
//  ContentView.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/6/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var organizer: FileOrganizer
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if organizer.isFirstRun {
                WelcomeView(organizer: organizer)
            } else {
                HStack(spacing: 0) {
                    sidebarSection
                    mainContentSection
                }
            }
        }
        .statusMessage(organizer: organizer)  // ADD THIS LINE
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            if let window = notification.object as? NSWindow {
                window.orderOut(nil)
                NSApp.setActivationPolicy(.accessory)
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

    // Main Content Section - REMOVE THE ZSTACK AND STATUS MESSAGE OVERLAY
    private var mainContentSection: some View {
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
    }

    // REMOVE THIS ENTIRE FUNCTION - it will be in the StatusMessageModifier instead
    // private func statusMessageOverlay(message: String) -> some View { ... }
}

#Preview {
    ContentView()
        .frame(width: 800, height: 600)
        .environmentObject(FileOrganizer())
}

