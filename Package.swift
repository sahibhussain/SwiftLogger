// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftLogger",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftLogger",
            targets: ["SwiftLogger"]),
    ],
    targets: [
        .target(
            name: "SwiftLogger"),
        .testTarget(
            name: "SHLoggerTests",
            dependencies: ["SwiftLogger"]),
    ]
)
