import SwiftUI

@main
struct CleanSweepApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("CleanSweep Settings", id: "settings") {
            ContentView()
                .environmentObject(appDelegate.organizer)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1000, height: 600)
        .defaultPosition(.center)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    static var shared: AppDelegate!
    let organizer = FileOrganizer()
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        // Delay the status bar setup slightly
        DispatchQueue.main.async {
            self.setupStatusBar()
            self.showInitialWindow()
        }
        
    }
    private func showInitialWindow() {
        // Always show settings window on startup
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // Give SwiftUI a moment to create the window
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for window in NSApp.windows {
                if window.title == "CleanSweep Settings" {
                    self.settingsWindow = window
                    window.delegate = self
                    window.makeKeyAndOrderFront(nil)
                    print("Settings window shown on startup")
                    return
                }
            }

            // If window not found, try once more
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for window in NSApp.windows {
                    if window.title == "CleanSweep Settings" {
                        self.settingsWindow = window
                        window.delegate = self
                        window.makeKeyAndOrderFront(nil)
                        break
                    }
                }
            }
        }
    }

    private func setupStatusBar() {
        print("Setting up status bar")

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else {
            print("ERROR: No button found")
            return
        }

        button.image = NSImage(systemSymbolName: "folder.badge.gearshape", accessibilityDescription: "CleanSweep")
        print("Button image set: \(button.image != nil)")

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Settings", action: #selector(showSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit CleanSweep", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
        print("Menu assigned")
    }

    @objc private func showSettings() {
        print("showSettings called")

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
        }
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Prevent closing, just hide instead
        sender.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
        return false
    }
}

