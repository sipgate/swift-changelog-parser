// swift-tools-version: 5.9.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-changelog-parser",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.4.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "swift-changelog-parser",
            dependencies: [.product(name: "Markdown", package: "swift-markdown"),
                           .product(name: "ArgumentParser", package: "swift-argument-parser")]),
    ]
)
