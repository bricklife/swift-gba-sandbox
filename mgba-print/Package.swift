// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-gba",
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
                .enableExperimentalFeature("Embedded")
            ]
        )
    ]
)
