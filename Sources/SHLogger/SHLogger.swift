// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation
import OSLog

public class SHLogger {
    
    // Enum defining our log levels
    public enum Level: Int {
        case info
        case debug
        case warning
        case error
        
        public var description: String {
            switch self {
            case .debug: return "Debug"
            case .info: return "Info"
            case .warning: return "Warning"
            case .error: return "Error"
            }
        }

        public static let all: [Level] = [.debug, .info, .warning, .error]

        func atLeast(_ level: Level) -> Bool {
            return level.rawValue >= rawValue
        }
        
    }
    
    private static let kLogDirectoryName = "Logs"
    
    // MARK: - Singleton Instance
    static let shared = SHLogger()
    private init() {}
    
    private var profile = Profile.shared
    private var internalLogger = Logger(subsystem: "", category: "SHLogger")
    
    // Log a message if the logger's log level is equal to or lower than the specified level.
    func log(_ message: String, properties: [String: Any]? = nil, level: Level = .info, fileName: String = #file, line: Int = #line, column: Int = #column, functionName: String = #function, loggerCategory: String = "Default") {
        
        var appendContents = formattedMessage(message, properties: properties, level: level, fileName: fileName, line: line, column: column, functionName: functionName)
        
        let bundleID = Bundle.main.bundleIdentifier ?? "Your App"
        let logger = Logger(subsystem: bundleID, category: loggerCategory)
        switch level {
        case .info:
            logger.info("\(appendContents)")
        case .debug:
            logger.debug("\(appendContents)")
        case .warning:
            logger.warning("\(appendContents)")
        case .error:
            logger.error("\(appendContents)")
        }
        
        if level != .info {
            let logFile = logFilePath()
            if !FileManager.default.fileExists(atPath: logFile) {
                appendContents = headerContent() + appendContents
                internalLogger.info("Log file created")
            } else {
                appendContents = logPrint() + appendContents
            }

            appendContents += "\n\n"

            do {
                try appendContents.write(toFile: logFile, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                internalLogger.error("Unable to write : \(error.debugDescription)")
            }
        }
        
    }
    
    func formattedMessage(_ message: String, properties: [String: Any]?, level: Level, fileName: String, line: Int, column _: Int, functionName: String) -> String {
        var appendContents = String()
        appendContents += "\(Date().toString())"
        appendContents += " [\(level.description)]"
        appendContents += " [\(sourceFileName(filePath: fileName))]"
        appendContents += " [\(line)]"
        
        let name = __dispatch_queue_get_label(nil)
        let queuename = String(cString: name, encoding: .utf8)
        appendContents += " [\(String(describing: queuename))]"

        appendContents += " \(functionName)"
        appendContents += " -> \(message)"

        if let properties = properties {
            appendContents += "\nPROPERTIES ¬ \n"

            for (key, _) in properties {
                assert(properties[key] != nil, "Event property cannot be null")
                appendContents += "\(key): \"\(String(describing: properties[key]))\"\n"
            }
        }

        return appendContents
    }
    
    
    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    private func logDirectoryPath() -> URL {
        let url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(SHLogger.kLogDirectoryName)

        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: false, attributes: nil)
                internalLogger.info("Log directory created")
            } catch let error as NSError {
                internalLogger.info("Unable to create directory : \(error.debugDescription)")
            }
        }

        return url
    }
    
    private func todayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return "\(formatter.string(from: Date()))"
    }
    
    private func headerContent() -> String {
        
        var content = "Log Created: \(todayDate())\n"
        content += "App Name: \(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleName")))\n"
        content += "App Version \(Bundle.main.releaseVersionNumber) [\(Bundle.main.buildVersionNumber)]"
        content += "App Bundle Identifier: \(Bundle.main.bundleIdentifier ?? "Not available")\n"
        content += "OS: \(Device.os) (\(Device.osVersion))\n"
        content += "Device: \(Device.modelName)\n"
        content += "------------------ User Detail Start ----------------------------------\n"
        content += "ID: \(profile.userID)\n"
        content += "Name: \(profile.name)\n"
        content += "Phone: \(profile.phone)\n"
        content += "Extra: \(profile.extraInfo)\n"
        content += "------------------ User Detail End ----------------------------------\n\n"
        
        return content
        
    }
    
    private func logData() -> Data? {
        return FileManager.default.contents(atPath: logFilePath())
    }
    
    
    public func logFilePath() -> String {
        return "\(logDirectoryPath().appendingPathComponent(todayDate()).path).txt"
    }
    
    public func logPrint() -> String {
        var content: String?
        let path = logFilePath()

        if FileManager.default.fileExists(atPath: path) {
            do {
                content = try? String(contentsOfFile: path, encoding: .utf8)
            }
        }

        return content ?? ""
    }
    
    public func deleteLogDir() {
        try? FileManager.default.removeItem(at: logDirectoryPath())
    }
    
}

public extension SHLogger {
    
    func info(_ message: String, properties: [String: Any]? = nil, fileName: String = #file, line: Int = #line, column: Int = #column, functionName: String = #function, loggerCategory: String = "Default") {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.log(message, properties: properties, level: .info, fileName: fileName, line: line, column: column, functionName: functionName, loggerCategory: loggerCategory)
        }
    }
    
    func debug(_ message: String, properties: [String: Any]? = nil, fileName: String = #file, line: Int = #line, column: Int = #column, functionName: String = #function, loggerCategory: String = "Default") {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.log(message, properties: properties, level: .debug, fileName: fileName, line: line, column: column, functionName: functionName, loggerCategory: loggerCategory)
        }
    }

    func warning(_ message: String, properties: [String: Any]? = nil, fileName: String = #file, line: Int = #line, column: Int = #column, functionName: String = #function, loggerCategory: String = "Default") {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.log(message, properties: properties, level: .warning, fileName: fileName, line: line, column: column, functionName: functionName, loggerCategory: loggerCategory)
        }
    }

    func error(_ message: String, properties: [String: Any]? = nil, fileName: String = #file, line: Int = #line, column: Int = #column, functionName: String = #function, loggerCategory: String = "Default") {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.log(message, properties: properties, level: .error, fileName: fileName, line: line, column: column, functionName: functionName, loggerCategory: loggerCategory)
        }
    }
    
}
