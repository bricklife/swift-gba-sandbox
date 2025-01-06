// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-gba",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "swift-gba",
            targets: ["swift-gba"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "swift-gba",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("Embedded"),
            ]
        )
    ]
)
