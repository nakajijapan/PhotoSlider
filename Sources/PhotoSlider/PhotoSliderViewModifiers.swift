//
//  PhotoSliderViewModifiers.swift
//  PhotoSlider
//

import SwiftUI

#if DEBUG
/// DEBUG-only, process-wide registry used to surface a common ordering mistake: attaching an
/// `.onPhotoSlider*` callback modifier *before* `.photoSlider(...)`. Because the callbacks ride
/// the environment (`transformEnvironment`), a modifier placed before the presentation host is
/// the host's *ancestor's* sibling, never propagates down, and the callback silently never fires.
///
/// `didRegisterAnyCallback` flips `true` the first time *any* callback modifier runs anywhere in
/// the app. If a slider is then presented with an *empty* callback set, the registration must have
/// landed in the wrong place — so we warn once. Genuine callback-free usage never trips this
/// (nothing flips the flag), so it does not mis-warn.
@MainActor
enum PhotoSliderCallbackRegistry {
    static var didRegisterAnyCallback = false
    static var didWarnAboutOrder = false

    /// Emits the ordering warning at most once per process, only when a callback was registered
    /// *somewhere* yet the presented slider sees none of them (the tell-tale of mis-ordering).
    static func warnIfCallbacksLikelyMisordered(presentedCallbacks: PhotoSliderCallbacks) {
        guard didRegisterAnyCallback, presentedCallbacks.isEmpty, !didWarnAboutOrder else { return }
        didWarnAboutOrder = true
        print("[PhotoSlider] Presented with no callbacks, but .onPhotoSlider* modifiers were used elsewhere — attach them AFTER .photoSlider(...) so they propagate via the environment.")
    }
}
#endif

// MARK: - Presentation

private struct PhotoSliderPresentationModifier: ViewModifier {

    @Binding var isPresented: Bool
    let photos: [PhotoItem]
    @Binding var selection: Int
    let configuration: PhotoSliderConfiguration
    let imageLoader: any ImageLoader

    @Environment(\.photoSliderCallbacks) private var callbacks

    func body(content: Content) -> some View {
        #if DEBUG
        if isPresented {
            PhotoSliderCallbackRegistry.warnIfCallbacksLikelyMisordered(presentedCallbacks: callbacks)
        }
        #endif
        return content.fullScreenCover(isPresented: $isPresented) {
            PhotoSliderView(
                photos: photos,
                selection: $selection,
                configuration: configuration,
                imageLoader: imageLoader
            )
            // Re-inject the callbacks so they cross the presentation boundary.
            .environment(\.photoSliderCallbacks, callbacks)
            // The viewer's VC view is `.clear` and its black backdrop fades to 0 on
            // swipe-to-dismiss. Without this, the fullScreenCover's default white
            // hosting background shows through as the cover presents/dismisses,
            // producing a full-screen white flash. Match the viewer's backdrop color
            // so the present/dismiss stays black instead of flashing white.
            .presentationBackground(configuration.backgroundColor)
        }
    }
}

public extension View {

    /// Presents PhotoSlider in a full-screen cover while `isPresented` is `true`.
    ///
    /// Presentation and dismissal use a cross-fade. If you need a thumbnail ⇄ full-screen
    /// hero (zoom) transition, use
    /// ``photoSlider(isPresented:photos:selection:configuration:imageLoader:sourceFrame:)``
    /// with a `sourceFrame`.
    ///
    /// The ``photoSliderCallbacks(_:)`` and individual callback modifiers attached to this view
    /// carry over to the PhotoSlider inside the cover. Because they are read from the environment,
    /// **attach them after (i.e. outside) this modifier** (attaching them before / inside means
    /// they do not propagate to the presentation path).
    ///
    /// - Parameters:
    ///   - isPresented: A Binding that controls the presentation state.
    ///   - photos: The array of photos to display.
    ///   - selection: A Binding to the current page.
    ///   - configuration: Configuration options. Defaults to ``PhotoSliderConfiguration/default``.
    ///   - imageLoader: The image loader. Defaults to ``ImageLoader/default``.
    func photoSlider(
        isPresented: Binding<Bool>,
        photos: [PhotoItem],
        selection: Binding<Int>,
        configuration: PhotoSliderConfiguration = .default,
        imageLoader: any ImageLoader = .default
    ) -> some View {
        modifier(
            PhotoSliderPresentationModifier(
                isPresented: isPresented,
                photos: photos,
                selection: selection,
                configuration: configuration,
                imageLoader: imageLoader
            )
        )
    }

    /// Presents PhotoSlider full-screen while `isPresented` is `true`, presenting and dismissing
    /// with a thumbnail ⇄ full-screen hero (zoom) transition.
    ///
    /// `sourceFrame` is a closure that returns the rectangle the thumbnail at the given index occupies
    /// in **screen coordinates (`.global`)**. On the SwiftUI side, pass the value obtained from
    /// `GeometryReader { proxy in ... proxy.frame(in: .global) }`.
    ///
    /// - On present: The image scales up from the current page's (`selection`) `sourceFrame` to full screen.
    /// - On dismiss: The image shrinks back to the `sourceFrame` of the current page (`selection`) at that moment
    ///   (if you have already swiped to a different page in the viewer, it returns to that page's thumbnail position).
    ///
    /// If `sourceFrame(index)` returns `nil`, an empty rectangle, or an off-screen rectangle, that present/dismiss
    /// falls back to the conventional cross-fade presentation (it does not crash).
    /// If you don't need a hero transition, use
    /// ``photoSlider(isPresented:photos:selection:configuration:imageLoader:)`` without the `sourceFrame` argument.
    ///
    /// The ``photoSliderCallbacks(_:)`` and individual callback modifiers attached to this view also
    /// carry over to the hero presentation path. Because they are read from the environment,
    /// **attach them after (i.e. outside) this modifier** (attaching them before / inside means
    /// they do not propagate to the presentation path).
    ///
    /// ## Example
    ///
    /// Record the frame each thumbnail occupies in screen coordinates (`.global`) and return it from `sourceFrame`.
    ///
    /// ```swift
    /// struct CarouselScreen: View {
    ///     let photos: [PhotoItem]
    ///     @State private var selection = 0
    ///     @State private var isPresented = false
    ///     // Record the frame each index's thumbnail occupies in screen coordinates.
    ///     @State private var frames: [Int: CGRect] = [:]
    ///
    ///     var body: some View {
    ///         TabView(selection: $selection) {
    ///             ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
    ///                 Button { isPresented = true } label: {
    ///                     thumbnail(for: photo)
    ///                 }
    ///                 .background(
    ///                     GeometryReader { proxy in
    ///                         Color.clear
    ///                             .onAppear { frames[index] = proxy.frame(in: .global) }
    ///                             .onChange(of: proxy.frame(in: .global)) { _, new in
    ///                                 frames[index] = new
    ///                             }
    ///                     }
    ///                 )
    ///                 .tag(index)
    ///             }
    ///         }
    ///         .tabViewStyle(.page)
    ///         .photoSlider(
    ///             isPresented: $isPresented,
    ///             photos: photos,
    ///             selection: $selection,
    ///             sourceFrame: { index in frames[index] } // return nil to fall back to a fade
    ///         )
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: A Binding that controls the presentation state.
    ///   - photos: The array of photos to display.
    ///   - selection: A Binding to the current page. It is the **source of truth** for the hero target page on both present and dismiss.
    ///   - configuration: Configuration options. Defaults to ``PhotoSliderConfiguration/default``.
    ///   - imageLoader: The image loader. Defaults to ``ImageLoader/default``.
    ///   - sourceFrame: A provider returning the thumbnail's screen-coordinate frame (`CGRect?`) for an index.
    ///     Return it in the `.global` coordinate space.
    func photoSlider(
        isPresented: Binding<Bool>,
        photos: [PhotoItem],
        selection: Binding<Int>,
        configuration: PhotoSliderConfiguration = .default,
        imageLoader: any ImageLoader = .default,
        sourceFrame: @escaping (Int) -> CGRect?
    ) -> some View {
        modifier(
            PhotoSliderHeroPresentationModifier(
                isPresented: isPresented,
                photos: photos,
                selection: selection,
                configuration: configuration,
                imageLoader: imageLoader,
                sourceFrame: sourceFrame
            )
        )
    }
}

// MARK: - Callbacks

public extension View {

    /// Subscribes to PhotoSlider's events in bulk.
    ///
    /// If called multiple times within the same view tree, the last one wins (it overwrites).
    func photoSliderCallbacks(_ callbacks: PhotoSliderCallbacks) -> some View {
        #if DEBUG
        PhotoSliderCallbackRegistry.didRegisterAnyCallback = true
        #endif
        return environment(\.photoSliderCallbacks, callbacks)
    }

    /// Registers a closure called when the page changes.
    func onPhotoSliderPageChanged(
        _ action: @escaping @MainActor @Sendable (Int) -> Void
    ) -> some View {
        #if DEBUG
        PhotoSliderCallbackRegistry.didRegisterAnyCallback = true
        #endif
        return transformEnvironment(\.photoSliderCallbacks) { $0.onPageChanged = action }
    }

    /// Registers a closure called just before dismissal.
    func onPhotoSliderWillDismiss(
        _ action: @escaping @MainActor @Sendable () -> Void
    ) -> some View {
        #if DEBUG
        PhotoSliderCallbackRegistry.didRegisterAnyCallback = true
        #endif
        return transformEnvironment(\.photoSliderCallbacks) { $0.onWillDismiss = action }
    }

    /// Registers a closure called after dismissal completes.
    func onPhotoSliderDidDismiss(
        _ action: @escaping @MainActor @Sendable () -> Void
    ) -> some View {
        #if DEBUG
        PhotoSliderCallbackRegistry.didRegisterAnyCallback = true
        #endif
        return transformEnvironment(\.photoSliderCallbacks) { $0.onDidDismiss = action }
    }

    /// Registers a closure called when the share button is tapped.
    func onPhotoSliderShare(
        _ action: @escaping @MainActor @Sendable (PhotoItem) -> Void
    ) -> some View {
        #if DEBUG
        PhotoSliderCallbackRegistry.didRegisterAnyCallback = true
        #endif
        return transformEnvironment(\.photoSliderCallbacks) { $0.onShare = action }
    }

    /// Registers an async closure called when deletion is requested. Returning `true` is treated as confirming the deletion.
    func onPhotoSliderRequestDelete(
        _ action: @escaping @MainActor @Sendable (PhotoItem) async -> Bool
    ) -> some View {
        #if DEBUG
        PhotoSliderCallbackRegistry.didRegisterAnyCallback = true
        #endif
        return transformEnvironment(\.photoSliderCallbacks) { $0.onRequestDelete = action }
    }

    /// Registers a closure to toggle the visibility of the caller's source thumbnail during the hero (zoom) transition.
    ///
    /// In a hero transition, the image scales up from the tapped thumbnail's position to the full-screen viewer.
    /// At that moment the caller's source thumbnail (such as a carousel's page image) stays on screen, so it
    /// overlaps the moving hero image and produces a **double image**. This modifier signals the timing for when
    /// to "hide / restore", and leaves the actual visibility toggle (`opacity`, etc.) to the caller.
    ///
    /// - `(index, isHidden: true)` is called **once**, **before the present zoom-in (at the start of presentation)**.
    ///   This way the hero image scales up from an empty thumbnail position from the start, preventing the source
    ///   thumbnail from peeking out beneath the hero image mid-scale and producing a double image.
    /// - `(index, isHidden: false)` is called **once**, after dismissal completes (after the shrink animation has fully returned).
    ///   This `index` is the **same index** that was hidden at present time. Even if the viewer is closed after
    ///   swiping to a different page, the originally hidden thumbnail is always restored (it never stays hidden).
    ///
    /// It fires only when the hero path is established via
    /// ``photoSlider(isPresented:photos:selection:configuration:imageLoader:sourceFrame:)`` with a `sourceFrame`.
    /// It is **not called** for the cross-fade presentation of
    /// ``photoSlider(isPresented:photos:selection:configuration:imageLoader:)`` without `sourceFrame`, or for a
    /// presentation that fell back to a fade because `sourceFrame(index)` was `nil`, an empty rectangle, or off-screen
    /// (because no hero image exists and no double image occurs).
    ///
    /// Registration is optional (opt-in). Present/dismiss behavior is unchanged if you don't register it
    /// (in that case the double image during the transition remains).
    ///
    /// > Important: Attach this modifier **after** `photoSlider(...)`.
    /// > An environment value set with `transformEnvironment` only flows to the **descendants** of the view it is attached to.
    /// > Because `photoSlider(...)` internally holds a presentation host (which reads this callback from the environment),
    /// > attaching this modifier **before** (i.e. inside) `photoSlider(...)` makes the presentation host look up the
    /// > callback from its own **ancestor**, where it is `nil` (so the callback never fires).
    /// > Attaching it **after** (i.e. outside) `photoSlider(...)` makes it an ancestor of the presentation host, so it propagates correctly.
    ///
    /// ## Example
    ///
    /// Toggle a single `hiddenIndex` State with `isHidden ? index : nil` to make the target page's thumbnail transparent.
    ///
    /// ```swift
    /// struct CarouselScreen: View {
    ///     let photos: [PhotoItem]
    ///     @State private var selection = 0
    ///     @State private var isPresented = false
    ///     @State private var frames: [Int: CGRect] = [:]
    ///     // The page index to hide during the hero transition (nil if there is nothing to hide).
    ///     @State private var hiddenIndex: Int?
    ///
    ///     var body: some View {
    ///         TabView(selection: $selection) {
    ///             ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
    ///                 Button {
    ///                     // Hide this page immediately and synchronously on tap (so it reliably disappears before the zoom-in).
    ///                     hiddenIndex = index
    ///                     isPresented = true
    ///                 } label: {
    ///                     thumbnail(for: photo)
    ///                 }
    ///                 // Make this page's thumbnail transparent during the transition to prevent a double image.
    ///                 .opacity(hiddenIndex == index ? 0 : 1)
    ///                 .tag(index)
    ///             }
    ///         }
    ///         .tabViewStyle(.page)
    ///         .photoSlider(
    ///             isPresented: $isPresented,
    ///             photos: photos,
    ///             selection: $selection,
    ///             sourceFrame: { index in frames[index] }
    ///         )
    ///         // Attach after photoSlider(...) (so it becomes an ancestor of the presentation host and propagates).
    ///         .onPhotoSliderSourceVisibilityChange { _, isHidden in
    ///             // Dismiss complete: restore with (index, false) (hiding was already done on tap).
    ///             if !isHidden { hiddenIndex = nil }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// > Note: It is recommended to hide **synchronously yourself on tap** and restore with the library's
    /// > `(index, isHidden: false)` (same as CarouselDemoView). `(index, isHidden: true)` arrives just before present
    /// > (the tick after the tap), so relying on it to hide is delayed by one frame, during which the thumbnail and
    /// > hero image can show a **double image**.
    ///
    /// - Parameter action: A closure that toggles the visibility state. The first argument is the target thumbnail's index;
    ///   the second argument `isHidden` hides when `true` (before the present zoom-in) and restores when `false` (after dismissal completes).
    func onPhotoSliderSourceVisibilityChange(
        _ action: @escaping @MainActor @Sendable (_ index: Int, _ isHidden: Bool) -> Void
    ) -> some View {
        #if DEBUG
        PhotoSliderCallbackRegistry.didRegisterAnyCallback = true
        #endif
        return transformEnvironment(\.photoSliderCallbacks) { $0.onSourceVisibilityChange = action }
    }
}
