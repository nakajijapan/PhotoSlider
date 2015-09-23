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
    var progressView: PhotoSlider.ProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initialize()
    }
    
    func initialize() {

        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = true

        // for zoom
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.bounces = true
        self.scrollView.delegate  = self
        
        // image
        self.imageView = UIImageView(frame: self.bounds)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.userInteractionEnabled = true

        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        
        // progress view
        self.progressView = ProgressView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        self.progressView.center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        self.progressView.hidden = true
        self.addSubview(self.progressView)
        

        let doubleTabGesture = UITapGestureRecognizer(target: self, action: "didDoubleTap:")
        doubleTabGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTabGesture)
        
        self.imageView.autoresizingMask = [
            .FlexibleWidth,
            .FlexibleLeftMargin,
            .FlexibleRightMargin,
            .FlexibleTopMargin,
            .FlexibleHeight,
            .FlexibleBottomMargin
        ]
        
    }
    
    func loadImage(imageURL: NSURL) {
        self.progressView.hidden = false
        self.imageView.sd_setImageWithURL(
            imageURL,
            placeholderImage: nil,
            options: .CacheMemoryOnly,
            progress: { (receivedSize, expectedSize) -> Void in
                let progress = Float(receivedSize) / Float(expectedSize)
                self.progressView.animateCurveToProgress(progress)
            }) { (image, error, cacheType, ImageView) -> Void in
                self.progressView.hidden = true
        }
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
