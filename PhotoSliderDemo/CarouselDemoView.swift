//
//  CarouselDemoView.swift
//  PhotoSliderDemo
//
//  A full-width, horizontally paging carousel (Mercari-style product gallery).
//  Swipe left/right to flip through bundled local images one at a time, and tap
//  any image to open PhotoSlider full screen at that index. Closing PhotoSlider
//  on a different page keeps the carousel page in sync via the shared `selection`
//  binding (the SwiftUI replacement for the old `photoSliderControllerWillDismiss`
//  → `currentRow` syncing in the UIKit demo).
//
//  This screen also wires the *hero (zoom) transition* by handing PhotoSlider the
//  on-screen frame of each page's image via the `sourceFrame:` overload. Presenting
//  zooms the tapped thumbnail up to full screen; closing (button or swipe-down)
//  shrinks the current page's image back into its carousel slot instead of fading
//  out to a blank backdrop.
//

import SwiftUI
import PhotoSlider

/// Full-width swipeable carousel landing screen.
///
/// - Uses `TabView` + `.tabViewStyle(.page(indexDisplayMode: .always))` so each
///   page snaps to one full-width image with a page-indicator dot row.
/// - Photos come from `DemoData.localPhotos()` (bundled `image001`–`image008`),
///   so it works fully offline.
/// - `selection` is shared between the carousel and PhotoSlider, giving two-way
///   page follow without any manual delegate plumbing.
/// - `frames` records each page's image rect in `.global` screen coordinates so
///   the hero transition can grow from / shrink back to the right slot.
struct CarouselDemoView: View {

    private let photos = DemoData.localPhotos()

    /// Current carousel page. Also drives `PhotoSlider`'s page while presented,
    /// so swiping inside the viewer moves the carousel underneath.
    @State private var selection = 0
    @State private var isPresented = false

    /// `index` → the rect (in `.global` screen coordinates) of the *visible image*
    /// for that page. Updated on appear and whenever the page's geometry changes
    /// (rotation, page change, safe-area updates), so the value handed to
    /// `sourceFrame` always reflects what is currently on screen.
    @State private var frames: [Int: CGRect] = [:]

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                pageImage(for: photo, at: index)
                    .tag(index)
                    .accessibilityIdentifier("carousel-page-\(index)")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Carousel")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("carousel")
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection,
            // Return the recorded image rect for `index`; `nil` (page never laid
            // out / off-screen) makes PhotoSlider fall back to a cross-fade.
            sourceFrame: { index in frames[index] }
        )
    }

    @ViewBuilder
    private func pageImage(for photo: PhotoItem, at index: Int) -> some View {
        Button {
            isPresented = true
        } label: {
            carouselImage(for: photo)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .contentShape(Rectangle())
                .background(frameReader(for: photo, at: index))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(photo.caption ?? "Photo")
        .accessibilityHint("Opens the photo full screen")
    }

    @ViewBuilder
    private func carouselImage(for photo: PhotoItem) -> some View {
        if case let .uiImage(image) = photo.source {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Color.gray
        }
    }

    /// Transparent geometry probe placed behind each page. It measures the page's
    /// `.global` rect, then narrows it to the *image* rect that `scaledToFit`
    /// actually paints (letterbox/pillarbox bars stripped), so the hero transition
    /// shrinks back into the picture rather than the full-bleed page bounds.
    @ViewBuilder
    private func frameReader(for photo: PhotoItem, at index: Int) -> some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    frames[index] = imageRect(in: proxy.frame(in: .global), for: photo)
                }
                .onChange(of: proxy.frame(in: .global)) { _, newPageRect in
                    frames[index] = imageRect(in: newPageRect, for: photo)
                }
        }
    }

    /// Computes the rect that a `.scaledToFit()` image occupies inside `pageRect`.
    ///
    /// `scaledToFit` centers the image and adds letterbox/pillarbox bars, so the
    /// page rect is wider/taller than the painted image. We shrink `pageRect` to
    /// the aspect-fitted image rect so the hero animation lands exactly on the
    /// picture. Falls back to the full page rect when the source isn't a `UIImage`
    /// or has a degenerate size.
    private func imageRect(in pageRect: CGRect, for photo: PhotoItem) -> CGRect {
        guard case let .uiImage(image) = photo.source,
              image.size.width > 0, image.size.height > 0,
              pageRect.width > 0, pageRect.height > 0 else {
            return pageRect
        }

        let scale = min(pageRect.width / image.size.width,
                        pageRect.height / image.size.height)
        let fittedSize = CGSize(width: image.size.width * scale,
                                height: image.size.height * scale)
        let origin = CGPoint(
            x: pageRect.minX + (pageRect.width - fittedSize.width) / 2,
            y: pageRect.minY + (pageRect.height - fittedSize.height) / 2
        )
        return CGRect(origin: origin, size: fittedSize)
    }
}

#Preview {
    NavigationStack {
        CarouselDemoView()
    }
}
