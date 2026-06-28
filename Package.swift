// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "PhotoSlider",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "PhotoSlider", targets: ["PhotoSlider"]),
        .library(name: "PhotoSliderKingfisher", targets: ["PhotoSliderKingfisher"]),
    ],
    dependencies: [
        // PhotoSlider core has NO dependency.
        // Kingfisher is only used by the optional PhotoSliderKingfisher target.
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "PhotoSlider",
            dependencies: [],
            path: "Sources/PhotoSlider",
            resources: [
                .process("PhotoSlider.xcassets"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "PhotoSliderKingfisher",
            dependencies: [
                "PhotoSlider",
                .product(name: "Kingfisher", package: "Kingfisher"),
            ],
            path: "Sources/PhotoSliderKingfisher",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "PhotoSliderTests",
            dependencies: ["PhotoSlider"],
            path: "Tests/PhotoSliderTests",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "PhotoSliderKingfisherTests",
            dependencies: ["PhotoSliderKingfisher"],
            path: "Tests/PhotoSliderKingfisherTests",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
