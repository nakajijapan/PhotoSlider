//
//  ViewController.swift
//
//  Created by nakajijapan on 3/28/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit

@objc public protocol PhotoSliderDelegate:NSObjectProtocol {
    @objc optional func photoSliderControllerWillDismiss(viewController: PhotoSlider.ViewController)
    @objc optional func photoSliderControllerDidDismiss(viewController: PhotoSlider.ViewController)
}

enum PhotoSliderControllerScrollMode:UInt {
    case None = 0, Vertical, Horizontal, Rotating
}

enum PhotoSliderControllerUsingImageType:UInt {
    case None = 0, URL, Image, Photo
}

public class ViewController:UIViewController {

    var scrollView: UIScrollView!

    var imageURLs: [URL]?
    var images: [UIImage]?
    var photos: [PhotoSlider.Photo]?
    var usingImageType: PhotoSliderControllerUsingImageType = .None
    var backgroundView: UIView!
    var effectView: UIVisualEffectView!
    var closeButton: UIButton?
    var scrollMode: PhotoSliderControllerScrollMode = .None
    var scrollInitalized = false
    var closeAnimating = false
    var imageViews: [PhotoSlider.ImageView] = []
    var previousPage = 0
    var captionLabel = UILabel(frame: CGRect.zero)

    // For ScrollViewDelegate
    var scrollPreviewPoint = CGPoint.zero

    public var delegate: PhotoSliderDelegate?
    public var visiblePageControl = true
    public var visibleCloseButton = true
    public var currentPage = 0

    public var pageControl = UIPageControl()
    public var backgroundViewColor = UIColor.black
    public var captionTextColor = UIColor.white
    public init(imageURLs:Array<URL>) {
        super.init(nibName: nil, bundle: nil)
        self.imageURLs = imageURLs
        usingImageType = .URL
    }

    public init(images: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
        usingImageType = .Image
    }

    public init(photos: [PhotoSlider.Photo]) {
        super.init(nibName: nil, bundle: nil)
        self.photos = photos
        usingImageType = .Photo
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor.clear

        backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = backgroundViewColor

        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.frame = view.bounds
        view.addSubview(effectView)
        effectView.addSubview(backgroundView)

        // scrollview setting for Item
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.accessibilityLabel = "PhotoSliderScrollView"
        view.addSubview(scrollView)
        layoutScrollView()

        scrollView.contentSize = CGSize(
            width: view.bounds.width * CGFloat(imageResources()!.count),
            height: view.bounds.height * 3.0
        )

        let width = view.bounds.width
        let height = view.bounds.height
        var frame = view.bounds
        frame.origin.y = height
        for imageResource in imageResources()! {
            
            let imageView: PhotoSlider.ImageView = PhotoSlider.ImageView(frame: frame)
            imageView.delegate = self
            scrollView.addSubview(imageView)
            
            if imageResource is URL {
                imageView.loadImage(imageURL: imageResource as! URL)
            } else if imageResource is UIImage {
                imageView.setImage(image: imageResource as! UIImage)
            } else {
                let photo = imageResource as! PhotoSlider.Photo
                if photo.imageURL != nil {
                    imageView.loadImage(imageURL: photo.imageURL!)
                } else {
                    imageView.setImage(image: photo.image!)
                }
            }
            
            frame.origin.x += width
            
            imageViews.append(imageView)
        }
        
        // Page Control
        if visiblePageControl {
            pageControl.frame = CGRect.zero
            pageControl.numberOfPages = imageResources()!.count
            pageControl.isUserInteractionEnabled = false
            view.addSubview(pageControl)
            layoutPageControl()
        }
        
        // Close Button
        if visibleCloseButton {
            closeButton = UIButton(frame: CGRect.zero)
            let imagePath = resourceBundle().path(forResource: "PhotoSliderClose", ofType: "png")
            closeButton!.setImage(UIImage(contentsOfFile: imagePath!), for: .normal)
            closeButton!.addTarget(self, action: #selector(closeButtonDidTap(_:)), for: .touchUpInside)
            closeButton!.imageView?.contentMode = UIViewContentMode.center
            view.addSubview(closeButton!)
            layoutCloseButton()
        }
        
        // Caption
        captionLabel.textColor = captionTextColor
        captionLabel.numberOfLines = 3
        view.addSubview(captionLabel)
        layoutCaptionLabel()
        
        updateCaption()
        setNeedsStatusBarAppearanceUpdate()

    }
    
    func closeButtonDidTap(_ sender: UIButton) {
        
        delegate?.photoSliderControllerWillDismiss?(viewController: self)
        dissmissViewControllerAnimated(animated: true)
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        scrollView.contentOffset = CGPoint(
            x: scrollView.bounds.width * CGFloat(currentPage),
            y: scrollView.bounds.height
        )
        scrollInitalized = true
    }

    // Constraints
    
    func layoutScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: UIView] = ["scrollView": scrollView]
        let constraintVertical   = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constraintHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraintVertical)
        view.addConstraints(constraintHorizontal)
    }
    
    func layoutCloseButton() {
        closeButton!.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: UIView] = ["closeButton": closeButton!]
        let constraintVertical   = NSLayoutConstraint.constraints(withVisualFormat: "V:|[closeButton(52)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constraintHorizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:[closeButton(52)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(constraintVertical)
        view.addConstraints(constraintHorizontal)
    }
    
    func layoutPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: UIView] = ["pageControl": pageControl]
        let constraintVertical = NSLayoutConstraint.constraints(withVisualFormat: "V:[pageControl]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let constraintCenterX  = NSLayoutConstraint.constraints(withVisualFormat: "H:|[pageControl]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        view.addConstraints(constraintVertical)
        view.addConstraints(constraintCenterX)
    }
    
    func layoutCaptionLabel() {
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        let views = ["captionLabel": captionLabel]
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
        view.addConstraints(constraintVertical)
        view.addConstraints(constraintHorizontal)
    }
}
// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {


    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        previousPage = currentPage
        scrollPreviewPoint = scrollView.contentOffset
        
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if !scrollInitalized {
            generateCurrentPage()
            return
        }
        
        let imageView = imageViews[currentPage]
        if imageView.scrollView.zoomScale > 1.0 {
            generateCurrentPage()
            scrollView.isScrollEnabled = false
            return
        }
        
        if scrollMode == .Rotating {
            return
        }
        

        let offsetX = fabs(scrollView.contentOffset.x - self.scrollPreviewPoint.x)
        let offsetY = fabs(scrollView.contentOffset.y - self.scrollPreviewPoint.y)
        
        if scrollMode == .None {
            if (offsetY > offsetX) {
                scrollMode = .Vertical
            } else {
                scrollMode = .Horizontal
            }
        }
        
        if self.scrollMode == .Vertical {
            let offsetHeight = fabs(scrollView.frame.size.height - scrollView.contentOffset.y)
            let alpha = 1.0 - ( fabs(offsetHeight) / (scrollView.frame.size.height / 2.0) )

            backgroundView.alpha = alpha
            
            var contentOffset = scrollView.contentOffset
            contentOffset.x = self.scrollPreviewPoint.x
            scrollView.contentOffset = contentOffset
            
            let screenHeight = UIScreen.main.bounds.size.height
            
            if scrollView.contentOffset.y > screenHeight * 1.4 {
                closePhotoSlider(up: true)
            } else if scrollView.contentOffset.y < screenHeight * 0.6  {
                closePhotoSlider(up: false)
            }
            
        } else if self.scrollMode == .Horizontal {
            var contentOffset = scrollView.contentOffset
            contentOffset.y = scrollPreviewPoint.y
            scrollView.contentOffset = contentOffset
        }
        
        // Update current page index.
        self.generateCurrentPage()

    }
    
    func generateCurrentPage() {

        var page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if page < 0 {
            page = 0
        } else if page >= imageResources()!.count {
            page = imageResources()!.count - 1;
        }
        
        currentPage = page

        if visiblePageControl {
            pageControl.currentPage = currentPage
        }

    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollMode == .Vertical {
            
            let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
            if velocity.y < -500 {
                scrollView.frame = scrollView.frame
                closePhotoSlider(up: true)
            } else if velocity.y > 500 {
                scrollView.frame = scrollView.frame
                closePhotoSlider(up: false)
            }
            
        }
        
    }
    
    func closePhotoSlider(up:Bool) {
        
        if closeAnimating == true {
            return
        }
        closeAnimating = true
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        var movedHeight = CGFloat(0)
        
        delegate?.photoSliderControllerWillDismiss?(viewController: self)
        
        if up {
            movedHeight = -screenHeight
        } else {
            movedHeight = screenHeight
        }
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: .curveEaseOut,
            animations: { () -> Void in
                self.scrollView.frame = CGRect(x: 0, y: movedHeight, width: screenWidth, height: screenHeight)
                self.backgroundView.alpha = 0.0
                self.closeButton?.alpha = 0.0
                self.captionLabel.alpha = 0.0
                self.view.alpha = 0.0
            },
            completion: {(result) -> Void in
                self.dissmissViewControllerAnimated(animated: false)
                self.closeAnimating = false
            }
        )
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if previousPage != currentPage {

            // If page index has changed - reset zoom scale for previous image.
            let imageView = imageViews[previousPage]
            imageView.scrollView.zoomScale = imageView.scrollView.minimumZoomScale
            
            // Show Caption Label
            updateCaption()

        }
        
        scrollMode = .None

    }
}

// MARK: - PhotoSliderImageViewDelegate

extension ViewController: PhotoSliderImageViewDelegate {

    func photoSliderImageViewDidEndZooming(viewController: PhotoSlider.ImageView, atScale scale: CGFloat) {
        if scale <= 1.0 {
            scrollView.isScrollEnabled = true
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.closeButton?.alpha = 1.0
                self.captionLabel.alpha = 1.0
                if self.visiblePageControl {
                    self.pageControl.alpha = 1.0
                }
                }, completion: nil)

        } else {
            scrollView.isScrollEnabled = false

            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.closeButton?.alpha = 0.0
                self.captionLabel.alpha = 0.0
                if self.visiblePageControl {
                    self.pageControl.alpha = 0.0
                }
                }, completion: nil)
        }
    }
    
    func dissmissViewControllerAnimated(animated:Bool) {
        
        dismiss(animated: animated, completion: { () -> Void in
            
            self.delegate?.photoSliderControllerDidDismiss?(viewController: self)
            
        })
    }
    
    func resourceBundle() -> Bundle {
        
        let bundlePath = Bundle.main.path(
            forResource: "PhotoSlider",
            ofType: "bundle",
            inDirectory: "Frameworks/PhotoSlider.framework"
        )
        
        if bundlePath != nil {
            return Bundle(path: bundlePath!)!
        }
        
        return Bundle(for: type(of: self))

    }
}

// MARK: - UITraitEnvironmenat

extension ViewController {
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        scrollMode = .Rotating
        
        let contentViewBounds = self.view.bounds
        let height = contentViewBounds.height
        
        // Background View
        backgroundView.frame = contentViewBounds
        
        // Scroll View
        scrollView.contentSize = CGSize(
            width: contentViewBounds.width * CGFloat(imageResources()!.count),
            height: contentViewBounds.height * 3.0
        )
        scrollView.frame = contentViewBounds
        
        // ImageViews
        var frame = CGRect(x: 0.0, y: contentViewBounds.height, width: contentViewBounds.width, height: contentViewBounds.height)
        for i in 0..<scrollView.subviews.count {

            let imageView = scrollView.subviews[i] as! PhotoSlider.ImageView
            
            imageView.frame = frame
            frame.origin.x += contentViewBounds.size.width
            imageView.scrollView.frame = contentViewBounds

            imageView.layoutImageView()

        }
        
        scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * contentViewBounds.width, y: height)
        
        scrollMode = .None
    }
}

// MARK: - ZoomingAnimationControllerTransitioning

extension ViewController: ZoomingAnimationControllerTransitioning {
    
    public func transitionSourceImageView() -> UIImageView {
        let zoomingImageView = imageViews[currentPage]
        zoomingImageView.imageView.clipsToBounds = true
        zoomingImageView.imageView.contentMode = UIViewContentMode.scaleAspectFill
        return zoomingImageView.imageView
    }
    
    public func transitionDestinationImageView(sourceImageView: UIImageView) {
        
        guard let sourceImage = sourceImageView.image else {
            return
        }
        
        var height: CGFloat = 0.0
        var width: CGFloat = 0.0
        
        if view.bounds.width < view.bounds.height {

            height = (view.frame.width * sourceImage.size.height) / sourceImage.size.width
            width  = view.frame.width

        } else {

            height = view.frame.height
            width  = (view.frame.height * sourceImage.size.width) / sourceImage.size.height

        }

        sourceImageView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        sourceImageView.center = CGPoint(
            x: view.frame.width * 0.5,
            y: view.frame.height * 0.5
        )
        
        
    }
    
    // Private Method

    func imageResources() -> [AnyObject]? {

        if usingImageType == .URL {
            return imageURLs as [AnyObject]?
        } else if usingImageType == .Image {
            return images
        } else if usingImageType == .Photo {
            return photos
        }
        
        return nil
    }
    
    func updateCaption() {

        if usingImageType == .Photo {
            if imageResources()!.count > 0 {
                let photo = photos![self.currentPage] as Photo
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
