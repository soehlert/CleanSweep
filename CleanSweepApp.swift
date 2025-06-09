//
//  CleanSweepApp.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/6/25.
//

import SwiftUI

@main
struct CleanSweepApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1000, height: 600)
        .windowResizability(.contentMinSize)
    }
}

#Preview {
    ContentView()
}
