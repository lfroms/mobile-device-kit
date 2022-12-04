// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobileDeviceKit",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "MobileDeviceKit",
            targets: ["MobileDeviceKit"]
        ),
        .executable(
            name: "deviceutil",
            targets: ["MobileDeviceUtil"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "MobileDeviceKit",
            dependencies: ["MobileDevice"]
        ),
        .target(
            name: "MobileDevice",
            linkerSettings: [
                .unsafeFlags(["-F", "/Library/Apple/System/Library/PrivateFrameworks/"]),
                .linkedFramework("MobileDevice")
            ]
        ),
        .executableTarget(
            name: "MobileDeviceUtil",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "MobileDeviceKit"
            ]
        ),
        .testTarget(
            name: "MobileDeviceKitTests",
            dependencies: ["MobileDeviceKit"]
        )
    ]
)
