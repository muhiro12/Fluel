// swift-tools-version: 6.2

import PackageDescription

let package = Package( // swiftlint:disable:this prefixed_toplevel_constant
    name: "FluelLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "FluelLibrary",
            targets: ["FluelLibrary"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/muhiro12/MHPlatform.git",
            "1.0.0"..<"2.0.0"
        )
    ],
    targets: [
        .target(
            name: "FluelLibrary",
            dependencies: [
                .product(
                    name: "MHPlatformCore",
                    package: "MHPlatform"
                )
            ],
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
