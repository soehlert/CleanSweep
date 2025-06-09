//
//  OrganizingRule.swift
//  CleanSweep
//
//  Created by Sam Oehlert on 6/8/25.
//


import Foundation

struct OrganizingRule: Identifiable, Codable {
    let id: UUID
    var folderName: String
    var fileExtensions: [String]
    var isEnabled: Bool

    init(folderName: String, fileExtensions: [String], isEnabled: Bool = true) {
        self.id = UUID()
        self.folderName = folderName
        self.fileExtensions = fileExtensions
        self.isEnabled = isEnabled
    }

    func matches(fileExtension: String) -> Bool {
        return isEnabled && fileExtensions.contains(fileExtension.lowercased())
    }
}
