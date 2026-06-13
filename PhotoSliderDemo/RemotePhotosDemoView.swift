//
//  RemotePhotosDemoView.swift
//  PhotoSliderDemo
//
//  Demonstrates PhotoSource.remote(URL) with the default URLSession loader.
//

import SwiftUI
import PhotoSlider

/// Holds thumbnail images fetched with the library's `DefaultImageLoader`.
@MainActor
@Observable
final class RemoteThumbnailStore {
    private(set) var images: [URL: UIImage] = [:]
    private let loader: any ImageLoader = .default

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

/// Remote images demo: URLs loaded by the default loader.
struct RemotePhotosDemoView: View {

    private let photos = DemoData.remotePhotos()
    @State private var store = RemoteThumbnailStore()
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
        .navigationTitle("Remote (default)")
        .navigationBarTitleDisplayMode(.inline)
        .task { store.load(DemoData.remoteURLs) }
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection
        )
    }
}

#Preview {
    NavigationStack {
        RemotePhotosDemoView()
    }
}
