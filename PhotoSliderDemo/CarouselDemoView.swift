//
//  CarouselDemoView.swift
//  PhotoSliderDemo
//
//  A *square* (1:1), horizontally paging carousel pinned to the top of the
//  screen — the SwiftUI port of the original UIKit demo, where a square
//  collection view (cell size `width × width`) sat at the top and you swiped
//  through photos one at a time. Tapping a page opens PhotoSlider full screen at
//  that index. Closing PhotoSlider on a different page keeps the carousel page
//  in sync via the shared `selection` binding (the SwiftUI replacement for the
//  old `photoSliderControllerWillDismiss` → `currentRow` syncing in UIKit).
//
//  This screen wires the *hero (zoom) transition* by handing PhotoSlider the
//  on-screen frame of the current page's image via the `sourceFrame:` overload.
//  Presenting zooms the tapped thumbnail up to full screen; closing (button or
//  swipe-down) shrinks the current page's image back into its square carousel
//  slot instead of fading out to a blank backdrop.
//
//  Hero-frame strategy: every page is the *same* fixed-size square and the image
//  is `scaledToFill`-clipped to fill it, so the painted image rect == the square
//  carousel rect for *all* pages. We therefore record a single `.global` frame
//  for the carousel container and return it for whatever `index` PhotoSlider
//  asks about. This sidesteps the TabView pitfall where an off-screen page's
//  `GeometryReader.onAppear` fires late: after swiping inside the viewer to a
//  page whose thumbnail never laid out, `sourceFrame(selection)` is still
//  non-nil, so the close animation always shrinks back into the square (never
//  silently falls back to a cross-fade).
//

import SwiftUI
import PhotoSlider

/// Square swipeable carousel landing screen (top-aligned, like the 1.x demo).
///
/// - Uses `TabView` + `.tabViewStyle(.page)` constrained to a 1:1 square via a
///   width-driven frame, so each page snaps to one square image with a
///   page-indicator dot row.
/// - Photos come from `DemoData.localPhotos()` (bundled `image001`–`image008`),
///   so it works fully offline.
/// - `selection` is shared between the carousel and PhotoSlider, giving two-way
///   page follow without any manual delegate plumbing.
/// - `carouselFrame` records the carousel square's rect in `.global` screen
///   coordinates so the hero transition can grow from / shrink back to it — for
///   the current page regardless of which page last laid out.
struct CarouselDemoView: View {

    private let photos = DemoData.localPhotos()

    /// Current carousel page. Also drives `PhotoSlider`'s page while presented,
    /// so swiping inside the viewer moves the carousel underneath.
    @State private var selection = 0
    @State private var isPresented = false

    /// The square carousel's rect in `.global` screen coordinates. Because every
    /// page fills this same square (`scaledToFill` + clip), this single rect is
    /// the hero source/target for *every* page — so `sourceFrame(selection)`
    /// stays non-nil even after swiping inside the viewer to an off-screen page.
    @State private var carouselFrame: CGRect?

    /// The carousel page index that must stay hidden while the hero (zoom)
    /// transition is in flight, or `nil` when nothing is hidden.
    ///
    /// Set from ``onPhotoSliderSourceVisibilityChange(_:)``: PhotoSlider sends
    /// `(index, isHidden: true)` *before* the present zoom grows (at the start of
    /// presentation), and `(index, isHidden: false)` only *after* the close
    /// animation has fully returned. Driving the page image's `opacity` off this
    /// avoids the "double image" where the still-on-screen carousel thumbnail and
    /// the moving hero image overlap during present/dismiss.
    /// Because every page uses the *same* `carouselFrame`, only the page
    /// matching this index is faded — the one whose square the hero image grows
    /// from / shrinks into.
    @State private var hiddenIndex: Int?

    var body: some View {
        VStack(spacing: 0) {
            squareCarousel
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Carousel")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("carousel")
        // Must be attached *before* `.photoSlider(...)` so it's injected into the
        // presentation path via the environment. PhotoSlider notifies us when to
        // hide (before the present zoom grows) and when to restore (after the
        // close animation has fully settled). Mapping straight to a single
        // `hiddenIndex` keeps the restore correct even if the viewer was swiped to
        // another page before closing: the index passed back on `isHidden == false`
        // is the one we originally hid, so the right thumbnail always reappears.
        .onPhotoSliderSourceVisibilityChange { index, isHidden in
            hiddenIndex = isHidden ? index : nil
        }
        .photoSlider(
            isPresented: $isPresented,
            photos: photos,
            selection: $selection,
            // Every page occupies the same square, so the current page's image
            // rect is always the recorded carousel frame. `nil` only before the
            // carousel has laid out, in which case PhotoSlider cross-fades.
            sourceFrame: { _ in carouselFrame }
        )
    }

    /// The 1:1 square carousel pinned to the top. Its width drives its height so
    /// it stays square across rotation / size classes, mirroring the old UIKit
    /// cell size of `CGSize(width: bounds.width, height: bounds.width)`.
    private var squareCarousel: some View {
        TabView(selection: $selection) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                pageImage(for: photo, at: index)
                    .tag(index)
                    .accessibilityIdentifier("carousel-page-\(index)")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .aspectRatio(1, contentMode: .fit)
        .background(Color.black)
        .background(carouselFrameReader)
    }

    /// A single page: the photo scaled to *fill* the square and clipped, wrapped
    /// in a button that opens PhotoSlider at this index.
    @ViewBuilder
    private func pageImage(for photo: PhotoItem, at index: Int) -> some View {
        Button {
            isPresented = true
        } label: {
            carouselImage(for: photo)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Hide *this* page's thumbnail while it's the hero source/target so it
        // doesn't double up with the moving hero image during present/dismiss.
        // `hiddenIndex` is set/cleared by `onPhotoSliderSourceVisibilityChange`.
        .opacity(hiddenIndex == index ? 0 : 1)
        .accessibilityLabel(photo.caption ?? "Photo")
        .accessibilityHint("Opens the photo full screen")
    }

    /// The page image, scaled to fill the square (centered, edges cropped) so it
    /// covers the whole 1:1 slot — matching the old centered, full-bleed cell.
    @ViewBuilder
    private func carouselImage(for photo: PhotoItem) -> some View {
        if case let .uiImage(image) = photo.source {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Color.gray
        }
    }

    /// Transparent geometry probe behind the whole carousel. It records the
    /// square's `.global` rect (and keeps it current across rotation / safe-area
    /// changes) so the hero transition grows from / shrinks into the square.
    private var carouselFrameReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { carouselFrame = proxy.frame(in: .global) }
                .onChange(of: proxy.frame(in: .global)) { _, newFrame in
                    carouselFrame = newFrame
                }
        }
    }
}

#Preview {
    NavigationStack {
        CarouselDemoView()
    }
}
