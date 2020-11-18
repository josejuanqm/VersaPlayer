// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "VersaPlayer",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "VersaPlayer",
            targets: ["VersaPlayer"]
        ),
    ],
    targets: [
		.target(
            name: "VersaPlayer",
            path: "VersaPlayer/Classes/Source"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
