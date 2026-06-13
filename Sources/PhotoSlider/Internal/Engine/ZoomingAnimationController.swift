//
//  ZoomingAnimationController.swift
//  PhotoSlider
//
//  Ported from v1.5.0. Kept internal to preserve the hero (thumbnail <-> fullscreen)
//  zoom transition capability. It is NOT wired into the default SwiftUI presentation
//  in v2.0 (which uses `.fullScreenCover`); a future minor can expose a custom
//  presentation path that drives this controller.
//

import UIKit

@MainActor
protocol ZoomingAnimationControllerTransitioning {
    func transitionSourceImageView() -> UIImageView
    func transitionDestinationImageView(sourceImageView: UIImageView)
}

@MainActor
final class ZoomingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private let present: Bool
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
