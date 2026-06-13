//
//  PhotoSliderViewController.swift
//  PhotoSlider
//
//  Internal interaction engine, ported from v1.5.0 `PhotoSlider.ViewController`.
//
//  The horizontal paging + vertical swipe-to-dismiss + background-fade physics are
//  preserved byte-for-byte (same single UIScrollView, same scrollMode exclusivity,
//  same distance/velocity thresholds, same ease-out 0.4s slide-out). Only the data
//  source ([PhotoItem]), the image loader (async `ImageLoader`), and the dismissal
//  hand-off (delegated to SwiftUI instead of `self.dismiss()`) are changed.
//
//  `UIScreen.main` and `traitCollectionDidChange(_:)` are replaced with the view's
//  own bounds and `viewWillTransition(to:with:)` to stay warning-free and correct in
//  the SwiftUI / fullScreenCover embedding (behaviour is identical at full screen).
//

import UIKit
import SwiftUI

enum PhotoSliderControllerScrollMode: UInt {
    case none = 0, vertical, horizontal, rotating
}

final class PhotoSliderViewController: UIViewController {

    // MARK: Inputs

    let items: [PhotoItem]
    let configuration: PhotoSliderConfiguration
    let imageLoader: any ImageLoader

    // MARK: Callbacks (assigned by the representable; capture latest SwiftUI state)

    var onPageChanged: ((Int) -> Void)?
    var onWillDismiss: (() -> Void)?
    var onDidDismiss: (() -> Void)?
    var onShare: ((PhotoItem) -> Void)?
    var onLongPress: ((PhotoItem) -> Void)?
    /// Tells SwiftUI to tear the viewer down (e.g. set `isPresented = false`).
    var onRequestDismiss: (() -> Void)?

    // MARK: State

    private var swipeDismissEnabled: Bool { configuration.enableSwipeToDismiss }
    private var bandOffsetY: CGFloat { swipeDismissEnabled ? view.bounds.height : 0 }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(
            x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        )
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = swipeDismissEnabled
        scrollView.isScrollEnabled = true
        scrollView.accessibilityLabel = "PhotoSliderScrollView"

        scrollView.contentSize = CGSize(
            width: self.view.bounds.width * CGFloat(items.count),
            height: self.view.bounds.height * (swipeDismissEnabled ? 3.0 : 1.0)
        )

        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private lazy var backgroundView: UIView = {
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor(configuration.backgroundColor)
        return backgroundView
    }()

    private lazy var captionBackgroundView: UIView = {
        let captionBackgroundView = UIView()
        captionBackgroundView.backgroundColor = captionBackgroundViewColor
        return captionBackgroundView
    }()

    private lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.frame = self.view.bounds
        return effectView
    }()

    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(frame: .zero)
        let image = UIImage(named: "PhotoSliderClose", in: .module, compatibleWith: nil)
        closeButton.setImage(image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonDidTap(_:)), for: .touchUpInside)
        closeButton.imageView?.contentMode = .center
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        closeButton.layer.shadowRadius = 3
        closeButton.layer.shadowOpacity = 1
        closeButton.accessibilityLabel = "Close"
        return closeButton
    }()

    private lazy var shareButton: UIButton = {
        let shareButton = UIButton(frame: .zero)
        let image = UIImage(named: "PhotoSliderShare", in: .module, compatibleWith: nil)
        shareButton.setImage(image, for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonDidTap(_:)), for: .touchUpInside)
        shareButton.imageView?.contentMode = .center
        shareButton.accessibilityLabel = "Share"
        return shareButton
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.frame = .zero
        pageControl.numberOfPages = items.count
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    private lazy var captionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = captionTextColor
        label.numberOfLines = captionNumberOfLines
        return label
    }()

    private var scrollMode: PhotoSliderControllerScrollMode = .none
    private var scrollInitalized = false
    private var closeAnimating = false
    private var imageViews: [PhotoSliderEngineImageView] = []
    private var previousPage = 0
    private var scrollPreviewPoint = CGPoint.zero
    private var statusBarHidden = false

    private(set) var currentPage = 0

    private var visiblePageControl: Bool { configuration.showsPageIndicator }
    private var visibleCloseButton: Bool { configuration.showsCloseButton }
    private var visibleShareButton: Bool { configuration.showsShareButton }
    private var showsCaption: Bool { configuration.showsCaption }

    // Caption styling carried over from v1.5.0 defaults.
    private let captionNumberOfLines = 3
    private let hasCaptionShadow = true
    private let captionBackgroundViewColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
    private let captionTextColor = UIColor.white

    // MARK: Init

    init(
        items: [PhotoItem],
        configuration: PhotoSliderConfiguration,
        imageLoader: any ImageLoader,
        initialPage: Int
    ) {
        self.items = items
        self.configuration = configuration
        self.imageLoader = imageLoader
        self.currentPage = max(0, min(initialPage, max(0, items.count - 1)))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
    override var prefersStatusBarHidden: Bool { statusBarHidden }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        view.addSubview(effectView)
        effectView.contentView.addSubview(backgroundView)

        view.addSubview(scrollView)
        layoutScrollView()

        let width = view.bounds.width
        var frame = view.bounds
        frame.origin.y = bandOffsetY

        for item in items {
            let imageView = PhotoSliderEngineImageView(frame: frame)
            imageView.delegate = self
            scrollView.addSubview(imageView)
            imageView.configure(
                item: item,
                imageLoader: imageLoader,
                maxZoomScale: configuration.maxZoomScale,
                enableZoom: configuration.enablePinchToZoom
            )
            frame.origin.x += width
            imageViews.append(imageView)
        }

        if visibleCloseButton {
            view.addSubview(closeButton)
            layoutCloseButton()
        }

        if visibleShareButton {
            view.addSubview(shareButton)
            layoutShareButton()
        }

        view.addSubview(captionBackgroundView)

        if visiblePageControl {
            captionBackgroundView.addSubview(pageControl)
            layoutPageControl()
        }

        captionBackgroundView.addSubview(captionLabel)
        layoutCaptionLabel()
        updateCaption()
        layoutCaptionBackgroundView()

        if view.bounds.width > view.bounds.height {
            statusBarHidden = true
        }
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.contentOffset = CGPoint(
            x: scrollView.bounds.width * CGFloat(currentPage),
            y: bandOffsetY
        )
        scrollInitalized = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarHidden = true
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        scrollMode = .rotating
        coordinator.animate(alongsideTransition: { _ in
            self.relayout(for: size)
        }, completion: { _ in
            self.scrollMode = .none
        })
    }

    // MARK: Actions

    @objc private func closeButtonDidTap(_ sender: UIButton) {
        onWillDismiss?()
        finishDismiss()
    }

    @objc private func shareButtonDidTap(_ sender: UIButton) {
        guard items.indices.contains(currentPage) else { return }
        onShare?(items[currentPage])
    }

    /// Hands the dismissal back to SwiftUI and fires the `didDismiss` callback.
    private func finishDismiss() {
        onRequestDismiss?()
        onDidDismiss?()
    }

    // MARK: External page sync

    /// Called by the representable when the SwiftUI `selection` binding changes externally.
    func scrollToPage(_ page: Int, animated: Bool) {
        let clamped = max(0, min(page, max(0, items.count - 1)))
        guard clamped != currentPage, scrollInitalized else { return }
        let offset = CGPoint(x: scrollView.bounds.width * CGFloat(clamped), y: scrollView.contentOffset.y)
        scrollView.setContentOffset(offset, animated: animated)
    }

    // MARK: Hero transition hooks (used by ZoomingAnimationController; unused by default in v2.0)

    func setChromeHiddenForHeroTransition() {
        scrollView.alpha = 0.0
        captionBackgroundView.alpha = 0.0
        closeButton.alpha = 0.0
        shareButton.alpha = 0.0
    }

    func revealContentForHeroTransition() {
        scrollView.alpha = 1.0
    }

    func revealChromeForHeroTransition() {
        captionBackgroundView.alpha = 1.0
        closeButton.alpha = 1.0
        shareButton.alpha = 1.0
    }
}

// MARK: - Setup Layout

private extension PhotoSliderViewController {

    func layoutScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ].forEach { $0.isActive = true }
    }

    func layoutCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        [
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 52.0),
            closeButton.widthAnchor.constraint(equalToConstant: 52.0)
        ].forEach { $0.isActive = true }
    }

    func layoutShareButton() {
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        [
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            shareButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            shareButton.heightAnchor.constraint(equalToConstant: 52.0),
            shareButton.widthAnchor.constraint(equalToConstant: 52.0)
        ].forEach { $0.isActive = true }
    }

    func layoutPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        [
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            pageControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
        ].forEach { $0.isActive = true }
    }

    func layoutCaptionLabel() {
        if hasCaptionShadow {
            let translucentBlack = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            captionLabel.shadowColor = translucentBlack
            captionLabel.shadowOffset = CGSize(width: 0.5, height: 0.5)
            captionLabel.layer.shadowRadius = 1.0
        }

        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        [
            captionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0),
            captionLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16.0),
            captionLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16.0)
        ].forEach { $0.isActive = true }
    }

    func layoutCaptionBackgroundView() {
        captionBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        [
            captionBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            captionBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            captionBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            captionBackgroundView.topAnchor.constraint(equalTo: captionLabel.topAnchor, constant: -16.0)
        ].forEach { $0.isActive = true }
    }

    func relayout(for size: CGSize) {
        let height = size.height
        let bounds = CGRect(origin: .zero, size: size)

        effectView.frame = bounds
        backgroundView.frame = bounds

        scrollView.contentSize = CGSize(
            width: size.width * CGFloat(items.count),
            height: size.height * (swipeDismissEnabled ? 3.0 : 1.0)
        )
        scrollView.frame = bounds

        let newBandOffsetY = swipeDismissEnabled ? height : 0
        var frame = CGRect(x: 0.0, y: newBandOffsetY, width: size.width, height: size.height)
        for imageView in imageViews {
            imageView.frame = frame
            frame.origin.x += size.width
            imageView.scrollView.frame = bounds
            imageView.layoutImageView()
        }

        scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * size.width, y: newBandOffsetY)
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoSliderViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        previousPage = currentPage
        scrollPreviewPoint = scrollView.contentOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

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

        if scrollMode == .rotating {
            return
        }

        let offsetX = abs(scrollView.contentOffset.x - scrollPreviewPoint.x)
        let offsetY = abs(scrollView.contentOffset.y - scrollPreviewPoint.y)

        if scrollMode == .none {
            if offsetY > offsetX {
                scrollMode = .vertical
            } else {
                scrollMode = .horizontal
            }
        }

        if scrollMode == .vertical {
            let offsetHeight = abs(scrollView.frame.size.height - scrollView.contentOffset.y)
            let alpha = 1.0 - (abs(offsetHeight) / (scrollView.frame.size.height / 2.0))

            backgroundView.alpha = alpha

            var contentOffset = scrollView.contentOffset
            contentOffset.x = scrollPreviewPoint.x
            scrollView.contentOffset = contentOffset

            if swipeDismissEnabled {
                let screenHeight = view.bounds.size.height
                let threshold = configuration.dismissProgressThreshold
                if scrollView.contentOffset.y > screenHeight * (1.0 + threshold) {
                    closePhotoSlider(movingUp: true)
                } else if scrollView.contentOffset.y < screenHeight * (1.0 - threshold) {
                    closePhotoSlider(movingUp: false)
                }
            }

        } else if scrollMode == .horizontal {
            var contentOffset = scrollView.contentOffset
            contentOffset.y = scrollPreviewPoint.y
            scrollView.contentOffset = contentOffset
        }

        generateCurrentPage()
    }

    private func generateCurrentPage() {

        var page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if page < 0 {
            page = 0
        } else if page >= items.count {
            page = items.count - 1
        }

        if page != currentPage {
            currentPage = page
            if visiblePageControl {
                pageControl.currentPage = currentPage
            }
            onPageChanged?(currentPage)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        if scrollMode == .vertical, swipeDismissEnabled {

            let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
            if velocity.y < -500 {
                closePhotoSlider(movingUp: true)
            } else if velocity.y > 500 {
                closePhotoSlider(movingUp: false)
            }
        }
    }

    private func closePhotoSlider(movingUp: Bool) {

        if closeAnimating { return }
        closeAnimating = true

        let screenHeight = view.bounds.height
        let screenWidth = view.bounds.width
        let movedHeight = movingUp ? -screenHeight : screenHeight

        onWillDismiss?()

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.scrollView.frame = CGRect(x: 0, y: movedHeight, width: screenWidth, height: screenHeight)
                self.backgroundView.alpha = 0.0
                self.closeButton.alpha = 0.0
                self.shareButton.alpha = 0.0
                self.captionLabel.alpha = 0.0
                self.captionBackgroundView.alpha = 0.0
                self.view.alpha = 0.0
            },
            completion: { _ in
                self.finishDismiss()
                self.closeAnimating = false
            }
        )
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if previousPage != currentPage {
            let imageView = imageViews[previousPage]
            imageView.scrollView.zoomScale = imageView.scrollView.minimumZoomScale
            updateCaption()
        }

        scrollMode = .none
    }
}

// MARK: - PhotoSliderImageViewDelegate

extension PhotoSliderViewController: PhotoSliderImageViewDelegate {

    func photoSliderImageViewDidLongPress(_ imageView: PhotoSliderEngineImageView) {
        guard let index = imageViews.firstIndex(where: { $0 === imageView }), items.indices.contains(index) else { return }
        onLongPress?(items[index])
    }

    func photoSliderImageViewDidEndZooming(_ imageView: PhotoSliderEngineImageView, atScale scale: CGFloat) {
        if scale <= 1.0 {
            scrollView.isScrollEnabled = true

            UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveLinear, animations: {
                self.closeButton.alpha = 1.0
                self.shareButton.alpha = 1.0
                self.captionLabel.alpha = 1.0
                if let captionText = self.captionLabel.text, !captionText.isEmpty {
                    self.captionBackgroundView.backgroundColor = self.captionBackgroundViewColor
                }
                if self.visiblePageControl {
                    self.pageControl.alpha = 1.0
                }
            })

        } else {
            scrollView.isScrollEnabled = false

            UIView.animate(withDuration: 0.05, delay: 0.0, options: .curveLinear, animations: {
                self.closeButton.alpha = 0.0
                self.shareButton.alpha = 0.0
                self.captionLabel.alpha = 0.0
                self.captionBackgroundView.backgroundColor = .clear
                if self.visiblePageControl {
                    self.pageControl.alpha = 0.0
                }
            })
        }
    }
}

// MARK: - Caption

private extension PhotoSliderViewController {

    func updateCaption() {
        guard showsCaption, items.indices.contains(currentPage) else {
            captionLabel.text = nil
            captionBackgroundView.backgroundColor = .clear
            return
        }

        let caption = items[currentPage].caption

        UIView.animate(
            withDuration: 0.1,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                self.captionLabel.alpha = 0.0
                self.captionBackgroundView.backgroundColor = .clear
            },
            completion: { _ in
                self.captionLabel.text = caption

                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear) {
                    self.captionLabel.alpha = 1.0
                    if let captionText = self.captionLabel.text, !captionText.isEmpty {
                        self.captionBackgroundView.backgroundColor = self.captionBackgroundViewColor
                    }
                }
            }
        )
    }
}

// MARK: - ZoomingAnimationControllerTransitioning (capability preserved, unused by default in v2.0)

extension PhotoSliderViewController: ZoomingAnimationControllerTransitioning {

    func transitionSourceImageView() -> UIImageView {
        let zoomingImageView = imageViews[currentPage]
        zoomingImageView.imageView.clipsToBounds = true
        zoomingImageView.imageView.contentMode = .scaleAspectFill
        return zoomingImageView.imageView
    }

    func transitionDestinationImageView(sourceImageView: UIImageView) {

        guard let sourceImage = sourceImageView.image else { return }

        var height: CGFloat = 0.0
        var width: CGFloat = 0.0

        if view.bounds.width < view.bounds.height {
            height = (view.frame.width * sourceImage.size.height) / sourceImage.size.width
            width = view.frame.width
        } else {
            height = view.frame.height
            width = (view.frame.height * sourceImage.size.width) / sourceImage.size.height
        }

        sourceImageView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        sourceImageView.center = CGPoint(
            x: view.frame.width * 0.5,
            y: view.frame.height * 0.5
        )
    }
}
