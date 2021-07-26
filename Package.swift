// swift-tools-version:5.4.0
import PackageDescription

let package = Package(
    name: "PhotoSlider",
    platforms: [.iOS(.v13)],
    dependencies: [
        .package(url: "git@github.com:onevcat/Kingfisher.git", from: "6.3.0")
    ]
)
