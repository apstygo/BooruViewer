// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "booru-api",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [
        .library(name: "SankakuAPI", targets: ["SankakuAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya", from: "15.0.3")
    ],
    targets: [
        .target(name: "SankakuAPI", dependencies: ["Moya"])
    ]
)
