//
//  PhotoSliderHeroPresenter.swift
//  PhotoSlider
//
//  Invisible SwiftUI bridge that presents `PhotoSliderViewController` directly with UIKit
//  (instead of `.fullScreenCover`) so the hero zoom transition can drive it. Keeps the
//  presentation in sync with the `isPresented` binding and funnels every present/dismiss
//  through a single Coordinator to prevent double-present / double-dismiss.
//

import SwiftUI
import UIKit

struct PhotoSliderHeroPresenter: UIViewRepresentable {

    @Binding var isPresented: Bool
    let photos: [PhotoItem]
    @Binding var selection: Int
    let configuration: PhotoSliderConfiguration
    let imageLoader: any ImageLoader
    let callbacks: PhotoSliderCallbacks
    let sourceFrame: (Int) -> CGRect?

    func makeCoordinator() -> Coordinator {
        Coordinator(
            isPresented: $isPresented,
            selection: $selection
        )
    }

    func makeUIView(context: Context) -> BridgeView {
        let view = BridgeView()
        view.isUserInteractionEnabled = false
        view.isHidden = false
        return view
    }

    func updateUIView(_ uiView: BridgeView, context: Context) {
        context.coordinator.update(
            from: uiView,
            isPresented: isPresented,
            photos: photos,
            selection: selection,
            configuration: configuration,
            imageLoader: imageLoader,
            callbacks: callbacks,
            sourceFrame: sourceFrame
        )
    }

    // MARK: - Bridge UIView

    /// A zero-size, non-interactive view used only to discover the presenter view controller
    /// from the live UIKit hierarchy. It never draws anything.
    final class BridgeView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    // MARK: - Coordinator

    @MainActor
    final class Coordinator {

        @Binding private var isPresented: Bool
        @Binding private var selection: Int

        /// Currently presented viewer (strong) and its transitioning delegate (strong --
        /// `transitioningDelegate` is `weak`, so without this it would be deallocated before
        /// the animation runs and UIKit would fall back to a fade).
        private var presentedViewer: PhotoSliderViewController?
        private var transitioningDelegate: PhotoSliderZoomTransitioningDelegate?

        /// Guards the present/dismiss entry points so each runs at most once per cycle.
        private var isPresenting = false
        private var isDismissing = false

        /// The source index hidden when the hero path was taken on present, or `nil` when no
        /// thumbnail was hidden (fade fallback / no source-visibility callback registered).
        /// Doubles as the "did we hide something?" flag for the dismiss-completion notification.
        private var hiddenSourceIndex: Int?

        /// The visibility callback captured at present time, retained so dismiss completion can
        /// restore the *same* thumbnail that was hidden (the present-time callback may differ
        /// from the latest one re-injected via the environment by dismiss time).
        private var sourceVisibilityChange: (@MainActor @Sendable (Int, Bool) -> Void)?

        /// The freshest `sourceFrame` / `selection` from the most recent `update(...)`. The
        /// present is deferred one runloop tick (see `presentIfNeeded`), by which point a later
        /// `update(...)` may have delivered a newer (non-`nil`) source frame; resolving against
        /// these avoids reading the stale value captured in the pass that triggered the present.
        private var latestSourceFrame: ((Int) -> CGRect?)?
        private var latestSelection: Int?

        /// The window-space frame the present hero actually grew from. Reused as the dismiss
        /// return target *only* when the live `sourceFrame` momentarily returns `nil` at dismiss
        /// time -- while the viewer is presented `.overFullScreen` the carousel's
        /// `GeometryReader` can be detached, so `update(...)` is not re-run with a fresh frame
        /// and the live provider would otherwise yield `nil` and fall back to a fade. The live
        /// provider is still tried first, so swiping to another page returns to that page.
        private var lastResolvedPresentFrame: CGRect?

        init(isPresented: Binding<Bool>, selection: Binding<Int>) {
            _isPresented = isPresented
            _selection = selection
        }

        func update(
            from bridgeView: PhotoSliderHeroPresenter.BridgeView,
            isPresented: Bool,
            photos: [PhotoItem],
            selection: Int,
            configuration: PhotoSliderConfiguration,
            imageLoader: any ImageLoader,
            callbacks: PhotoSliderCallbacks,
            sourceFrame: @escaping (Int) -> CGRect?
        ) {
            // Keep the freshest source-frame provider / page for the deferred present read.
            latestSourceFrame = sourceFrame
            latestSelection = selection

            if isPresented {
                presentIfNeeded(
                    from: bridgeView,
                    photos: photos,
                    selection: selection,
                    configuration: configuration,
                    imageLoader: imageLoader,
                    callbacks: callbacks,
                    sourceFrame: sourceFrame
                )
                syncExternalPage(selection)
            } else {
                dismissIfNeeded()
            }
        }

        // MARK: Present

        private func presentIfNeeded(
            from bridgeView: PhotoSliderHeroPresenter.BridgeView,
            photos: [PhotoItem],
            selection: Int,
            configuration: PhotoSliderConfiguration,
            imageLoader: any ImageLoader,
            callbacks: PhotoSliderCallbacks,
            sourceFrame: @escaping (Int) -> CGRect?
        ) {
            // Single entry point: skip if a viewer is already up or a present is in flight.
            guard presentedViewer == nil, !isPresenting else { return }
            // Window not attached yet -> retry on the next `updateUIView`.
            guard let presenter = bridgeView.presenter, let window = bridgeView.window else { return }

            isPresenting = true

            let viewer = PhotoSliderViewController(
                items: photos,
                configuration: configuration,
                imageLoader: imageLoader,
                initialPage: selection
            )
            viewer.modalPresentationStyle = .overFullScreen

            configureCallbacks(on: viewer, callbacks: callbacks)
            presentedViewer = viewer

            // Defer the source-frame resolution and the actual present to the next runloop tick.
            //
            // `updateUIView` runs *inside* SwiftUI's layout/update pass. When `isPresented`
            // flips to true (e.g. a thumbnail tap), the `sourceFrame` closure captured for this
            // very pass can still read a *stale* value (commonly `nil`) for a frame that a
            // sibling `GeometryReader` only just produced -- so `resolvedThumbnail` returns
            // `nil` and presentation silently falls back to a cross-dissolve. Hopping to the
            // next main-runloop tick lets SwiftUI commit the freshest `carouselFrame` before we
            // read it, and lets UIKit run the custom hero transition cleanly outside the layout
            // pass. `latestSourceFrame`/`latestSelection` are kept current by every `update(...)`.
            DispatchQueue.main.async { [weak self, weak viewer, weak window] in
                guard let self, let viewer, let window else { return }
                let sourceFrame = self.latestSourceFrame ?? sourceFrame
                let page = self.latestSelection ?? selection

                let presentFrame = self.resolvedThumbnail(
                    forIndex: page,
                    photos: photos,
                    window: window,
                    sourceFrame: sourceFrame
                )

                if let presentFrame {
                    self.lastResolvedPresentFrame = presentFrame.windowFrame
                    // Hero path: keep a strong reference to the delegate (it is `weak` on the VC).
                    let delegate = PhotoSliderZoomTransitioningDelegate(
                        viewer: viewer,
                        presentThumbnail: presentFrame,
                        dismissThumbnailProvider: { [weak self, weak window] in
                            guard let self, let window else { return nil }
                            let sf = self.latestSourceFrame ?? sourceFrame
                            // Prefer the live frame for the current page (so swiping returns to
                            // that page). If it is momentarily `nil` -- the carousel can be
                            // detached while presented `.overFullScreen`, so `update(...)` is not
                            // re-run with a fresh frame -- fall back to the frame the present grew
                            // from so dismissal still zooms back instead of fading.
                            if let resolved = self.resolvedThumbnail(
                                forIndex: self.selection,
                                photos: photos,
                                window: window,
                                sourceFrame: sf
                            ) {
                                return resolved
                            }
                            guard let cached = self.lastResolvedPresentFrame else { return nil }
                            let image = photos.indices.contains(self.selection)
                                ? self.synchronousImage(for: photos[self.selection])
                                : nil
                            return PhotoSliderThumbnailTransition(image: image, windowFrame: cached)
                        }
                    )
                    // Restore the caller's thumbnail the instant the dismiss shrink animation
                    // lands (inside the zoom controller's animation completion), rather than
                    // waiting for UIKit's post-dismiss completion -- otherwise an empty slot is
                    // visible between landing and the thumbnail re-appearing. Idempotent, so the
                    // dismiss-completion fallback below does not double-fire.
                    delegate.onDismissLanded = { [weak self] in self?.restoreSourceIfNeeded() }
                    self.transitioningDelegate = delegate
                    viewer.transitioningDelegate = delegate

                    // Hero path only: remember the index + callback so dismiss completion can
                    // restore the *same* thumbnail (even if the viewer swiped pages). `page` is the
                    // index the present frame was resolved for.
                    self.hiddenSourceIndex = page
                    self.sourceVisibilityChange = callbacks.onSourceVisibilityChange
                    // Hide the caller's source thumbnail *before* the zoom grows, so the moving
                    // hero image starts from an already-empty square instead of revealing the
                    // thumbnail underneath it as it expands. This fires in the deferred block (the
                    // next runloop tick, *outside* `updateUIView`), so mutating the caller's
                    // `@State` here does not trigger "Modifying state during view update" and does
                    // not disturb the hero zoom.
                    self.sourceVisibilityChange?(page, true)
                } else {
                    // Fallback: no valid source frame -> plain cross-dissolve, no white backdrop.
                    // No thumbnail is hidden, so dismiss must not emit a "restore" notification.
                    // Clear any stale hero state so dismiss completion does not restore a thumbnail.
                    self.transitioningDelegate = nil
                    viewer.modalTransitionStyle = .crossDissolve
                    self.hiddenSourceIndex = nil
                    self.sourceVisibilityChange = nil
                }

                presenter.present(viewer, animated: true) { [weak self] in
                    self?.isPresenting = false
                }
            }
        }

        private func configureCallbacks(
            on viewer: PhotoSliderViewController,
            callbacks: PhotoSliderCallbacks
        ) {
            viewer.onPageChanged = { [weak self] page in
                self?.selection = page
                callbacks.onPageChanged?(page)
            }
            viewer.onWillDismiss = { callbacks.onWillDismiss?() }
            viewer.onDidDismiss = { callbacks.onDidDismiss?() }
            viewer.onShare = { item in callbacks.onShare?(item) }
            viewer.onLongPress = nil
            // Close button / swipe-to-dismiss route back through `isPresented` so present and
            // dismiss share one path (calling `dismiss()` here too would double-dismiss).
            viewer.onRequestDismiss = { [weak self] in
                self?.isPresented = false
            }
        }

        // MARK: External page sync

        /// Mirrors the representable's behaviour: when `selection` changes externally while
        /// the viewer is up, scroll the viewer to that page.
        private func syncExternalPage(_ selection: Int) {
            guard let viewer = presentedViewer, !isPresenting else { return }
            if selection != viewer.currentPage {
                viewer.scrollToPage(selection, animated: true)
            }
        }

        // MARK: Dismiss

        private func dismissIfNeeded() {
            // Single entry point: only dismiss a viewer we presented, and only once.
            guard let viewer = presentedViewer, !isDismissing else { return }
            isDismissing = true

            // Swipe-to-dismiss already ran the viewer's own 0.4s slide-out to `view.alpha == 0`,
            // so dismiss it *without* an animated transition. Animating here would re-run the
            // hero zoom-out, which resets `view.alpha` back to 1.0 and briefly re-reveals the
            // blur + black background. Close-button / tap dismissal keeps the hero zoom-out.
            let animated = !viewer.isDismissingViaSwipe

            // The completion runs for both `animated` and non-animated (swipe) dismissals, so
            // restoring the hidden thumbnail here guarantees it always comes back, only once,
            // and only after the zoom-out animation has fully settled.
            viewer.dismiss(animated: animated) { [weak self] in
                guard let self else { return }
                self.presentedViewer = nil
                self.transitioningDelegate = nil
                self.lastResolvedPresentFrame = nil
                self.isDismissing = false

                // Fallback restore: the hero (animated) path already restored at landing via
                // `onDismissLanded`, so this is a no-op there. The swipe (non-animated) path has
                // no landing hook, so it restores here. Idempotent -> always exactly once.
                self.restoreSourceIfNeeded()
            }
        }

        /// Restores the caller's hidden source thumbnail exactly once. Safe to call from both the
        /// dismiss landing hook and the dismiss completion -- after the first call `hiddenSourceIndex`
        /// is cleared, so subsequent calls are no-ops (no double reveal).
        private func restoreSourceIfNeeded() {
            guard let index = hiddenSourceIndex else { return }
            sourceVisibilityChange?(index, false)
            hiddenSourceIndex = nil
            sourceVisibilityChange = nil
        }

        // MARK: Thumbnail resolution

        /// Resolves the hero thumbnail (image + window-space frame) for `index`, or `nil` when
        /// the source frame is missing / empty / off-screen (fade fallback).
        private func resolvedThumbnail(
            forIndex index: Int,
            photos: [PhotoItem],
            window: UIWindow,
            sourceFrame: (Int) -> CGRect?
        ) -> PhotoSliderThumbnailTransition? {
            guard photos.indices.contains(index) else { return nil }

            let global = sourceFrame(index)
            guard
                let resolved = PhotoSliderHeroResolver.resolvedWindowFrame(
                    global: global,
                    in: window.bounds
                )
            else {
                return nil
            }

            return PhotoSliderThumbnailTransition(
                image: synchronousImage(for: photos[index]),
                windowFrame: resolved
            )
        }

        /// Best-effort synchronous image for the moving hero view at present time. Remote
        /// sources have no in-memory image yet, so they animate the frame only (the viewer
        /// fades in behind); on dismiss the moving view comes from the loaded viewer image.
        private func synchronousImage(for item: PhotoItem) -> UIImage? {
            switch item.source {
            case .uiImage(let image):
                return image
            case .data(let data):
                return UIImage(data: data)
            case .remote:
                return nil
            }
        }
    }
}

// MARK: - Presenter discovery

private extension UIView {

    /// The view controller to present from: the frontmost presented controller reachable from
    /// the window's `rootViewController`, falling back to the nearest controller in the
    /// responder chain.
    var presenter: UIViewController? {
        if let root = window?.rootViewController {
            return root.frontmostPresentedViewController
        }
        return nearestViewController
    }

    var nearestViewController: UIViewController? {
        var responder: UIResponder? = next
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
}

private extension UIViewController {

    /// Walks `presentedViewController` to the deepest (frontmost) controller.
    var frontmostPresentedViewController: UIViewController {
        var controller = self
        while let presented = controller.presentedViewController {
            controller = presented
        }
        return controller
    }
}
