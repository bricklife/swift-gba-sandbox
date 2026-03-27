// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "newyear2026",
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
                .enableExperimentalFeature("Embedded"),
                .enableExperimentalFeature("Volatile"),
            ]
        ),
        .target(name: "Support"),
    ]
)
