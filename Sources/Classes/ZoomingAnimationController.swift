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
    func transitionDestinationImageView(_ sourceImageView: UIImageView)
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
        return 0.2
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if self.present {
            self.animatePresenting(transitionContext)
        } else {
            self.animateDismiss(transitionContext)
        }
    }
    
    func animatePresenting(_ transitionContext:UIViewControllerContextTransitioning) {

        let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()

        let snapshotView = fromViewController.view.resizableSnapshotView(from: fromViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
        containerView.addSubview(snapshotView!)
        
        toViewController.view.alpha = 0.0
        containerView.addSubview(toViewController.view)
        
        
        let backgroundView = UIView(frame: fromViewController.view.frame)
        backgroundView.backgroundColor = UIColor.black()
        backgroundView.alpha = 0.0
        containerView.addSubview(backgroundView)
        
        let sourceImageView = self.sourceTransition!.transitionSourceImageView()
        containerView.addSubview(sourceImageView)


        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseOut,
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
    
    func animateDismiss(_ transitionContext:UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        let sourceImageView = self.sourceTransition!.transitionSourceImageView()
        containerView.addSubview(sourceImageView)

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseOut,
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
