//
//  PhotoSliderZoomTransitioningDelegate.swift
//  PhotoSlider
//
//  Bridges UIKit's `UIViewControllerTransitioningDelegate` to the v1.5.0
//  `ZoomingAnimationController`, wiring the caller's thumbnail (source frame + image) and the
//  viewer (`PhotoSliderViewController`) as the source / destination of the hero zoom.
//
//  IMPORTANT: `UIViewController.transitioningDelegate` is `weak`. The presenter bridge's
//  Coordinator MUST keep a strong reference to an instance of this type for the duration of
//  the presentation, otherwise it is deallocated before the animation runs and UIKit silently
//  falls back to a fade (the single most common bug in this area).
//

import UIKit

@MainActor
final class PhotoSliderZoomTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    /// The thumbnail to grow from on present. Resolved (image + window-space frame) once at
    /// present time by the bridge.
    private let presentThumbnail: PhotoSliderThumbnailTransition

    /// Re-evaluates the thumbnail to shrink back to at dismiss time, using the current page as
    /// the source of truth (`selection`). Returning `nil` here means "no valid return target"
    /// so dismissal falls back to a fade.
    private let dismissThumbnailProvider: () -> PhotoSliderThumbnailTransition?

    /// The viewer being presented. Plays the `destination` role on present (fullscreen centre
    /// frame) and the `source` role on dismiss (current page's UIImageView).
    private weak var viewer: PhotoSliderViewController?

    init(
        viewer: PhotoSliderViewController,
        presentThumbnail: PhotoSliderThumbnailTransition,
        dismissThumbnailProvider: @escaping () -> PhotoSliderThumbnailTransition?
    ) {
        self.viewer = viewer
        self.presentThumbnail = presentThumbnail
        self.dismissThumbnailProvider = dismissThumbnailProvider
        super.init()
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let viewer else { return nil }
        let controller = ZoomingAnimationController(present: true)
        controller.sourceTransition = presentThumbnail
        controller.destinationTransition = viewer
        return controller
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let viewer, let dismissThumbnail = dismissThumbnailProvider() else {
            // No valid return target (e.g. swiped to a page whose thumbnail is off-screen):
            // returning `nil` lets UIKit dismiss with its default fade.
            return nil
        }
        let controller = ZoomingAnimationController(present: false)
        controller.sourceTransition = viewer
        controller.destinationTransition = dismissThumbnail
        return controller
    }
}
