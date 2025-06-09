//
//  LaunchAgentManager.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/8/25.
//


import Foundation

class LaunchAgentManager {
    private static let launchAgentURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/LaunchAgents/com.cleansweep.fileorganizer.plist")

    static func enable() {
        let bundlePath = Bundle.main.bundlePath

        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.cleansweep.fileorganizer</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(bundlePath)/Contents/MacOS/CleanSweep</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <false/>
        </dict>
        </plist>
        """

        try? plistContent.write(to: launchAgentURL, atomically: true, encoding: .utf8)

        // Load the launch agent
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["load", launchAgentURL.path]
        task.launch()
    }

    static func disable() {
        // Unload the launch agent
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["unload", launchAgentURL.path]
        task.launch()
        task.waitUntilExit()

        // Remove the plist file
        try? FileManager.default.removeItem(at: launchAgentURL)
    }

    static func isEnabled() -> Bool {
        return FileManager.default.fileExists(atPath: launchAgentURL.path)
    }
}
