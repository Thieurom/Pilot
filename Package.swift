// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pilot",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .macCatalyst(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Pilot",
            targets: ["Pilot"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Pilot",
            dependencies: []
        ),
        .testTarget(
            name: "PilotTests",
            dependencies: ["Pilot"]
        )
    ]
)
