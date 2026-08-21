// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "SystemInfo",
    platforms: [
        .watchOS(.v4),
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15)
      ],
    products: [
        .library(
            name: "SystemInfo",
            targets: ["SystemInfo"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SystemInfo",
            path: "Sources/Swift"
        )
    ]
)
