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
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
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
        .testTarget(
            name: "MobileDeviceKitTests",
            dependencies: ["MobileDeviceKit"]
        )
    ]
)
