//
//  KingfisherDemoView.swift
//  PhotoSliderDemo
//
//  Demonstrates using the Kingfisher-backed image loader.
//

import SwiftUI
import PhotoSlider
import PhotoSliderKingfisher
import Kingfisher

/// Kingfisher demo: same remote URLs, but the slider uses `.kingfisher()` loader.
struct KingfisherDemoView: View {

    private let photos = DemoData.remotePhotos()
    @State private var isPresented = false
    @State private var selection = 0

    var body: some View {
        ThumbnailGridView(
            photos: photos,
            // Thumbnails intentionally use Kingfisher's own SwiftUI view
            // to show the dependency works end to end.
            thumbnailProvider: { _ in nil },
            onTap: { index in
                selection = index
                isPresented = true
            }
        )
        .overlay(alignment: .top) { kingfisherThumbnailStrip }
        .navigationTitle("Kingfisher")
        .navigationBarTitleDisplayMode(.inline)
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection,
            imageLoader: .kingfisher()
        )
    }

    @ViewBuilder
    private var kingfisherThumbnailStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(DemoData.remoteURLs.enumerated()), id: \.offset) { index, url in
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            selection = index
                            isPresented = true
                        }
                        .accessibilityIdentifier("kf-thumbnail-\(index)")
                }
            }
            .padding(8)
        }
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        KingfisherDemoView()
    }
}
