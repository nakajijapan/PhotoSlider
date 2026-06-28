//
//  DemoData.swift
//  PhotoSliderDemo
//
//  Hard-coded sample data used across the demo screens.
//

import SwiftUI
import PhotoSlider

/// Sample data factory for the demo.
///
/// - Local images ship inside the app bundle (`Resources/image001.jpg` … `image008.jpg`)
///   so the demo works fully offline.
/// - Remote images use small public placeholder URLs.
enum DemoData {

    /// Names of the bundled local sample images (without extension).
    static let localImageNames: [String] = (1...8).map { String(format: "image%03d", $0) }

    /// Loads a bundled JPEG by name. Returns a solid-color placeholder if missing.
    static func localImage(named name: String) -> UIImage {
        if let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }
        return placeholderImage()
    }

    /// `PhotoItem`s backed by in-memory `UIImage`s decoded from the bundle.
    static func localPhotos() -> [PhotoItem] {
        localImageNames.enumerated().map { index, name in
            PhotoItem(source: .uiImage(localImage(named: name)),
                      caption: "Local image \(index + 1)")
        }
    }

    /// Remote photo URLs (public placeholder service). Used with the default loader.
    static let remoteURLs: [URL] = [
        "https://picsum.photos/id/1018/1200/1600",
        "https://picsum.photos/id/1015/1200/1600",
        "https://picsum.photos/id/1019/1200/1600",
        "https://picsum.photos/id/1016/1200/1600",
        "https://picsum.photos/id/1024/1200/1600",
        "https://picsum.photos/id/1025/1200/1600",
    ].compactMap(URL.init(string:))

    /// `PhotoItem`s backed by remote URLs.
    static func remotePhotos() -> [PhotoItem] {
        remoteURLs.enumerated().map { index, url in
            PhotoItem(source: .remote(url), caption: "Remote photo \(index + 1)")
        }
    }

    /// A deterministic solid-color placeholder image.
    static func placeholderImage(size: CGSize = CGSize(width: 1200, height: 1600)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

/// Loads grid thumbnails through the library's ``ImageLoader`` abstraction, caching by URL.
///
/// Shared by the Remote (`.default`) and Kingfisher (`.kingfisher()`) demos — they differ
/// only by the injected loader, so the load/cache logic lives in one place.
@MainActor
@Observable
final class ThumbnailStore {

    private(set) var images: [URL: UIImage] = [:]
    private let loader: any ImageLoader

    init(loader: any ImageLoader) {
        self.loader = loader
    }

    /// Loads any not-yet-cached URLs concurrently; each image is published as it finishes.
    func load(_ urls: [URL]) {
        for url in urls where images[url] == nil {
            Task { [loader] in
                if let image = try? await loader.loadImage(from: url) {
                    self.images[url] = image
                }
            }
        }
    }
}
