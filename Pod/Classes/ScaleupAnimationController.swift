//
//  ScaleupAnimationController.swift
//  Pods
//
//  Created by nakajijapan on 2015/09/13.
//
//

import UIKit

public class ScaleupAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    
    var presented = true

    public init(presented: Bool) {
        super.init()
        self.presented = presented
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 3.0
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if self.presented {
            self.animatePresenting(transitionContext)
        } else {
            self.animateDismiss(transitionContext)
        }
    }
    
    func animatePresenting(transitionContext:UIViewControllerContextTransitioning) {
        let presentingController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        containerView.insertSubview(presentedController.view, belowSubview: presentingController.view)
        
        var transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -500.0
        transform = CATransform3DScale(transform, 0.85, 0.85, 1.0)
        
        presentedController.view.frame.origin.y -= containerView.bounds.size.height
        
        //適当にアニメーション
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            
            presentingController.view.alpha = 0.0
            presentingController.view.layer.transform = transform
            presentedController.view.frame.origin.y = 0.0
            
            
            }, completion: { finished in
                transitionContext.completeTransition(true)
        })
    }
    
    func animateDismiss(transitionContext:AnyObject) {
        
    }

    
   
}
