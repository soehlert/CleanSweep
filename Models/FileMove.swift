import Foundation

struct FileMove: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let fromPath: String
    let toPath: String
    let timestamp: Date

    init(fileName: String, fromPath: String, toPath: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.fileName = fileName
        self.fromPath = fromPath
        self.toPath = toPath
        self.timestamp = timestamp
    }

    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: timestamp)
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: timestamp)
    }
    
    var sourceFolder: String {
        return URL(fileURLWithPath: fromPath).lastPathComponent
    }

    var destinationFolder: String {
        return URL(fileURLWithPath: toPath).lastPathComponent
    }
}
