//
//  PhotoSliderDemoUITests.swift
//  PhotoSliderDemoUITests
//
//  Launch smoke tests for the SwiftUI PhotoSlider 2.0 demo.
//

import XCTest

final class PhotoSliderDemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// The app launches without crashing and shows the carousel landing screen.
    func testLaunchShowsCarousel() throws {
        let app = XCUIApplication()
        app.launch()

        // The first carousel page (a tappable image) should be on screen.
        let firstPage = app.descendants(matching: .any)["carousel-page-0"]
        XCTAssertTrue(firstPage.waitForExistence(timeout: 10),
                      "Carousel first page should appear on launch")

        // The demo menu (route to the original four demos) is also present.
        XCTAssertTrue(app.buttons["demo-menu"].waitForExistence(timeout: 10),
                      "Demo menu button should be in the toolbar")
    }

    /// The demo menu opens the local-images demo, which renders thumbnails.
    func testOpenLocalDemo() throws {
        let app = XCUIApplication()
        app.launch()

        let menu = app.buttons["demo-menu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 10),
                      "Demo menu button should exist")
        menu.tap()

        let localCell = app.buttons["demo-Local images (uiImage)"]
        XCTAssertTrue(localCell.waitForExistence(timeout: 10),
                      "Local demo row should exist in the menu")
        localCell.tap()

        let firstThumbnail = app.buttons["thumbnail-0"]
        XCTAssertTrue(firstThumbnail.waitForExistence(timeout: 10),
                      "First thumbnail should appear in the local demo")
    }

    /// Tapping a carousel page presents the PhotoSlider viewer; the close button
    /// dismisses it and returns to the carousel. This exercises the hero (zoom)
    /// present + dismiss path end to end.
    func testCarouselPresentsAndDismisses() throws {
        let app = XCUIApplication()
        app.launch()

        let firstPage = app.descendants(matching: .any)["carousel-page-0"]
        XCTAssertTrue(firstPage.waitForExistence(timeout: 10),
                      "Carousel first page should appear on launch")

        firstPage.tap()

        let viewerScroll = app.scrollViews["PhotoSliderScrollView"]
        XCTAssertTrue(viewerScroll.waitForExistence(timeout: 10),
                      "PhotoSlider viewer should appear after tapping a page")

        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 10),
                      "Close button should exist in the viewer")
        closeButton.tap()

        XCTAssertTrue(firstPage.waitForExistence(timeout: 10),
                      "Carousel should be visible again after dismiss")
    }

    /// The hero source thumbnail is hidden while the viewer is presented (the
    /// caller fades it to `opacity 0`: synchronously on tap, then kept hidden via
    /// `onPhotoSliderSourceVisibilityChange`) and restored — tappable again — once
    /// the dismiss animation has fully settled. Guards against the thumbnail
    /// staying invisible after close.
    func testCarouselSourceThumbnailHidesAndRestores() throws {
        let app = XCUIApplication()
        app.launch()

        let firstPage = app.descendants(matching: .any)["carousel-page-0"]
        XCTAssertTrue(firstPage.waitForExistence(timeout: 10),
                      "Carousel first page should appear on launch")
        // Before presenting, the thumbnail is interactive (opacity 1).
        XCTAssertTrue(firstPage.isHittable,
                      "Carousel thumbnail should be hittable before presenting")

        firstPage.tap()

        let viewerScroll = app.scrollViews["PhotoSliderScrollView"]
        XCTAssertTrue(viewerScroll.waitForExistence(timeout: 10),
                      "PhotoSlider viewer should appear after tapping a page")
        // While presented the viewer fully covers the carousel, and the caller
        // has faded the source thumbnail to `opacity 0`, so it is not hittable.
        XCTAssertFalse(firstPage.isHittable,
                       "Source thumbnail should not be hittable while presented")

        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 10),
                      "Close button should exist in the viewer")
        closeButton.tap()

        // After the dismiss zoom-out fully settles, the source thumbnail must be
        // restored and interactive again. We verify the *real* signal — that the
        // page is tappable and re-opens the viewer — rather than `isHittable`.
        //
        // `isHittable` is unreliable for this `TabView` page element: its reported
        // accessibility frame spans the off-screen paging area (origin x ≈ -100,
        // width > screen), so once the thumbnail is faded to `opacity 0` and back
        // to `1`, XCUI's hit-test for the cached element stays `false` even though
        // the page is on screen and a real touch at its center opens the viewer.
        // (Before this fix the thumbnail was never hidden, so `isHittable` trivially
        // stayed true and never actually exercised the restore.) Re-tapping the
        // page proves the restore: the carousel is back and interactive.
        XCTAssertTrue(firstPage.waitForExistence(timeout: 10),
                      "Carousel should be visible again after dismiss")
        firstPage.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(viewerScroll.waitForExistence(timeout: 10),
                      "Restored carousel thumbnail should re-open the viewer when tapped")
    }

    /// In the Callbacks demo (`showsShareButton = true`), tapping the Share button
    /// presents the iOS share sheet (`UIActivityViewController`) for the current
    /// image, rather than only firing the `onShare` callback.
    func testSharePresentsActivitySheet() throws {
        let app = XCUIApplication()
        app.launch()

        let menu = app.buttons["demo-menu"]
        XCTAssertTrue(menu.waitForExistence(timeout: 10),
                      "Demo menu button should exist")
        menu.tap()

        let callbacksCell = app.buttons["demo-Configuration & callbacks"]
        XCTAssertTrue(callbacksCell.waitForExistence(timeout: 10),
                      "Callbacks demo row should exist in the menu")
        callbacksCell.tap()

        let firstThumbnail = app.buttons["thumbnail-0"]
        XCTAssertTrue(firstThumbnail.waitForExistence(timeout: 10),
                      "First thumbnail should appear in the callbacks demo")
        firstThumbnail.tap()

        let viewerScroll = app.scrollViews["PhotoSliderScrollView"]
        XCTAssertTrue(viewerScroll.waitForExistence(timeout: 10),
                      "PhotoSlider viewer should appear after tapping a thumbnail")

        let shareButton = app.buttons["Share"]
        XCTAssertTrue(shareButton.waitForExistence(timeout: 10),
                      "Share button should exist in the viewer")
        shareButton.tap()

        // The system share sheet (`UIActivityViewController`) presents as the
        // `ActivityListView` container with its standard activity collection view;
        // either signal proves the sheet was shown. (On iOS the activities surface
        // as cells, not buttons, so we match the container/collection identifiers.)
        let activityListView = app.otherElements["ActivityListView"]
        let activityCollectionView = app.collectionViews["activityCollectionView"]
        let appeared = activityListView.waitForExistence(timeout: 10)
            || activityCollectionView.waitForExistence(timeout: 2)
            || app.sheets.firstMatch.waitForExistence(timeout: 2)
        XCTAssertTrue(appeared,
                      "Tapping Share should present the iOS activity share sheet")
    }
}
