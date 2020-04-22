//
//  ZoomingAnimationController.swift
//  Pods
//
//  Created by nakajijapan on 2015/09/13.
//
//

import UIKit

public protocol ZoomingAnimationControllerTransitioning {
    func transitionSourceImageView() -> UIImageView
    func transitionDestinationImageView(sourceImageView: UIImageView)
}

public class ZoomingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var present = true
    public var sourceTransition: ZoomingAnimationControllerTransitioning?
    public var destinationTransition: ZoomingAnimationControllerTransitioning?

    public init(present: Bool) {
        super.init()
        self.present = present
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        if self.present {
            self.animatePresenting(transitionContext: transitionContext)
        } else {
            self.animateDismiss(transitionContext: transitionContext)
        }
    }

    func animatePresenting(transitionContext: UIViewControllerContextTransitioning) {

        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView

        guard let photoSliderViewController = toViewController as? ViewController else {
            return
        }

        let scrollView = photoSliderViewController.scrollView
        scrollView.alpha = 0.0

        let captionBackgroundView = photoSliderViewController.captionBackgroundView
        captionBackgroundView.alpha = 0.0

        let closeButton = photoSliderViewController.closeButton
        closeButton.alpha = 0.0

        let shareButton = photoSliderViewController.shareButton
        shareButton.alpha = 0.0

        containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0.0

        let sourceImageView = sourceTransition!.transitionSourceImageView()
        containerView.addSubview(sourceImageView)

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0.0,
            options: UIView.AnimationOptions.curveEaseOut,
            animations: { () -> Void in
                containerView.alpha = 1.0
                self.destinationTransition!.transitionDestinationImageView(sourceImageView: sourceImageView)
                toViewController.view.alpha = 1.0

        }, completion: { _ -> Void in
            sourceImageView.alpha = 0.0
            sourceImageView.removeFromSuperview()
            scrollView.alpha = 1.0
            toViewController.view.alpha = 1.0

            UIView.animate(withDuration: 0.15, animations: {
                captionBackgroundView.alpha = 1.0
                closeButton.alpha = 1.0
                shareButton.alpha = 1.0
            }, completion: { _ in
                captionBackgroundView.alpha = 1.0
                closeButton.alpha = 1.0
                shareButton.alpha = 1.0
            })

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })

    }

    func animateDismiss(transitionContext: UIViewControllerContextTransitioning) {

        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let containerView = transitionContext.containerView

        containerView.addSubview(fromViewController.view)

        let sourceImageView = self.sourceTransition!.transitionSourceImageView()
        containerView.addSubview(sourceImageView)

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0.0,
            options: UIView.AnimationOptions.curveLinear,
            animations: { () -> Void in
                self.destinationTransition!.transitionDestinationImageView(sourceImageView: sourceImageView)
                fromViewController.view.alpha = 0.0
        },
            completion: { _ -> Void in
                sourceImageView.alpha = 0.0
                sourceImageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
