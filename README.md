![SwiftLogger thumbnail](https://user-gen-media-assets.s3.amazonaws.com/gpt4o_images/96dccea7-b1e6-43df-846c-df87fad6bcf8.png)
# SwiftLogger

SwiftLogger is a pure Swift library designed for logging in iOS, macOS, and other Apple platforms.

## Overview

SwiftLogger provides a simple, efficient logging solution for Swift applications. It offers configurable log levels, easy integration, and comprehensive debugging information to help developers track application behavior and troubleshoot issues effectively.

## Installation

### Swift Package Manager (SPM)

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

#### If using in an Application

1. File > Swift Packages > Add Package Dependency
2. Add `https://github.com/sahibhussain/SwiftLogger.git`
3. Select "Up to Next Major" with "1.0.0"

#### If using in a Package

Once you have your Swift package set up, adding SwiftLogger as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

```swift
dependencies: [
    .package(url: "https://github.com/sahibhussain/SwiftLogger.git", .upToNextMajor(from: "1.0.0"))
]
```

Normally you'll want to depend on the `SwiftLogger` target:

```swift
.product(name: "SwiftLogger", package: "SwiftLogger")
```

## Usage

### Log Levels

SwiftLogger supports the following log levels:

- `info` - General information messages
- `debug` - Detailed debugging information
- `warning` - Warning messages for potential issues
- `error` - Error messages for actual problems

The values are `Int` types in incremental order of the above levels.

You can choose to omit logs up to a certain level. For example:

```swift
// If you want to log only warnings and errors
SwiftLogger.shared.logLevel = .warning
```

### Helper Functions for Easy Logging

Each logging function accepts the following parameters:

- `message: String`: A message that you want to log
- `properties: [String: Any]?`: All the properties that you want to print
- `fileName: String`: Name of the file from which the log was initiated
- `line: Int`: Line number of the code where the log was initiated
- `column: Int`: Column number of the code where the log was initiated
- `functionName: String`: Name of the function where the log was initiated
- `loggerCategory: String`: Category of the log

```swift
SwiftLogger.shared.info("message", properties = nil, fileName = #file, line = #line, column = #column, functionName = #function, loggerCategory = "Default")

SwiftLogger.shared.debug("message", properties = nil, fileName = #file, line = #line, column = #column, functionName = #function, loggerCategory = "Default")

SwiftLogger.shared.warning("message", properties = nil, fileName = #file, line = #line, column = #column, functionName = #function, loggerCategory = "Default")

SwiftLogger.shared.error("message", properties = nil, fileName = #file, line = #line, column = #column, functionName = #function, loggerCategory = "Default")
```

## Support

### Contact

Follow and contact me on [X (Twitter)](https://x.com/Sahib_hussain0). If you find an issue, [open a ticket](https://github.com/sahibhussain/SwiftLogger/issues/new).