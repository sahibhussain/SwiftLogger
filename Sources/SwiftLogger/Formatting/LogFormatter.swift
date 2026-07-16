import Foundation

struct LogFormatter {

    func format(_ entry: LogEntry) -> String {
        var output = entry.timestamp.toString()
        output += " [\(entry.level.description)]"
        output += " [\(sourceFileName(from: entry.fileName))]"
        output += " [\(entry.line)]"

        let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)
        output += " [\(String(describing: queueLabel))]"

        output += " \(entry.functionName)"
        output += " -> \(entry.message)"

        if let props = entry.properties {
            output += "\nPROPERTIES ¬ \n"
            for (key, value) in props {
                output += "\(key): \"\(value)\"\n"
            }
        }

        return output
    }

    private func sourceFileName(from filePath: String) -> String {
        filePath.components(separatedBy: "/").last ?? filePath
    }
}
