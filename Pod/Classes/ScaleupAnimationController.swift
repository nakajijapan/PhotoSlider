//
//  ScaleupAnimationController.swift
//  Pods
//
//  Created by nakajijapan on 2015/09/13.
//
//

import UIKit

public protocol ScaleupAnimationControllerTransitioning {
    func transitionSourceImageView() -> UIImageView
    func transitionDestinationImageViewFrame() -> CGRect
}


public class ScaleupAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var present = true
    public var sourceTransition: ScaleupAnimationControllerTransitioning?
    public var destinationTransition: ScaleupAnimationControllerTransitioning?

    public init(present: Bool) {
        super.init()
        self.present = present
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
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
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

        let alphaView = UIView(frame: transitionContext.finalFrameForViewController(toViewController))
        alphaView.backgroundColor = UIColor.blackColor()
        alphaView.alpha = 0.0
        containerView.addSubview(alphaView);
        
        let sourceImageView = self.sourceTransition!.transitionSourceImageView()

        containerView.addSubview(sourceImageView)


        UIView.animateWithDuration(
            self.transitionDuration(transitionContext),
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                
                sourceImageView.frame = self.destinationTransition!.transitionDestinationImageViewFrame()
                sourceImageView.transform = CGAffineTransformMakeScale(1.02, 1.02)
                
                alphaView.alpha = 0.9
                
            }) { (result) -> Void in
                
                UIView.animateWithDuration(
                    0.2,
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: { () -> Void in

                        sourceImageView.transform = CGAffineTransformIdentity
                        alphaView.alpha = 1.0


                    },
                    completion: { (result) -> Void in
                        sourceImageView.alpha = 0.0

                        alphaView.alpha = 1.0

                        sourceImageView.removeFromSuperview()
                        alphaView.removeFromSuperview()
                        
                        transitionContext.completeTransition(true)
                })
                

        }
        
    }
    
    func animateDismiss(transitionContext:UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)

        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            
            fromViewController.view.alpha = 0.0
            toViewController.view.alpha = 1.0
            
            
            }, completion: { finished in
                transitionContext.completeTransition(true)
        })
    }

    
   
}
