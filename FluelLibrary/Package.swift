// swift-tools-version: 6.2

import PackageDescription

let package = Package( // swiftlint:disable:this prefixed_toplevel_constant
    name: "FluelLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
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
            path: ".",
            sources: [
                "Sources"
            ],
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
