import Foundation

internal extension Bundle {

    var releaseVersionNumber: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    var buildVersionNumber: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
}
