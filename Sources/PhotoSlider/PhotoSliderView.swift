//
//  PhotoSliderView.swift
//  PhotoSlider
//

import SwiftUI

/// A SwiftUI view that displays multiple photos full-screen with paging.
///
/// Horizontal swipe to page, vertical swipe to dismiss full-screen, and pinch / double-tap to
/// zoom feel exactly like v1.5.0 (UIKit) — internally it reuses the proven `UIScrollView`
/// engine.
///
/// Place it directly inside your own `.fullScreenCover` / `.sheet`, or present it using the
/// ``SwiftUICore/View/photoSlider(isPresented:photos:selection:configuration:imageLoader:)``
/// modifier.
///
/// ```swift
/// .photoSlider(isPresented: $isPresented, photos: photos, selection: $index)
/// ```
@MainActor
public struct PhotoSliderView: View {

    private let photos: [PhotoItem]
    @Binding private var selection: Int
    private let configuration: PhotoSliderConfiguration
    private let imageLoader: any ImageLoader

    @Environment(\.dismiss) private var dismiss
    @Environment(\.photoSliderCallbacks) private var callbacks

    /// Creates a PhotoSlider.
    ///
    /// - Parameters:
    ///   - photos: The array of photos to display. An empty array still initializes successfully, but the view renders empty.
    ///   - selection: The index of the currently displayed page. Out-of-range values are clamped to the nearest valid index.
    ///   - configuration: Appearance and behavior options. Defaults to ``PhotoSliderConfiguration/default``.
    ///   - imageLoader: The loader that fetches images. Defaults to ``ImageLoader/default`` (`URLSession`-based).
    public init(
        photos: [PhotoItem],
        selection: Binding<Int>,
        configuration: PhotoSliderConfiguration = .default,
        imageLoader: any ImageLoader = .default
    ) {
        self.photos = photos
        self._selection = selection
        self.configuration = configuration
        self.imageLoader = imageLoader
    }

    public var body: some View {
        // Lay an opaque backdrop *behind* the viewer. The VC's own view is `UIColor.clear`,
        // so when callers place `PhotoSliderView` directly inside a `.sheet` /
        // `.fullScreenCover`, the host's default white background would otherwise show
        // through and flash white as the cover presents / dismisses. Making the view itself
        // opaque keeps the present / dismiss black instead of flashing white.
        ZStack {
            configuration.backgroundColor.ignoresSafeArea()
            PhotoSliderControllerRepresentable(
                items: photos,
                selection: $selection,
                configuration: configuration,
                imageLoader: imageLoader,
                callbacks: callbacks,
                onRequestDismiss: { dismiss() }
            )
            .ignoresSafeArea()
        }
        .statusBarHidden(true)
    }
}

#if DEBUG
private struct PhotoSliderPreviewHost: View {
    @State private var selection = 0

    private let photos: [PhotoItem] = {
        let colors: [UIColor] = [.systemIndigo, .systemTeal, .systemPink]
        return colors.enumerated().map { index, color in
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 1600))
            let image = renderer.image { context in
                color.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 1200, height: 1600))
            }
            return PhotoItem(source: .uiImage(image), caption: "Sample \(index + 1)")
        }
    }()

    var body: some View {
        PhotoSliderView(photos: photos, selection: $selection)
    }
}

#Preview {
    PhotoSliderPreviewHost()
}
#endif
