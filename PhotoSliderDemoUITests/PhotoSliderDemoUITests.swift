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

    /// The app launches without crashing and shows the demo list.
    func testLaunchShowsDemoList() throws {
        let app = XCUIApplication()
        app.launch()

        let list = app.collectionViews["demo-list"]
        XCTAssertTrue(list.waitForExistence(timeout: 10),
                      "Demo list should appear on launch")
    }

    /// Tapping the local-images demo navigates and renders thumbnails.
    func testOpenLocalDemo() throws {
        let app = XCUIApplication()
        app.launch()

        let localCell = app.buttons["demo-Local images (uiImage)"]
        XCTAssertTrue(localCell.waitForExistence(timeout: 10),
                      "Local demo row should exist")
        localCell.tap()

        let firstThumbnail = app.buttons["thumbnail-0"]
        XCTAssertTrue(firstThumbnail.waitForExistence(timeout: 10),
                      "First thumbnail should appear in the local demo")
    }
}
