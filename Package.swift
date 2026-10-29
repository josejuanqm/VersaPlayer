// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VersaPlayer",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "VersaPlayer", targets: ["VersaPlayer"]),
    ],
    targets: [
        .target(name: "VersaPlayerCore"),
        .target(name: "VersaPlayer", dependencies: ["VersaPlayerCore"]),
        .testTarget(name: "VersaPlayerCoreTests", dependencies: ["VersaPlayerCore"]),
        .testTarget(name: "VersaPlayerTests", dependencies: ["VersaPlayer"]),
    ],
    swiftLanguageModes: [.v6]
)
