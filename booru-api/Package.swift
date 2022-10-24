// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "booru-api",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [
        .library(name: "SankakuAPI", targets: ["SankakuAPI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SankakuAPI"
        )
    ]
)
