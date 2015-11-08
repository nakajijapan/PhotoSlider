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
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.2
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if self.present {
            self.animatePresenting(transitionContext)
        } else {
            self.animateDismiss(transitionContext)
        }
    }
    
    func animatePresenting(transitionContext:UIViewControllerContextTransitioning) {

        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!

        let snapshotView = fromViewController.view.resizableSnapshotViewFromRect(fromViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
        containerView.addSubview(snapshotView)
        
        toViewController.view.alpha = 0.0
        containerView.addSubview(toViewController.view)
        
        
        let backgroundView = UIView(frame: fromViewController.view.frame)
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.alpha = 0.0
        containerView.addSubview(backgroundView)
        
        let sourceImageView = self.sourceTransition!.transitionSourceImageView()
        containerView.addSubview(sourceImageView)


        UIView.animateWithDuration(
            self.transitionDuration(transitionContext),
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                
                self.destinationTransition!.transitionDestinationImageView(sourceImageView)
                backgroundView.alpha = 1.0

            }) { (result) -> Void in
                
                sourceImageView.alpha = 0.0
                sourceImageView.removeFromSuperview()
                
                toViewController.view.alpha = 1.0
                backgroundView.removeFromSuperview()
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())

        }
        
    }
    
    func animateDismiss(transitionContext:UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        let sourceImageView = self.sourceTransition!.transitionSourceImageView()
        containerView.addSubview(sourceImageView)

        UIView.animateWithDuration(
            self.transitionDuration(transitionContext),
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                
                self.destinationTransition!.transitionDestinationImageView(sourceImageView)
                fromViewController.view.alpha = 0.1
                
            }) { (result) -> Void in
                
                sourceImageView.alpha = 0.0
                fromViewController.view.alpha = 0.0

                sourceImageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                
        }
    }

}
