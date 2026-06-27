//
//  KingfisherDemoView.swift
//  PhotoSliderDemo
//
//  Demonstrates using the Kingfisher-backed image loader.
//

import SwiftUI
import PhotoSlider
import PhotoSliderKingfisher

/// Holds thumbnail images fetched with the Kingfisher-backed `ImageLoader`.
///
/// Mirrors `RemoteThumbnailStore`, but loads through `.kingfisher()` instead of
/// the default loader — so both the grid thumbnails and the full-screen viewer
/// go through Kingfisher end to end.
@MainActor
@Observable
final class KingfisherThumbnailStore {
    private(set) var images: [URL: UIImage] = [:]
    private let loader: any ImageLoader = .kingfisher()

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

/// Kingfisher demo: same remote URLs as the Remote demo, but every image — grid
/// thumbnails and the full-screen slider — is loaded with `.kingfisher()`.
struct KingfisherDemoView: View {

    private let photos = DemoData.remotePhotos()
    @State private var store = KingfisherThumbnailStore()
    @State private var isPresented = false
    @State private var selection = 0

    var body: some View {
        ThumbnailGridView(
            photos: photos,
            thumbnailProvider: { photo in
                if case let .remote(url) = photo.source { return store.images[url] }
                return nil
            },
            onTap: { index in
                selection = index
                isPresented = true
            }
        )
        .navigationTitle("Kingfisher")
        .navigationBarTitleDisplayMode(.inline)
        .task { store.load(DemoData.remoteURLs) }
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection,
            imageLoader: .kingfisher()
        )
    }
}

#Preview {
    NavigationStack {
        KingfisherDemoView()
    }
}
