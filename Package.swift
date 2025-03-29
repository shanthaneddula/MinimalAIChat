// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MinimalAIChat",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "MinimalAIChat",
            targets: ["MinimalAIChat"]
        ),
        .library(
            name: "MinimalAIChatCore",
            targets: ["MinimalAIChatCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "MinimalAIChat",
            dependencies: [
                "MinimalAIChatCore",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            path: "Sources/MinimalAIChat"
        ),
        .target(
            name: "MinimalAIChatCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            path: "Sources/MinimalAIChatCore"
        ),
        .testTarget(
            name: "MinimalAIChatTests",
            dependencies: ["MinimalAIChatCore"],
            path: "Tests/Unit"
        ),
        .testTarget(
            name: "MinimalAIChatIntegrationTests",
            dependencies: ["MinimalAIChatCore"],
            path: "Tests/Integration"
        ),
        .testTarget(
            name: "MinimalAIChatPerformanceTests",
            dependencies: ["MinimalAIChatCore"],
            path: "Tests/Performance"
        ),
    ]
)
