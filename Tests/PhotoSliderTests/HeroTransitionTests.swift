//
//  HeroTransitionTests.swift
//  PhotoSliderTests
//
//  Boundary tests for the hero (zoom) transition logic. The UI animation itself (zoom
//  physics) is out of scope; what is tested is the UI-free decision logic that picks
//  between "run the hero" and "fall back to a fade", plus the transitioning delegate's
//  present/dismiss factory branches.
//

import XCTest
import UIKit
@testable import PhotoSlider

final class HeroTransitionTests: XCTestCase {

    private let windowBounds = CGRect(x: 0, y: 0, width: 390, height: 844)

    // MARK: - PhotoSliderHeroResolver: fallback boundaries

    func testResolverNilFrameFallsBack() {
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: nil, in: windowBounds))
        XCTAssertFalse(PhotoSliderHeroResolver.shouldUseHero(global: nil, in: windowBounds))
    }

    func testResolverEmptyFrameFallsBack() {
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: .zero, in: windowBounds))
        XCTAssertFalse(PhotoSliderHeroResolver.shouldUseHero(global: .zero, in: windowBounds))
    }

    func testResolverNonPositiveDimensionsFallBack() {
        let zeroWidth = CGRect(x: 10, y: 10, width: 0, height: 100)
        let zeroHeight = CGRect(x: 10, y: 10, width: 100, height: 0)
        let negative = CGRect(x: 10, y: 10, width: -50, height: -50)
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: zeroWidth, in: windowBounds))
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: zeroHeight, in: windowBounds))
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: negative, in: windowBounds))
    }

    func testResolverOffScreenFrameFallsBack() {
        // Entirely above the window.
        let above = CGRect(x: 10, y: -500, width: 100, height: 100)
        // Entirely to the right of the window.
        let right = CGRect(x: 1000, y: 10, width: 100, height: 100)
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: above, in: windowBounds))
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: right, in: windowBounds))
        XCTAssertFalse(PhotoSliderHeroResolver.shouldUseHero(global: above, in: windowBounds))
    }

    func testResolverNonFiniteFrameFallsBack() {
        let infinite = CGRect(x: 10, y: 10, width: CGFloat.infinity, height: 100)
        let nan = CGRect(x: CGFloat.nan, y: 10, width: 100, height: 100)
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: infinite, in: windowBounds))
        XCTAssertNil(PhotoSliderHeroResolver.resolvedWindowFrame(global: nan, in: windowBounds))
    }

    // MARK: - PhotoSliderHeroResolver: valid frames

    func testResolverValidFramePassesThrough() {
        let valid = CGRect(x: 24, y: 120, width: 160, height: 160)
        let resolved = PhotoSliderHeroResolver.resolvedWindowFrame(global: valid, in: windowBounds)
        XCTAssertEqual(resolved, valid)
        XCTAssertTrue(PhotoSliderHeroResolver.shouldUseHero(global: valid, in: windowBounds))
    }

    func testResolverPartiallyOnScreenFrameIsUsable() {
        // Straddles the top edge but still intersects the window -> usable.
        let straddling = CGRect(x: 10, y: -40, width: 100, height: 100)
        let resolved = PhotoSliderHeroResolver.resolvedWindowFrame(global: straddling, in: windowBounds)
        XCTAssertEqual(resolved, straddling)
    }

    // MARK: - ZoomingAnimationController flag (drives delegate factory)

    @MainActor
    func testPresentControllerCarriesPresentFlag() {
        XCTAssertTrue(ZoomingAnimationController(present: true).present)
        XCTAssertFalse(ZoomingAnimationController(present: false).present)
    }

    // MARK: - PhotoSliderZoomTransitioningDelegate factory branches

    @MainActor
    func testDelegateReturnsPresentingControllerForPresented() {
        let viewer = makeViewer()
        let thumbnail = makeThumbnail()
        let delegate = PhotoSliderZoomTransitioningDelegate(
            viewer: viewer,
            presentThumbnail: thumbnail,
            dismissThumbnailProvider: { thumbnail }
        )

        let presenting = delegate.animationController(
            forPresented: viewer,
            presenting: UIViewController(),
            source: UIViewController()
        )

        let controller = try? XCTUnwrap(presenting as? ZoomingAnimationController)
        XCTAssertEqual(controller?.present, true)
    }

    @MainActor
    func testDelegateReturnsDismissingControllerForDismissed() {
        let viewer = makeViewer()
        let thumbnail = makeThumbnail()
        let delegate = PhotoSliderZoomTransitioningDelegate(
            viewer: viewer,
            presentThumbnail: thumbnail,
            dismissThumbnailProvider: { thumbnail }
        )

        let dismissing = delegate.animationController(forDismissed: viewer)

        let controller = try? XCTUnwrap(dismissing as? ZoomingAnimationController)
        XCTAssertEqual(controller?.present, false)
    }

    @MainActor
    func testDelegateFallsBackToFadeWhenDismissThumbnailIsNil() {
        let viewer = makeViewer()
        let thumbnail = makeThumbnail()
        // Mirrors "swiped to a page whose source frame is now nil/off-screen".
        let delegate = PhotoSliderZoomTransitioningDelegate(
            viewer: viewer,
            presentThumbnail: thumbnail,
            dismissThumbnailProvider: { nil }
        )

        XCTAssertNil(delegate.animationController(forDismissed: viewer))
    }

    // MARK: - swipe-vs-button dismissal flag (gates the second hero transition)

    @MainActor
    func testViewerIsNotDismissingViaSwipeByDefault() {
        // A freshly-presented viewer (and the close-button / tap dismissal path) must leave the
        // flag `false` so the hero presenter still runs the animated zoom-out on dismiss.
        // Only a vertical swipe-to-dismiss flips it to `true` (then the presenter dismisses
        // without animation, avoiding the double-dismiss blur flash).
        let viewer = makeViewer()
        XCTAssertFalse(viewer.isDismissingViaSwipe)
    }

    // MARK: - selection as the truth source for the dismiss return target

    @MainActor
    func testDismissProviderResolvesUsingCurrentSelection() {
        let viewer = makeViewer()
        let frames: [Int: CGRect] = [
            0: CGRect(x: 0, y: 100, width: 100, height: 100),
            2: CGRect(x: 200, y: 300, width: 120, height: 120),
        ]
        var currentSelection = 0

        // The provider re-reads `currentSelection` each time, exactly like the bridge reading
        // the `selection` binding at dismiss time.
        let delegate = PhotoSliderZoomTransitioningDelegate(
            viewer: viewer,
            presentThumbnail: makeThumbnail(frame: frames[0]!),
            dismissThumbnailProvider: {
                guard
                    let resolved = PhotoSliderHeroResolver.resolvedWindowFrame(
                        global: frames[currentSelection],
                        in: CGRect(x: 0, y: 0, width: 390, height: 844)
                    )
                else { return nil }
                return PhotoSliderThumbnailTransition(image: nil, windowFrame: resolved)
            }
        )

        // Page 0: returns to frame 0.
        let atPageZero = delegate.animationController(forDismissed: viewer) as? ZoomingAnimationController
        let zeroThumbnail = atPageZero?.destinationTransition as? PhotoSliderThumbnailTransition
        XCTAssertEqual(zeroThumbnail?.windowFrame, frames[0])

        // Swipe to page 2: the dismiss target follows the new selection.
        currentSelection = 2
        let atPageTwo = delegate.animationController(forDismissed: viewer) as? ZoomingAnimationController
        let twoThumbnail = atPageTwo?.destinationTransition as? PhotoSliderThumbnailTransition
        XCTAssertEqual(twoThumbnail?.windowFrame, frames[2])

        // Swipe to page 1 (no frame recorded): falls back to a fade.
        currentSelection = 1
        XCTAssertNil(delegate.animationController(forDismissed: viewer))
    }

    // MARK: - Helpers

    @MainActor
    private func makeViewer() -> PhotoSliderViewController {
        let photos = [
            PhotoItem(source: .uiImage(UIImage())),
            PhotoItem(source: .uiImage(UIImage())),
            PhotoItem(source: .uiImage(UIImage())),
        ]
        return PhotoSliderViewController(
            items: photos,
            configuration: .default,
            imageLoader: .default,
            initialPage: 0
        )
    }

    @MainActor
    private func makeThumbnail(frame: CGRect = CGRect(x: 10, y: 10, width: 100, height: 100)) -> PhotoSliderThumbnailTransition {
        PhotoSliderThumbnailTransition(image: nil, windowFrame: frame)
    }
}
