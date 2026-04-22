// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "lowlevel",
    products: [
        .executable(
            name: "Game",
            targets: ["Game"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Game",
            swiftSettings: [
                .enableExperimentalFeature("Embedded")
            ]
        )
    ]
)
