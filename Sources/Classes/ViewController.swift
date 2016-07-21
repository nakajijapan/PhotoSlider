//
//  ViewController.swift
//
//  Created by nakajijapan on 3/28/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit

@objc public protocol PhotoSliderDelegate:NSObjectProtocol {
    @objc optional func photoSliderControllerWillDismiss(_ viewController: PhotoSlider.ViewController)
    @objc optional func photoSliderControllerDidDismiss(_ viewController: PhotoSlider.ViewController)
}

enum PhotoSliderControllerScrollMode:UInt {
    case none = 0, vertical, horizontal, rotating
}

enum PhotoSliderControllerUsingImageType:UInt {
    case none = 0, url, image, photo
}

public class ViewController:UIViewController, UIScrollViewDelegate, PhotoSliderImageViewDelegate, ZoomingAnimationControllerTransitioning {

    var scrollView:UIScrollView!

    var imageURLs:Array<URL>?
    var images:Array<UIImage>?
    var photos:Array<PhotoSlider.Photo>?
    var usingImageType = PhotoSliderControllerUsingImageType.none
    var backgroundView:UIView!
    var effectView:UIVisualEffectView!
    var closeButton:UIButton?
    var scrollMode:PhotoSliderControllerScrollMode = .none
    var scrollInitalized = false
    var closeAnimating = false
    var imageViews = Array<PhotoSlider.ImageView>()
    var previousPage = 0
    var captionLabel = UILabel(frame: CGRect.zero)


    public var delegate: PhotoSliderDelegate? = nil
    public var visiblePageControl = true
    public var visibleCloseButton = true
    public var currentPage = 0

    public var pageControl = UIPageControl()
    public var backgroundViewColor = UIColor.black()
    public var captionTextColor = UIColor.white()
    
    public init(imageURLs:Array<URL>) {
        super.init(nibName: nil, bundle: nil)
        self.imageURLs = imageURLs
        self.usingImageType = .url
    }

    public init(images:Array<UIImage>) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
        self.usingImageType = .image
    }

    public init(photos:Array<PhotoSlider.Photo>) {
        super.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.usingImageType = .photo
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = UIScreen.main().bounds
        self.view.backgroundColor = UIColor.clear()

        self.backgroundView = UIView(frame: self.view.bounds)
        self.backgroundView.backgroundColor = self.backgroundViewColor

        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 {
            self.view.addSubview(self.backgroundView)
        } else {
            self.effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
            self.effectView.frame = self.view.bounds
            self.view.addSubview(self.effectView)
            self.effectView.addSubview(self.backgroundView)
        }

        // scrollview setting for Item
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.clipsToBounds = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.isScrollEnabled = true
        self.scrollView.accessibilityLabel = "PhotoSliderScrollView"
        self.view.addSubview(self.scrollView)
        self.layoutScrollView()

        self.scrollView.contentSize = CGSize(
            width: self.view.bounds.width * CGFloat(self.imageResources()!.count),
            height: self.view.bounds.height * 3.0
        )

        let width = self.view.bounds.width
        let height = self.view.bounds.height
        var frame = self.view.bounds
        frame.origin.y = height
        for imageResource in self.imageResources()! {
            
            let imageView:PhotoSlider.ImageView = PhotoSlider.ImageView(frame: frame)
            imageView.delegate = self
            self.scrollView.addSubview(imageView)
            
            if imageResource.dynamicType === URL.self {
                imageView.loadImage(imageResource as! URL)
            } else if imageResource.dynamicType === UIImage.self {
                imageView.setImage(imageResource as! UIImage)
            } else {
                let photo = imageResource as! PhotoSlider.Photo
                if photo.imageURL != nil {
                    imageView.loadImage(photo.imageURL!)
                } else {
                    imageView.setImage(photo.image!)
                }
            }
            
            frame.origin.x += width
            
            imageViews.append(imageView)
        }
        
        // Page Control
        if self.visiblePageControl {
            self.pageControl.frame = CGRect.zero
            self.pageControl.numberOfPages = self.imageResources()!.count
            self.pageControl.isUserInteractionEnabled = false
            self.view.addSubview(self.pageControl)
            self.layoutPageControl()
        }
        
        // Close Button
        if self.visibleCloseButton {
            self.closeButton = UIButton(frame: CGRect.zero)
            let imagePath = self.resourceBundle().pathForResource("PhotoSliderClose", ofType: "png")
            self.closeButton!.setImage(UIImage(contentsOfFile: imagePath!), for: UIControlState())
            self.closeButton!.addTarget(self, action: #selector(ViewController.closeButtonDidTap(_:)), for: UIControlEvents.touchUpInside)
            self.closeButton!.imageView?.contentMode = UIViewContentMode.center
            self.view.addSubview(self.closeButton!)
            self.layoutCloseButton()
        }
        
        // Caption
        self.captionLabel.textColor = self.captionTextColor
        self.captionLabel.numberOfLines = 3
        self.view.addSubview(self.captionLabel)
        self.layoutCaptionLabel()
        
        self.updateCaption()
        self.setNeedsStatusBarAppearanceUpdate()

    }
    
    override public func viewWillAppear(_ animated: Bool) {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.width * CGFloat(self.currentPage), y: self.scrollView.bounds.height)
        self.scrollInitalized = true
    }
    
    // MARK: - Constraints
    
    func layoutScrollView() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["scrollView": self.scrollView]
        let constraintVertical   = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constraintHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(constraintVertical)
        self.view.addConstraints(constraintHorizontal)
    }
    
    func layoutCloseButton() {
        self.closeButton!.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["closeButton": self.closeButton!]
        let constraintVertical   = NSLayoutConstraint.constraints(withVisualFormat: "V:|[closeButton(52)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constraintHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:[closeButton(52)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(constraintVertical)
        self.view.addConstraints(constraintHorizontal)
    }
    
    func layoutPageControl() {
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["pageControl": self.pageControl]
        let constraintVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:[pageControl]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constraintCenterX  = NSLayoutConstraint.constraints(withVisualFormat: "H:|[pageControl]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        self.view.addConstraints(constraintVertical)
        self.view.addConstraints(constraintCenterX)
    }
    
    func layoutCaptionLabel() {
        self.captionLabel.translatesAutoresizingMaskIntoConstraints = false
        let views = ["captionLabel": self.captionLabel]
        let constraintVertical   = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[captionLabel]-32-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )
        let constraintHorizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-16-[captionLabel]-16-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )
        self.view.addConstraints(constraintVertical)
        self.view.addConstraints(constraintHorizontal)
    }
    
    // MARK: - UIScrollViewDelegate

    var scrollPreviewPoint = CGPoint.zero
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.previousPage = self.currentPage
        
        self.scrollPreviewPoint = scrollView.contentOffset
        
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollInitalized == false {
            self.generateCurrentPage()
            return
        }
        
        let imageView = self.imageViews[self.currentPage]
        if imageView.scrollView.zoomScale > 1.0 {
            self.generateCurrentPage()
            self.scrollView.isScrollEnabled = false
            return
        }
        
        if self.scrollMode == .rotating {
            return
        }
        

        let offsetX = fabs(scrollView.contentOffset.x - self.scrollPreviewPoint.x)
        let offsetY = fabs(scrollView.contentOffset.y - self.scrollPreviewPoint.y)
        
        if self.scrollMode == .none {
            if (offsetY > offsetX) {
                self.scrollMode = .vertical
            } else {
                self.scrollMode = .horizontal
            }
        }
        
        if self.scrollMode == .vertical {
            let offsetHeight = fabs(scrollView.frame.size.height - scrollView.contentOffset.y)
            let alpha = 1.0 - ( fabs(offsetHeight) / (scrollView.frame.size.height / 2.0) )

            self.backgroundView.alpha = alpha
            
            var contentOffset = scrollView.contentOffset
            contentOffset.x = self.scrollPreviewPoint.x
            scrollView.contentOffset = contentOffset
            
            let screenHeight = UIScreen.main().bounds.size.height
            
            if self.scrollView.contentOffset.y > screenHeight * 1.4 {
                self.closePhotoSlider(true)
            } else if self.scrollView.contentOffset.y < screenHeight * 0.6  {
                self.closePhotoSlider(false)
            }
            
        } else if self.scrollMode == .horizontal {
            var contentOffset = scrollView.contentOffset
            contentOffset.y = self.scrollPreviewPoint.y
            scrollView.contentOffset = contentOffset
        }
        
        // Update current page index.
        self.generateCurrentPage()

    }
    
    func generateCurrentPage() {

        var page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if page < 0 {
            page = 0
        } else if page >= self.imageResources()?.count {
            page = self.imageResources()!.count - 1;
        }
        
        self.currentPage = page

        if self.visiblePageControl {
            self.pageControl.currentPage = self.currentPage
        }

    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if self.scrollMode == .vertical {
            
            let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
            if velocity.y < -500 {
                self.scrollView.frame = scrollView.frame
                self.closePhotoSlider(true)
            } else if velocity.y > 500 {
                self.scrollView.frame = scrollView.frame
                self.closePhotoSlider(false)
            }
            
        }
        
    }
    
    func closePhotoSlider(_ up:Bool) {
        
        if self.closeAnimating == true {
            return
        }
        self.closeAnimating = true
        
        let screenHeight = UIScreen.main().bounds.size.height
        let screenWidth = UIScreen.main().bounds.size.width
        var movedHeight = CGFloat(0)
        
        self.delegate?.photoSliderControllerWillDismiss?(self)
        
        if up {
            movedHeight = -screenHeight
        } else {
            movedHeight = screenHeight
        }
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: { () -> Void in
                self.scrollView.frame = CGRect(x: 0, y: movedHeight, width: screenWidth, height: screenHeight)
                self.backgroundView.alpha = 0.0
                self.closeButton?.alpha = 0.0
                self.captionLabel.alpha = 0.0
                self.view.alpha = 0.0
            },
            completion: {(result) -> Void in
                self.dissmissViewControllerAnimated(false)
                self.closeAnimating = false
            }
        )
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if self.previousPage != self.currentPage {

            // If page index has changed - reset zoom scale for previous image.
            let imageView = self.imageViews[self.previousPage]
            imageView.scrollView.zoomScale = imageView.scrollView.minimumZoomScale
            
            // Show Caption Label
            self.updateCaption()

        }
        
        self.scrollMode = .none

    }
    
    // MARK: - Button Actions
    
    func closeButtonDidTap(_ sender:UIButton) {

        self.delegate?.photoSliderControllerWillDismiss?(self)
        self.dissmissViewControllerAnimated(true)

    }
    
    // MARK: - PhotoSliderImageViewDelegate

    func photoSliderImageViewDidEndZooming(_ viewController: PhotoSlider.ImageView, atScale scale: CGFloat) {
        if scale <= 1.0 {
            self.scrollView.isScrollEnabled = true
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.closeButton?.alpha = 1.0
                self.captionLabel.alpha = 1.0
                if self.visiblePageControl {
                    self.pageControl.alpha = 1.0
                }
                }, completion: nil)

        } else {
            self.scrollView.isScrollEnabled = false

            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.closeButton?.alpha = 0.0
                self.captionLabel.alpha = 0.0
                if self.visiblePageControl {
                    self.pageControl.alpha = 0.0
                }
                }, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    
    func dissmissViewControllerAnimated(_ animated:Bool) {
        
        self.dismiss(animated: animated, completion: { () -> Void in
            
            self.delegate?.photoSliderControllerDidDismiss?(self)
            
        })
    }
    
    func resourceBundle() -> Bundle {
        
        let bundlePath = Bundle.main.pathForResource(
            "PhotoSlider",
            ofType: "bundle",
            inDirectory: "Frameworks/PhotoSlider.framework"
        )
        
        if bundlePath != nil {
            return Bundle(path: bundlePath!)!
        }
        
        return Bundle(for: self.dynamicType)

    }
    
    // MARK: - UITraitEnvironment
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        self.scrollMode = .rotating
        
        let contentViewBounds = self.view.bounds
        let height = contentViewBounds.height
        
        // Background View
        self.backgroundView.frame = contentViewBounds
        if floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 {
            self.effectView.frame = contentViewBounds
        }
        
        // Scroll View
        self.scrollView.contentSize = CGSize(
            width: contentViewBounds.width * CGFloat(self.imageResources()!.count),
            height: contentViewBounds.height * 3.0
        )
        self.scrollView.frame = contentViewBounds
        
        // ImageViews
        var frame = CGRect(x: 0.0, y: contentViewBounds.height, width: contentViewBounds.width, height: contentViewBounds.height)
        for i in 0..<self.scrollView.subviews.count {

            let imageView = self.scrollView.subviews[i] as! PhotoSlider.ImageView
            
            imageView.frame = frame
            frame.origin.x += contentViewBounds.size.width
            imageView.scrollView.frame = contentViewBounds

            imageView.layoutImageView()

        }
        
        self.scrollView.contentOffset = CGPoint(x: CGFloat(self.currentPage) * contentViewBounds.width, y: height)
        
        self.scrollMode = .none
    }
    
    // MARK: - ZoomingAnimationControllerTransitioning
    
    public func transitionSourceImageView() -> UIImageView {
        let zoomingImageView = self.imageViews[self.currentPage]
        zoomingImageView.imageView.clipsToBounds = true
        zoomingImageView.imageView.contentMode = UIViewContentMode.scaleAspectFill
        return zoomingImageView.imageView
    }
    
    public func transitionDestinationImageView(_ sourceImageView: UIImageView) {
        
        guard let sourceImage = sourceImageView.image else {
            return
        }
        
        var height = CGFloat(0.0)
        var width = CGFloat(0.0)
        
        if self.view.bounds.width < self.view.bounds.height {
                
            height = (self.view.frame.width * sourceImage.size.height) / sourceImage.size.width
            width  = self.view.frame.width

        } else {

            height = self.view.frame.height
            width  = (self.view.frame.height * sourceImage.size.width) / sourceImage.size.height

        }

        sourceImageView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        sourceImageView.center = CGPoint(
            x: self.view.frame.width * 0.5,
            y: self.view.frame.height * 0.5
        )
        
        
    }
    
    // MARK: - Private Method

    func imageResources() -> Array<AnyObject>? {

        if self.usingImageType == .url {
            return self.imageURLs
        } else if self.usingImageType == .image {
            return self.images
        } else if self.usingImageType == .photo {
            return self.photos
        }
        
        return nil
    }
    
    func updateCaption() {

        if self.usingImageType == .photo {
            if self.imageResources()?.count > 0 {
                let photo = self.photos![self.currentPage] as Photo
                UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                    self.captionLabel.alpha = 0.0
                    }, completion: { (completed) -> Void in

                        self.captionLabel.text = photo.caption
                        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                            self.captionLabel.alpha = 1.0
                        }, completion: nil)

                        
                })
            }
        }

    }

}
