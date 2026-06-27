// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package( // swiftlint:disable:this prefixed_toplevel_constant
    name: "FluelLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS("27.0")
    ],
    products: [
        .library(
            name: "FluelLibrary",
            targets: ["FluelLibrary"]
        )
    ],
    targets: [
        .target(
            name: "FluelLibrary",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FluelLibraryTests",
            dependencies: ["FluelLibrary"],
            path: "Tests/Default"
        )
    ]
)
