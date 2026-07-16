import Foundation

internal extension Date {

    private static let timestampFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
        f.locale = Locale.current
        f.timeZone = TimeZone.current
        return f
    }()

    static let logDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale.current
        f.timeZone = TimeZone.current
        return f
    }()

    func toString() -> String {
        Date.timestampFormatter.string(from: self)
    }

    func toDateString() -> String {
        Date.logDateFormatter.string(from: self)
    }
}
