//
//  KingfisherDemoView.swift
//  PhotoSliderDemo
//
//  Demonstrates using the Kingfisher-backed image loader.
//

import SwiftUI
import PhotoSlider
import PhotoSliderKingfisher

/// Kingfisher demo: same remote URLs as the Remote demo, but every image — grid
/// thumbnails and the full-screen slider — is loaded with `.kingfisher()`.
struct KingfisherDemoView: View {

    private let photos = DemoData.remotePhotos()
    @State private var store = ThumbnailStore(loader: .kingfisher())
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
