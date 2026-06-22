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
}
