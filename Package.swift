// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PhotoSlider",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "PhotoSlider", targets: ["PhotoSlider"])
    ],
    dependencies: [
        .package(url: "git@github.com:onevcat/Kingfisher.git", from: "7.1.2")
    ],
    targets: [
        .target(
            name: "PhotoSlider",
            dependencies: ["Kingfisher"],
            path: "Sources",
            resources: [
                .process("PhotoSlider.xcassets")
            ]
        )
    ]
)
