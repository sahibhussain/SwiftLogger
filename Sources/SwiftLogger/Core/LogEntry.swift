import Foundation

struct LogEntry {
    let message: String
    let level: LogLevel
    let isPublic: Bool
    let properties: [String: Any]?
    let fileName: String
    let line: Int
    let column: Int
    let functionName: String
    let category: String
    let timestamp: Date

    init(
        message: String,
        level: LogLevel,
        isPublic: Bool,
        properties: [String: Any]?,
        fileName: String,
        line: Int,
        column: Int,
        functionName: String,
        category: String
    ) {
        self.message = message
        self.level = level
        self.isPublic = isPublic
        self.properties = properties
        self.fileName = fileName
        self.line = line
        self.column = column
        self.functionName = functionName
        self.category = category
        self.timestamp = Date()
    }
}
