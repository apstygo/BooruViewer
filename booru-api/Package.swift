// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "booru-api",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [
        .library(name: "SankakuAPI", targets: ["SankakuAPI"])
    ],
    dependencies: [.package(url: "https://github.com/Kitura/Swift-JWT", .upToNextMajor(from: "4.0.0"))],
    targets: [
        .target(
            name: "SankakuAPI",
            dependencies: [.product(name: "SwiftJWT", package: "Swift-JWT")]
        )
    ]
)
