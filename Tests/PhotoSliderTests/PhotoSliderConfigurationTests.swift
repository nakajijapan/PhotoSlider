//
//  PhotoSliderConfigurationTests.swift
//  PhotoSliderTests
//

import XCTest
import SwiftUI
@testable import PhotoSlider

final class PhotoSliderConfigurationTests: XCTestCase {

    func testDefaults() {
        let config = PhotoSliderConfiguration.default
        XCTAssertEqual(config.backgroundColor, .black)
        XCTAssertTrue(config.showsPageIndicator)
        XCTAssertTrue(config.showsCloseButton)
        XCTAssertFalse(config.showsShareButton)
        XCTAssertTrue(config.showsCaption)
        XCTAssertTrue(config.enableSwipeToDismiss)
        XCTAssertTrue(config.enablePinchToZoom)
        XCTAssertEqual(config.maxZoomScale, 3.0)
        // Matches v1.5.0's "40% of screen height" dismiss distance.
        XCTAssertEqual(config.dismissProgressThreshold, 0.4, accuracy: 0.0001)
    }

    func testDefaultEqualsInit() {
        XCTAssertEqual(PhotoSliderConfiguration.default, PhotoSliderConfiguration())
    }

    func testEquatable() {
        var a = PhotoSliderConfiguration()
        let b = PhotoSliderConfiguration()
        XCTAssertEqual(a, b)
        a.maxZoomScale = 5.0
        XCTAssertNotEqual(a, b)
    }
}
