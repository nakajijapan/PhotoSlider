//
//  ImageView.swift
//
//  Created by nakajijapan on 3/29/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit
import Kingfisher

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
        self.layoutScrollView()

        self.scrollView.addSubview(self.imageView)
       
        // progress view
        self.progressView = ProgressView(frame: CGRectZero)
        self.progressView.hidden = true
        self.addSubview(self.progressView)
        self.layoutProgressView()
        
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
    
    // MARK: - Constraints
    
    func layoutScrollView() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["scrollView": self.scrollView]
        let constraintVertical   = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[scrollView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )
        let constraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[scrollView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )
        self.addConstraints(constraintVertical)
        self.addConstraints(constraintHorizontal)
    }
    
    func layoutProgressView() {
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["progressView": self.progressView, "superView": self]
        let constraintVertical = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[superView]-(<=1)-[progressView(40)]",
            options: NSLayoutFormatOptions.AlignAllCenterX,
            metrics: nil,
            views: views
        )
        let constraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[superView]-(<=1)-[progressView(40)]",
            options: NSLayoutFormatOptions.AlignAllCenterY,
            metrics: nil,
            views: views
        )
        self.addConstraints(constraintVertical)
        self.addConstraints(constraintHorizontal)
    }
    
    func loadImage(imageURL: NSURL) {
        
        self.progressView.hidden = false
        
        self.imageView.kf_setImageWithURL(
            imageURL,
            placeholderImage: nil,
            optionsInfo: [.CacheMemoryOnly],
            progressBlock: { (receivedSize, totalSize) -> () in
                
                let progress = Float(receivedSize) / Float(totalSize)
                self.progressView.animateCurveToProgress(progress)

            }) { (image, error, cacheType, imageURL) -> () in
                self.progressView.hidden = true
                
                if error == nil {
                    self.layoutImageView(image!)
                }
        }
        
    }
    
    func setImage(image:UIImage) {

        self.imageView.image = image
        self.layoutImageView(image)
        
    }
    
    func layoutImageView(image:UIImage) {
        var frame = CGRectZero
        frame.origin = CGPointZero
        
        let height = image.size.height * (self.bounds.width / image.size.width)
        let width = image.size.width * (self.bounds.height / image.size.height)
        
        if image.size.width > image.size.height {
            
            frame.size = CGSize(width: self.bounds.width, height: height)
            if height >= self.bounds.height {
                frame.size = CGSize(width: width, height: self.bounds.height)
            }
            
        } else {

            frame.size = CGSize(width: width, height: self.bounds.height)
            if width >= self.bounds.width {
                frame.size = CGSize(width: self.bounds.width, height: height)
            }

        }
        
        self.imageView.frame = frame
        self.imageView.center = CGPoint(x: CGRectGetMidX(self.bounds), y: CGRectGetMidY(self.bounds))
    }
    
    func layoutImageView() {
        
        guard let image = self.imageView.image else {
            return
        }
        self.layoutImageView(image)
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
