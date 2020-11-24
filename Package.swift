// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gladiator-asset-builder",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/GladiatorEngine/GladiatorAssetManager", .branch("main")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/kelvin13/PNG", .exact("3.0.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "gladiator-asset-builder",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "GladiatorAssetManager", package: "GladiatorAssetManager"),
                .product(name: "PNG", package: "PNG")
            ]),
        .testTarget(
            name: "AssetBuilderTests",
            dependencies: ["gladiator-asset-builder"]),
    ]
)
