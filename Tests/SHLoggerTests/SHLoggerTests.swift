import XCTest
@testable import SwiftLogger

final class SHLoggerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SwiftLogger.shared.logLevel = .info
        SwiftLogger.shared.deleteLogDir()
    }

    // MARK: - LogLevel

    func testLogLevelOrdering() {
        XCTAssertTrue(LogLevel.error >= LogLevel.warning)
        XCTAssertTrue(LogLevel.warning > LogLevel.debug)
        XCTAssertTrue(LogLevel.debug > LogLevel.info)
    }

    func testLogLevelDescriptions() {
        XCTAssertEqual(LogLevel.info.description, "Info")
        XCTAssertEqual(LogLevel.debug.description, "Debug")
        XCTAssertEqual(LogLevel.warning.description, "Warning")
        XCTAssertEqual(LogLevel.error.description, "Error")
    }

    func testLogLevelFiltering() {
        SwiftLogger.shared.logLevel = .error
        XCTAssertTrue(SwiftLogger.shared.logLevel > .warning)
    }

    // MARK: - Writing

    func testLogFilePathIsNonNilAfterWrite() {
        SwiftLogger.shared.error("test error", category: "Network")
        waitForLogQueue()
        XCTAssertNotNil(SwiftLogger.shared.logFilePath(category: "Network"))
    }

    func testCategoryIsolation() {
        SwiftLogger.shared.error("network error", category: "Network")
        SwiftLogger.shared.error("auth error", category: "Auth")
        waitForLogQueue()
        let networkPath = SwiftLogger.shared.logFilePath(category: "Network")
        let authPath = SwiftLogger.shared.logFilePath(category: "Auth")
        XCTAssertNotEqual(networkPath, authPath)
        XCTAssertTrue(SwiftLogger.shared.logPrint(category: "Network").contains("network error"))
        XCTAssertTrue(SwiftLogger.shared.logPrint(category: "Auth").contains("auth error"))
        XCTAssertFalse(SwiftLogger.shared.logPrint(category: "Network").contains("auth error"))
    }

    func testSetProfile() {
        SwiftLogger.shared.setProfile(userID: "u1", name: "Alice", phone: "555-0100", extra: ["role": "admin"])
    }

    // MARK: - Clearing

    func testClearTodayForCategory() {
        SwiftLogger.shared.error("to be cleared", category: "Network")
        waitForLogQueue()
        XCTAssertFalse(SwiftLogger.shared.logPrint(category: "Network").isEmpty)
        SwiftLogger.shared.clearLogs(category: "Network", date: Date())
        XCTAssertTrue(SwiftLogger.shared.logPrint(category: "Network").isEmpty)
    }

    func testClearEntireCategory() {
        SwiftLogger.shared.error("msg", category: "Auth")
        waitForLogQueue()
        XCTAssertFalse(SwiftLogger.shared.logPrint(category: "Auth").isEmpty)
        SwiftLogger.shared.clearLogs(category: "Auth")
        XCTAssertTrue(SwiftLogger.shared.logPrint(category: "Auth").isEmpty)
    }

    func testClearCategoryDoesNotAffectOthers() {
        SwiftLogger.shared.error("network msg", category: "Network")
        SwiftLogger.shared.error("auth msg", category: "Auth")
        waitForLogQueue()
        SwiftLogger.shared.clearLogs(category: "Network")
        XCTAssertTrue(SwiftLogger.shared.logPrint(category: "Network").isEmpty)
        XCTAssertFalse(SwiftLogger.shared.logPrint(category: "Auth").isEmpty)
    }

    func testClearOldLogsKeepsRecentFiles() {
        SwiftLogger.shared.error("recent msg", category: "Default")
        waitForLogQueue()
        SwiftLogger.shared.clearOldLogs(olderThan: 7)
        // today's file is within 7 days — should survive
        XCTAssertFalse(SwiftLogger.shared.logPrint(category: "Default").isEmpty)
    }

    func testRetentionDaysKeepsCurrentLogs() {
        SwiftLogger.shared.retentionDays = 7
        SwiftLogger.shared.error("kept msg", category: "Default")
        waitForLogQueue()
        // today's file is within retention window — must not be removed
        XCTAssertFalse(SwiftLogger.shared.logPrint(category: "Default").isEmpty)
        SwiftLogger.shared.retentionDays = nil
    }

    func testRetentionDaysNilDisablesAutoClear() {
        SwiftLogger.shared.retentionDays = nil
        SwiftLogger.shared.error("msg", category: "Default")
        waitForLogQueue()
        XCTAssertFalse(SwiftLogger.shared.logPrint(category: "Default").isEmpty)
    }

    func testDeleteLogDir() {
        SwiftLogger.shared.error("test", category: "Default")
        waitForLogQueue()
        SwiftLogger.shared.deleteLogDir()
        XCTAssertTrue(SwiftLogger.shared.logPrint(category: "Default").isEmpty)
    }

    func testDeleteLogDirIsIdempotent() {
        SwiftLogger.shared.deleteLogDir()
        SwiftLogger.shared.deleteLogDir()
        // Should not crash when called on an already-absent directory.
    }

    // MARK: - Helpers

    private func waitForLogQueue(timeout: TimeInterval = 1) {
        let e = expectation(description: "log queue drained")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { e.fulfill() }
        waitForExpectations(timeout: timeout)
    }
}
