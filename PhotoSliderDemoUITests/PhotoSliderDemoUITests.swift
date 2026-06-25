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
    /// caller fades it to `opacity 0` via `onPhotoSliderSourceVisibilityChange`)
    /// and restored — hittable again — once the dismiss animation has fully
    /// settled. Guards against the thumbnail staying invisible after close.
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
        // restored (opacity back to 1) and interactive again.
        XCTAssertTrue(firstPage.waitForExistence(timeout: 10),
                      "Carousel should be visible again after dismiss")
        let restored = expectation(for: NSPredicate(format: "isHittable == true"),
                                   evaluatedWith: firstPage)
        wait(for: [restored], timeout: 10)
    }
}
