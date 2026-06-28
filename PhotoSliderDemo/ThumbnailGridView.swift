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
            // A square footprint (`Color.clear` + 1:1 aspect ratio) drives the cell
            // size, and the image fills it as an overlay and is clipped to the
            // square. Doing it the other way round (scaledToFill *then* aspectRatio)
            // lets the image's own landscape size leak into layout, so cells end up
            // different sizes and overflow into their neighbours.
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay { thumbnailImage(for: photo) }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentShape(RoundedRectangle(cornerRadius: 8))
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
