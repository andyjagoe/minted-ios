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
    dependencies: [
        .package(url: "https://github.com/clerk/clerk-ios.git", exact: "0.55.0")
    ],
    targets: [
        .target(
            name: "MintedUI",
            dependencies: [
                .product(name: "Clerk", package: "clerk-ios")
            ],
            path: "Sources/MintedUI",
            sources: ["Models", "ViewModels", "Views", "Services"],
            resources: [.process("Assets.xcassets")]),
        .testTarget(
            name: "MintedUITests",
            dependencies: ["MintedUI"]),
    ]
) 