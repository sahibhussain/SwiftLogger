import Foundation

final class UserProfile: @unchecked Sendable {

    static let shared = UserProfile()
    private init() {}

    private(set) var userID: String = ""
    private(set) var name: String = ""
    private(set) var phone: String = ""
    private(set) var extraInfo: [String: String] = [:]

    func configure(userID: String, name: String, phone: String, extra: [String: String]) {
        self.userID = userID
        self.name = name
        self.phone = phone
        self.extraInfo = extra
    }
}
