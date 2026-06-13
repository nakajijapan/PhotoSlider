//
//  ThumbnailGridView.swift
//  PhotoSliderDemo
//
//  A reusable LazyVGrid of thumbnails. Tapping a thumbnail reports its index.
//

import SwiftUI
import PhotoSlider

/// A grid of square thumbnails. Each tap calls `onTap` with the tapped index.
struct ThumbnailGridView: View {

    let photos: [PhotoItem]
    /// Async thumbnail provider. Returns `nil` while loading / on failure.
    let thumbnailProvider: (PhotoItem) -> UIImage?
    let onTap: (Int) -> Void

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    thumbnail(for: photo, index: index)
                }
            }
            .padding(8)
        }
    }

    @ViewBuilder
    private func thumbnail(for photo: PhotoItem, index: Int) -> some View {
        Button {
            onTap(index)
        } label: {
            thumbnailImage(for: photo)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("thumbnail-\(index)")
        .accessibilityLabel(photo.caption ?? "Photo \(index + 1)")
    }

    @ViewBuilder
    private func thumbnailImage(for photo: PhotoItem) -> some View {
        if let image = thumbnailProvider(photo) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Rectangle().fill(.quaternary)
                ProgressView()
            }
        }
    }
}

#Preview {
    ThumbnailGridView(
        photos: DemoData.localPhotos(),
        thumbnailProvider: { photo in
            if case let .uiImage(image) = photo.source { return image }
            return nil
        },
        onTap: { print("tapped \($0)") }
    )
}
