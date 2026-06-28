//
//  RemotePhotosDemoView.swift
//  PhotoSliderDemo
//
//  Demonstrates PhotoSource.remote(URL) with the default URLSession loader.
//

import SwiftUI
import PhotoSlider

/// Remote images demo: URLs loaded by the default loader.
struct RemotePhotosDemoView: View {

    private let photos = DemoData.remotePhotos()
    @State private var store = ThumbnailStore(loader: .default)
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
