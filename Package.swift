import PackageDescription

let package = PhotoSlider(
    name: "PhotoSlider",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "PhotoSlider", targets: ["PhotoSlider"])
    ],
    dependencies: [
        .Package(url: "git@github.com:onevcat/Kingfisher.git")
    ]
)
