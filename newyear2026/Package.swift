// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "gba-sprite",
    products: [
        .executable(
            name: "Game",
            targets: ["Game"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Game",
            dependencies: [
                "Support",
            ],
            swiftSettings: [
                .enableExperimentalFeature("Volatile"),
                .enableExperimentalFeature("SymbolLinkageMarkers"),
            ]
        ),
        .target(name: "Support"),
    ]
)
