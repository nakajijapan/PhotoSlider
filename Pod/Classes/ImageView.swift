//
//  ImageView.swift
//
//  Created by nakajijapan on 3/29/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit

class ImageView: UIView, UIScrollViewDelegate {

    var imageView:UIImageView!
    var scrollView:UIScrollView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.bounces = true
        self.scrollView.delegate  = self
        //self.scrollView.backgroundColor = UIColor.greenColor()
        
        self.backgroundColor = UIColor.clearColor()
        
        self.imageView = UIImageView(frame: self.bounds)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.userInteractionEnabled = true
        
        self.userInteractionEnabled = true
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)

        let doubleTabGesture = UITapGestureRecognizer(target: self, action: "didDoubleTap:")
        doubleTabGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTabGesture)
    }
    
    func didDoubleTap(sender: UIGestureRecognizer) {
        if self.scrollView.zoomScale == 1.0 {
            self.scrollView.setZoomScale(2.0, animated: true)
        } else {
            self.scrollView.setZoomScale(0.0, animated: true)
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

}
