// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "System",
    platforms: [
        .watchOS(.v4),
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15)
      ],
    products: [
        .library(
            name: "System",
            targets: ["System"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "System",
            path: "Sources/Swift"
        )
    ]
)
