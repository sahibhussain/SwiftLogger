import Foundation
import OSLog

public final class SwiftLogger {

    public static let shared = SwiftLogger()
    private init() {}

    public var logLevel: LogLevel = .info

    /// Set to a positive integer to automatically purge log files older than that many days.
    /// Cleanup runs once per calendar day, on the first log write of that day.
    /// Set to `nil` to disable auto-clearing.
    public var retentionDays: Int? = nil

    private let formatter = LogFormatter()
    private let fileManager = LogFileManager()
    private let profile = UserProfile.shared

    // Serial queue ensures file reads/writes are never concurrent.
    private let logQueue = DispatchQueue(label: "com.swiftlogger.logging", qos: .utility)

    // Tracks the last date auto-clean ran; accessed only from logQueue.
    private var lastAutoCleanDate: String?

    // MARK: - Public Configuration

    public func setProfile(
        userID: String = "",
        name: String = "",
        phone: String = "",
        extra: [String: String] = [:]
    ) {
        profile.configure(userID: userID, name: name, phone: phone, extra: extra)
    }

    // MARK: - Public File Access

    public func logFilePath(category: String = "Default") -> String? {
        fileManager.filePath(category: category)
    }

    public func logPrint(category: String = "Default", date: Date = Date()) -> String {
        fileManager.read(category: category, date: date)
    }

    // MARK: - Log Clearing

    /// Remove today's log file for a specific category.
    public func clearLogs(category: String, date: Date = Date()) {
        fileManager.clear(category: category, date: date)
    }

    /// Remove all log files for a specific category.
    public func clearLogs(category: String) {
        fileManager.clear(category: category)
    }

    /// Remove log files older than `days` days across all categories.
    public func clearOldLogs(olderThan days: Int) {
        fileManager.clearOldLogs(olderThan: days)
    }

    /// Remove the entire Logs directory.
    public func deleteLogDir() { fileManager.deleteAll() }

    // MARK: - Internal Routing

    // Called from logQueue — safe to mutate lastAutoCleanDate here.
    private func autoCleanIfNeeded() {
        guard let days = retentionDays else { return }
        let today = Date().toDateString()
        guard lastAutoCleanDate != today else { return }
        lastAutoCleanDate = today
        fileManager.clearOldLogs(olderThan: days)
    }

    private func route(_ entry: LogEntry) {
        autoCleanIfNeeded()
        let formatted = formatter.format(entry)
        let bundleID = Bundle.main.bundleIdentifier ?? "app"
        let logger = Logger(subsystem: bundleID, category: entry.category)

        switch (entry.level, entry.isPublic) {
        case (.info, true):     logger.info("\(formatted, privacy: .public)")
        case (.info, false):    logger.info("\(formatted, privacy: .private)")
        case (.debug, true):    logger.debug("\(formatted, privacy: .public)")
        case (.debug, false):   logger.debug("\(formatted, privacy: .private)")
        case (.warning, true):  logger.warning("\(formatted, privacy: .public)")
        case (.warning, false): logger.warning("\(formatted, privacy: .private)")
        case (.error, true):    logger.critical("\(formatted, privacy: .public)")
        case (.error, false):   logger.critical("\(formatted, privacy: .private)")
        }

        guard entry.level != .info else { return }
        fileManager.append(formatted, category: entry.category, header: headerContent())
    }

    private func headerContent() -> String {
        var content = "Log Created: \(Date().toDateString())\n"
        content += "App Name: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "Unknown")\n"
        content += "App Version: \(Bundle.main.releaseVersionNumber) [\(Bundle.main.buildVersionNumber)]\n"
        content += "App Bundle Identifier: \(Bundle.main.bundleIdentifier ?? "Not available")\n"
        content += "OS: \(DeviceInfo.osName) (\(DeviceInfo.osVersion))\n"
        content += "Device: \(DeviceInfo.modelName)\n"
        content += "------------------ User Detail Start ----------------------------------\n"
        content += "ID: \(profile.userID)\n"
        content += "Name: \(profile.name)\n"
        content += "Phone: \(profile.phone)\n"
        content += "Extra: \(profile.extraInfo)\n"
        content += "------------------ User Detail End ------------------------------------\n\n"
        return content
    }
}

// MARK: - Public Logging API

public extension SwiftLogger {

    func info(
        _ message: String,
        isPublic: Bool = true,
        properties: [String: Any]? = nil,
        fileName: String = #file,
        line: Int = #line,
        column: Int = #column,
        functionName: String = #function,
        category: String = "Default"
    ) {
        guard logLevel <= .info else { return }
        let entry = LogEntry(
            message: message, level: .info, isPublic: isPublic,
            properties: properties, fileName: fileName, line: line,
            column: column, functionName: functionName, category: category
        )
        logQueue.async { [weak self] in self?.route(entry) }
    }

    func debug(
        _ message: String,
        isPublic: Bool = true,
        properties: [String: Any]? = nil,
        fileName: String = #file,
        line: Int = #line,
        column: Int = #column,
        functionName: String = #function,
        category: String = "Default"
    ) {
        guard logLevel <= .debug else { return }
        let entry = LogEntry(
            message: message, level: .debug, isPublic: isPublic,
            properties: properties, fileName: fileName, line: line,
            column: column, functionName: functionName, category: category
        )
        logQueue.async { [weak self] in self?.route(entry) }
    }

    func warning(
        _ message: String,
        isPublic: Bool = true,
        properties: [String: Any]? = nil,
        fileName: String = #file,
        line: Int = #line,
        column: Int = #column,
        functionName: String = #function,
        category: String = "Default"
    ) {
        guard logLevel <= .warning else { return }
        let entry = LogEntry(
            message: message, level: .warning, isPublic: isPublic,
            properties: properties, fileName: fileName, line: line,
            column: column, functionName: functionName, category: category
        )
        logQueue.async { [weak self] in self?.route(entry) }
    }

    func error(
        _ message: String,
        isPublic: Bool = true,
        properties: [String: Any]? = nil,
        fileName: String = #file,
        line: Int = #line,
        column: Int = #column,
        functionName: String = #function,
        category: String = "Default"
    ) {
        guard logLevel <= .error else { return }
        let entry = LogEntry(
            message: message, level: .error, isPublic: isPublic,
            properties: properties, fileName: fileName, line: line,
            column: column, functionName: functionName, category: category
        )
        logQueue.async { [weak self] in self?.route(entry) }
    }
}
