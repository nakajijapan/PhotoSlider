//
//  ViewController.swift
//
//  Created by nakajijapan on 3/28/15.
//  Copyright (c) 2015 net.nakajijapan. All rights reserved.
//

import UIKit

@objc public protocol PhotoSliderDelegate {
    @objc optional func photoSliderControllerWillDismiss(_ viewController: PhotoSlider.ViewController)
    @objc optional func photoSliderControllerDidDismiss(_ viewController: PhotoSlider.ViewController)
}

enum PhotoSliderControllerScrollMode: UInt {
    case None = 0, Vertical, Horizontal, Rotating
}

enum PhotoSliderControllerUsingImageType: UInt {
    case None = 0, URL, Image, Photo
}

public class ViewController: UIViewController {

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(
            x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        )
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.accessibilityLabel = "PhotoSliderScrollView"

        scrollView.contentSize = CGSize(
            width: self.view.bounds.width * CGFloat(self.imageResources()!.count),
            height: self.view.bounds.height * 3.0
        )

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        return scrollView
    }()
    
    var imageURLs: [URL]?
    var images: [UIImage]?
    var photos: [PhotoSlider.Photo]?
    var usingImageType: PhotoSliderControllerUsingImageType = .None

    lazy var backgroundView: UIView = {
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = self.backgroundViewColor
        return backgroundView
    }()

    lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.frame = self.view.bounds
        return effectView
    }()

    lazy var closeButton: UIButton = {
        let closeButton = UIButton(frame: CGRect.zero)
        let imagePath = self.resourceBundle().path(forResource: "PhotoSliderClose", ofType: "png")
        closeButton.setImage(UIImage(contentsOfFile: imagePath!), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonDidTap(_:)), for: .touchUpInside)
        closeButton.imageView?.contentMode = UIViewContentMode.center
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        closeButton.layer.shadowRadius = 3
        closeButton.layer.shadowOpacity = 1
        return closeButton
    }()

    var scrollMode: PhotoSliderControllerScrollMode = .None
    var scrollInitalized = false
    var closeAnimating = false
    var imageViews: [PhotoSlider.ImageView] = []
    var previousPage = 0
    lazy var captionLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = self.captionTextColor
        label.numberOfLines = self.captionNumberOfLines
        return label
    }()

    // For ScrollViewDelegate
    var scrollPreviewPoint = CGPoint.zero

    public weak var delegate: PhotoSliderDelegate?
    public var visiblePageControl = true
    public var visibleCloseButton = true
    public var currentPage = 0
    public var captionNumberOfLines = 3

    lazy public var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.frame = .zero
        pageControl.numberOfPages = self.imageResources()!.count
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    public var backgroundViewColor = UIColor.black
    public var captionTextColor = UIColor.white

    public var imageLoader: PhotoSlider.ImageLoader?

    public init(imageURLs: [URL]) {
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

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var statusBarHidden = false

    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override public var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor.clear

        view.addSubview(effectView)
        effectView.contentView.addSubview(backgroundView)

        // scrollview setting for Item
        view.addSubview(scrollView)
        layoutScrollView()

        let width = view.bounds.width
        let height = view.bounds.height
        var frame = view.bounds
        frame.origin.y = height

        if imageLoader == nil {
            imageLoader = PhotoSlider.KingfisherImageLoader()
        }

        for imageResource in imageResources()! {
            
            let imageView: PhotoSlider.ImageView = PhotoSlider.ImageView(frame: frame)
            imageView.delegate = self
            imageView.imageLoader = imageLoader
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
            view.addSubview(pageControl)
            layoutPageControl()
        }
        
        // Close Button
        if visibleCloseButton {
            view.addSubview(closeButton)
            layoutCloseButton()
        }

        // Caption
        view.addSubview(captionLabel)
        layoutCaptionLabel()
        updateCaption()

        if width > height {
            statusBarHidden = true
        }

        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func closeButtonDidTap(_ sender: UIButton) {
        delegate?.photoSliderControllerWillDismiss?(self)
        dissmissViewControllerAnimated(animated: true)
    }

    override public func viewWillAppear(_ animated: Bool) {
        scrollView.contentOffset = CGPoint(
            x: scrollView.bounds.width * CGFloat(currentPage),
            y: scrollView.bounds.height
        )
        scrollInitalized = true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        statusBarHidden = true
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

}

// MARK: - Setup Layout

fileprivate extension ViewController {

    func layoutScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
            ].forEach { $0.isActive = true }
    }

    func layoutCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            [
                closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
                closeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
                closeButton.heightAnchor.constraint(equalToConstant: 52.0),
                closeButton.widthAnchor.constraint(equalToConstant: 52.0),
                ].forEach { $0.isActive = true }
        } else {
            [
                closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
                closeButton.heightAnchor.constraint(equalToConstant: 52.0),
                closeButton.widthAnchor.constraint(equalToConstant: 52.0),
                ].forEach { $0.isActive = true }

        }
    }

    func layoutPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            [
                pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0),
                pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                pageControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
                pageControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
                ].forEach { $0.isActive = true }
        } else {
            [
                pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                pageControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
                pageControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
                ].forEach { $0.isActive = true }
        }
    }

    func layoutCaptionLabel() {
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            [
                captionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0),
                captionLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16.0),
                captionLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16.0),
                ].forEach { $0.isActive = true }
        } else {
            [
                captionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32.0),
                captionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
                captionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
                ].forEach { $0.isActive = true }
        }
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
        
        let offsetX = fabs(scrollView.contentOffset.x - scrollPreviewPoint.x)
        let offsetY = fabs(scrollView.contentOffset.y - scrollPreviewPoint.y)
        
        if scrollMode == .None {
            if offsetY > offsetX {
                scrollMode = .Vertical
            } else {
                scrollMode = .Horizontal
            }
        }
        
        if scrollMode == .Vertical {
            let offsetHeight = fabs(scrollView.frame.size.height - scrollView.contentOffset.y)
            let alpha = 1.0 - ( fabs(offsetHeight) / (scrollView.frame.size.height / 2.0) )

            backgroundView.alpha = alpha
            
            var contentOffset = scrollView.contentOffset
            contentOffset.x = scrollPreviewPoint.x
            scrollView.contentOffset = contentOffset
            
            let screenHeight = UIScreen.main.bounds.size.height
            
            if scrollView.contentOffset.y > screenHeight * 1.4 {
                closePhotoSlider(movingUp: true)
            } else if scrollView.contentOffset.y < screenHeight * 0.6 {
                closePhotoSlider(movingUp: false)
            }
            
        } else if scrollMode == .Horizontal {
            var contentOffset = scrollView.contentOffset
            contentOffset.y = scrollPreviewPoint.y
            scrollView.contentOffset = contentOffset
        }
        
        // Update current page index.
        generateCurrentPage()

    }
    
    fileprivate func generateCurrentPage() {

        var page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if page < 0 {
            page = 0
        } else if page >= imageResources()!.count {
            page = imageResources()!.count - 1
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
                closePhotoSlider(movingUp: true)
            } else if velocity.y > 500 {
                scrollView.frame = scrollView.frame
                closePhotoSlider(movingUp: false)
            }
            
        }
        
    }
    
    fileprivate func closePhotoSlider(movingUp: Bool) {
        
        if closeAnimating == true {
            return
        }
        closeAnimating = true
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        var movedHeight = CGFloat(0)
        
        delegate?.photoSliderControllerWillDismiss?(self)
        
        if movingUp {
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
                self.closeButton.alpha = 0.0
                self.captionLabel.alpha = 0.0
                self.view.alpha = 0.0
            },
            completion: { _ -> Void in
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

    func photoSliderImageViewDidEndZooming(_ viewController: PhotoSlider.ImageView, atScale scale: CGFloat) {
        if scale <= 1.0 {
            scrollView.isScrollEnabled = true
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.closeButton.alpha = 1.0
                self.captionLabel.alpha = 1.0
                if self.visiblePageControl {
                    self.pageControl.alpha = 1.0
                }
                }, completion: nil)

        } else {
            scrollView.isScrollEnabled = false

            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.closeButton.alpha = 0.0
                self.captionLabel.alpha = 0.0
                if self.visiblePageControl {
                    self.pageControl.alpha = 0.0
                }
                }, completion: nil)
        }
    }
    
    func dissmissViewControllerAnimated(animated: Bool) {
        
        dismiss(animated: animated, completion: { () -> Void in
            
            self.delegate?.photoSliderControllerDidDismiss?(self)
            
        })
    }
    
    fileprivate func resourceBundle() -> Bundle {
        
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
        
        let contentViewBounds = view.bounds
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
        
        guard let sourceImage = sourceImageView.image else { return }
        
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
    fileprivate func imageResources() -> [AnyObject]? {
        if usingImageType == .URL {
            return imageURLs as [AnyObject]?
        } else if usingImageType == .Image {
            return images
        } else if usingImageType == .Photo {
            return photos
        }
        return nil
    }
    
    fileprivate func updateCaption() {
        if usingImageType == .Photo {
            if imageResources()!.count > 0 {
                let photo = photos![currentPage] as Photo
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: .curveLinear,
                    animations: { () -> Void in
                        self.captionLabel.alpha = 0.0
                }, completion: { _ -> Void in
                    self.captionLabel.text = photo.caption
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                        self.captionLabel.alpha = 1.0
                    }, completion: nil)
                })
            }
        }
    }
}
