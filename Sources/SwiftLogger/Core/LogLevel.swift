import Foundation

public enum LogLevel: Int, Comparable {
    case info    = 0
    case debug   = 1
    case warning = 2
    case error   = 3

    public var description: String {
        switch self {
        case .info:    return "Info"
        case .debug:   return "Debug"
        case .warning: return "Warning"
        case .error:   return "Error"
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
