// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pilot",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Pilot",
            targets: ["Pilot"]
        ),
        .library(
            name: "PilotTestSupport",
            targets: ["PilotTestSupport"]
        ),
        .library(
            name: "PilotType",
            targets: ["PilotType"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Pilot",
            dependencies: ["PilotType"]
        ),
        .target(
            name: "PilotTestSupport",
            dependencies: []
        ),
        .target(
            name: "PilotType",
            dependencies: []
        ),
        .testTarget(
            name: "PilotTests",
            dependencies: ["Pilot", "PilotTestSupport"]
        )
    ]
)
