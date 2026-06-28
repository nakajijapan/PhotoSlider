//
//  LocalPhotosDemoView.swift
//  PhotoSliderDemo
//
//  Demonstrates PhotoSource.uiImage with bundled local images (offline).
//

import SwiftUI
import PhotoSlider

/// Local images demo: bundled `UIImage`s shown via `.photoSlider(isPresented:...)`.
struct LocalPhotosDemoView: View {

    private let photos = DemoData.localPhotos()
    @State private var isPresented = false
    @State private var selection = 0

    var body: some View {
        ThumbnailGridView(
            photos: photos,
            thumbnailProvider: { photo in
                if case let .uiImage(image) = photo.source { return image }
                return nil
            },
            onTap: { index in
                selection = index
                isPresented = true
            }
        )
        .navigationTitle("Local (uiImage)")
        .navigationBarTitleDisplayMode(.inline)
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection
        )
    }
}

#Preview {
    NavigationStack {
        LocalPhotosDemoView()
    }
}
