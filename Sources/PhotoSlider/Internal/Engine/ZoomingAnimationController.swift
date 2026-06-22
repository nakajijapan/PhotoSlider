//
//  ZoomingAnimationController.swift
//  PhotoSlider
//
//  Ported from v1.5.0. Kept internal to drive the hero (thumbnail <-> fullscreen) zoom
//  transition. As of v2.0 it is wired into the `photoSlider(...:sourceFrame:)` overload via
//  `PhotoSliderZoomTransitioningDelegate`, which presents `PhotoSliderViewController`
//  directly with UIKit (`.overFullScreen`) so that `.to` / `.from` cast to
//  `PhotoSliderViewController` here. (The default `sourceFrame`-less overload still uses
//  `.fullScreenCover` and does not run this controller -- it would not satisfy the cast.)
//

import UIKit

@MainActor
protocol ZoomingAnimationControllerTransitioning {
    func transitionSourceImageView() -> UIImageView
    func transitionDestinationImageView(sourceImageView: UIImageView)
}

@MainActor
final class ZoomingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    /// `true` when this controller drives the presenting animation, `false` for dismissal.
    /// Exposed (internal, read-only) so the transitioning delegate's factory branches can be
    /// asserted in unit tests without running a real transition.
    let present: Bool
    var sourceTransition: ZoomingAnimationControllerTransitioning?
    var destinationTransition: ZoomingAnimationControllerTransitioning?

    init(present: Bool) {
        self.present = present
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if present {
            animatePresenting(transitionContext: transitionContext)
        } else {
            animateDismiss(transitionContext: transitionContext)
        }
    }

    private func animatePresenting(transitionContext: UIViewControllerContextTransitioning) {

        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let photoSliderViewController = toViewController as? PhotoSliderViewController,
            let sourceTransition,
            let destinationTransition
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        photoSliderViewController.setChromeHiddenForHeroTransition()

        containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0.0

        let sourceImageView = sourceTransition.transitionSourceImageView()
        containerView.addSubview(sourceImageView)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                containerView.alpha = 1.0
                destinationTransition.transitionDestinationImageView(sourceImageView: sourceImageView)
                toViewController.view.alpha = 1.0
            },
            completion: { _ in
                sourceImageView.alpha = 0.0
                sourceImageView.removeFromSuperview()
                photoSliderViewController.revealContentForHeroTransition()
                toViewController.view.alpha = 1.0

                UIView.animate(withDuration: 0.15) {
                    photoSliderViewController.revealChromeForHeroTransition()
                }

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }

    private func animateDismiss(transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let sourceTransition,
            let destinationTransition
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(fromViewController.view)

        let sourceImageView = sourceTransition.transitionSourceImageView()
        containerView.addSubview(sourceImageView)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveLinear,
            animations: {
                destinationTransition.transitionDestinationImageView(sourceImageView: sourceImageView)
                fromViewController.view.alpha = 0.0
            },
            completion: { _ in
                sourceImageView.alpha = 0.0
                sourceImageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
