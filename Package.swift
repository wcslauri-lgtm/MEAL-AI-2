// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "MEAL_AI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MEAL_AI",
            targets: ["MEAL_AI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MEAL_AI",
            path: "MEAL AI/Sources"
        ),
        .testTarget(
            name: "MEAL_AITests",
            dependencies: ["MEAL_AI"],
            path: "MEAL AITests"
        ),
        .testTarget(
            name: "MEAL_AIUITests",
            dependencies: ["MEAL_AI"],
            path: "MEAL AIUITests"
        )
    ]
)
