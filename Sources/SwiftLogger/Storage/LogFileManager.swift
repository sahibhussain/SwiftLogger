import Foundation
import OSLog

final class LogFileManager {

    private static let rootDirectoryName = "Logs"
    private let oslog = Logger(subsystem: "", category: "SwiftLogger.Storage")

    // MARK: - Paths

    func filePath(category: String, date: Date = Date()) -> String? {
        guard let dir = categoryDirectoryURL(category: category) else { return nil }
        return dir.appendingPathComponent(date.toDateString()).path + ".txt"
    }

    private func categoryDirectoryURL(category: String) -> URL? {
        guard let root = rootDirectoryURL else { return nil }
        let dir = root.appendingPathComponent(category)
        guard !FileManager.default.fileExists(atPath: dir.path) else { return dir }
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
            oslog.error("Failed to create category directory '\(category)': \(error.localizedDescription)")
        }
        return dir
    }

    // Returns nil (not creating) when the root does not yet exist — used by clearing ops.
    private var existingRootDirectoryURL: URL? {
        guard let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let dir = caches.appendingPathComponent(LogFileManager.rootDirectoryName)
        return FileManager.default.fileExists(atPath: dir.path) ? dir : nil
    }

    private var rootDirectoryURL: URL? {
        guard let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        let dir = caches.appendingPathComponent(LogFileManager.rootDirectoryName)
        guard !FileManager.default.fileExists(atPath: dir.path) else { return dir }
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
            oslog.error("Failed to create log root directory: \(error.localizedDescription)")
        }
        return dir
    }

    // MARK: - Write / Read

    func append(_ text: String, category: String, header: String?) {
        guard let path = filePath(category: category) else { return }
        let prefix: String
        if FileManager.default.fileExists(atPath: path) {
            prefix = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
        } else {
            prefix = header ?? ""
        }
        let content = prefix + text + "\n\n"
        do {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            oslog.error("Failed to write log for category '\(category)': \(error.localizedDescription)")
        }
    }

    func read(category: String, date: Date = Date()) -> String {
        guard let path = filePath(category: category, date: date),
              FileManager.default.fileExists(atPath: path) else { return "" }
        return (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
    }

    // MARK: - Clearing

    /// Remove today's log file for a specific category.
    func clear(category: String, date: Date) {
        guard let path = filePath(category: category, date: date) else { return }
        try? FileManager.default.removeItem(atPath: path)
    }

    /// Remove all log files for a specific category.
    func clear(category: String) {
        guard let root = existingRootDirectoryURL else { return }
        let dir = root.appendingPathComponent(category)
        try? FileManager.default.removeItem(at: dir)
    }

    /// Remove all log files across every category that are older than `days` days.
    func clearOldLogs(olderThan days: Int) {
        guard let root = existingRootDirectoryURL,
              let categories = try? FileManager.default.contentsOfDirectory(
                  at: root, includingPropertiesForKeys: [.isDirectoryKey]
              ) else { return }

        guard let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else { return }
        let formatter = Date.logDateFormatter

        for categoryURL in categories {
            guard (try? categoryURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true else { continue }
            guard let files = try? FileManager.default.contentsOfDirectory(
                at: categoryURL, includingPropertiesForKeys: nil
            ) else { continue }
            for file in files where file.pathExtension == "txt" {
                let stem = file.deletingPathExtension().lastPathComponent
                guard let fileDate = formatter.date(from: stem), fileDate < cutoff else { continue }
                try? FileManager.default.removeItem(at: file)
            }
        }
    }

    /// Remove the entire Logs directory.
    func deleteAll() {
        guard let root = existingRootDirectoryURL else { return }
        try? FileManager.default.removeItem(at: root)
    }
}
