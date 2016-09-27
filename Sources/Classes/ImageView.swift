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

        backgroundColor = UIColor.clear
        isUserInteractionEnabled = true

        // for zoom
        scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.bounces = true
        scrollView.delegate  = self
        
        // image
        imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        addSubview(self.scrollView)
        layoutScrollView()

        scrollView.addSubview(self.imageView)
       
        // progress view
        progressView = ProgressView(frame: CGRect.zero)
        progressView.isHidden = true
        addSubview(self.progressView)
        layoutProgressView()
        
        let doubleTabGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
        doubleTabGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTabGesture)
        
        self.imageView.autoresizingMask = [
            .flexibleWidth,
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleHeight,
            .flexibleBottomMargin
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
        if !imageView.frame.equalTo(frameToCenter) {
            
            imageView.frame = frameToCenter;
            
        }
    }
    
    // MARK: - Constraints
    
    func layoutScrollView() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["scrollView": self.scrollView]
        let constraintVertical   = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[scrollView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )
        let constraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[scrollView]|",
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
        let constraintVertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superView]-(<=1)-[progressView(40)]",
            options: NSLayoutFormatOptions.alignAllCenterX,
            metrics: nil,
            views: views
        )
        let constraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superView]-(<=1)-[progressView(40)]",
            options: NSLayoutFormatOptions.alignAllCenterY,
            metrics: nil,
            views: views
        )
        self.addConstraints(constraintVertical)
        self.addConstraints(constraintHorizontal)
    }
    
    func loadImage(imageURL: URL) {
        
        self.progressView.isHidden = false
        
        self.imageView.kf.setImage(
            with: imageURL,
            placeholder: nil,
            options: [.transition(.fade(1))],
            progressBlock: { (receivedSize, totalSize) -> () in
                
                let progress = Float(receivedSize) / Float(totalSize)
                self.progressView.animateCurveToProgress(progress: progress)

            }) { (image, error, cacheType, imageURL) -> () in
                self.progressView.isHidden = true
                
                if error == nil {
                    self.layoutImageView(image: image!)
                }
        }
        
    }
    
    func setImage(image:UIImage) {

        self.imageView.image = image
        self.layoutImageView(image: image)
        
    }
    
    func layoutImageView(image:UIImage) {
        var frame = CGRect.zero
        frame.origin = CGPoint.zero
        
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
        self.imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    func layoutImageView() {
        
        guard let image = self.imageView.image else {
            return
        }
        self.layoutImageView(image: image)
    }
    
    func didDoubleTap(_ sender: UIGestureRecognizer) {

        if self.scrollView.zoomScale == 1.0 {

            let touchPoint = sender.location(in: self)
            self.scrollView.zoom(to: CGRect(x: touchPoint.x, y: touchPoint.y, width: 1, height: 1), animated: true)


            
        } else {

            self.scrollView.setZoomScale(0.0, animated: true)


        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    @nonobjc func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.delegate?.photoSliderImageViewDidEndZooming(viewController: self, atScale: scale)
    }
    
}
