//
//  AppSettings.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/8/25.
//


import Foundation

struct AppSettings: Codable {
    var rules: [OrganizingRule]
    var watchedFolderPath: String
    var lastSaved: Date
    var isFirstRun: Bool

    init(rules: [OrganizingRule], watchedFolderPath: String, isFirstRun: Bool = true) {
        self.rules = rules
        self.watchedFolderPath = watchedFolderPath
        self.lastSaved = Date()
        self.isFirstRun = isFirstRun
    }
}
