// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MintedUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MintedUI",
            targets: ["MintedUI"]),
    ],
    targets: [
        .target(
            name: "MintedUI",
            dependencies: [],
            path: "Sources/MintedUI",
            sources: ["Models", "ViewModels", "Views"],
            resources: [.process("Assets.xcassets")]),
        .testTarget(
            name: "MintedUITests",
            dependencies: ["MintedUI"]),
    ]
) 