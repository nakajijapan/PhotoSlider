//
//  ImageView.swift
//
//  Created by nakajijapan on 3/29/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit

protocol PhotoSliderImageViewDelegate {
    func photoSliderImageViewDidEndZooming(viewController: PhotoSlider.ImageView, atScale scale: CGFloat)
}

class ImageView: UIView, UIScrollViewDelegate {

    var imageView: UIImageView!
    var scrollView: UIScrollView!
    var progressView: PhotoSlider.ProgressView!
    var delegate: PhotoSliderImageViewDelegate? = nil
    
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
        self.imageView = UIImageView(frame: CGRectZero)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boundsSize = self.bounds.size
        var frameToCenter = self.imageView.frame
        
        // Horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0)
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0)
            
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if !CGRectEqualToRect(self.imageView.frame, frameToCenter) {
            
            self.imageView.frame = frameToCenter;
            
        }
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
            }) { (image, error, cacheType, imageURL) -> Void in
                self.progressView.hidden = true
                
                if error == nil {
                    self.layoutImageView(image)
                }
        }
    }
    
    func setImage(image:UIImage) {
        self.layoutImageView(image)
    }
    
    func layoutImageView(image:UIImage) {
        var frame = CGRectZero
        frame.origin = CGPointZero
        
        if image.size.width > image.size.height {
            frame.size = CGSize(width: self.bounds.width, height: image.size.height * (self.bounds.width / image.size.width))
        } else {
            frame.size = CGSize(width: image.size.width * (self.bounds.height / image.size.height), height: self.bounds.height)
        }
        
        self.imageView.frame = frame
        self.imageView.center = CGPoint(x: CGRectGetMidX(self.bounds), y: CGRectGetMidY(self.bounds))
    }
    
    
    func didDoubleTap(sender: UIGestureRecognizer) {

        if self.scrollView.zoomScale == 1.0 {

            let touchPoint = sender.locationInView(self)
            self.scrollView.zoomToRect(CGRect(x: touchPoint.x, y: touchPoint.y, width: 1, height: 1), animated: true)

        } else {

            self.scrollView.setZoomScale(0.0, animated: true)

        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        self.delegate?.photoSliderImageViewDidEndZooming(self, atScale: scale)
    }
    
}
