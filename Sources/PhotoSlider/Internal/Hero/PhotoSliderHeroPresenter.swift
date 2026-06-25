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

            // Resolve the source frame for the page being presented (the truth source).
            let presentFrame = resolvedThumbnail(
                forIndex: selection,
                photos: photos,
                window: window,
                sourceFrame: sourceFrame
            )

            if let presentFrame {
                // Hero path: keep a strong reference to the delegate (it is `weak` on the VC).
                let delegate = PhotoSliderZoomTransitioningDelegate(
                    viewer: viewer,
                    presentThumbnail: presentFrame,
                    dismissThumbnailProvider: { [weak self, weak window] in
                        guard let self, let window else { return nil }
                        return self.resolvedThumbnail(
                            forIndex: self.selection,
                            photos: photos,
                            window: window,
                            sourceFrame: sourceFrame
                        )
                    }
                )
                transitioningDelegate = delegate
                viewer.transitioningDelegate = delegate
            } else {
                // Fallback: no valid source frame -> plain cross-dissolve, no white backdrop.
                transitioningDelegate = nil
                viewer.modalTransitionStyle = .crossDissolve
            }

            presentedViewer = viewer
            presenter.present(viewer, animated: true) { [weak self] in
                self?.isPresenting = false
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

            viewer.dismiss(animated: animated) { [weak self] in
                self?.presentedViewer = nil
                self?.transitioningDelegate = nil
                self?.isDismissing = false
            }
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
