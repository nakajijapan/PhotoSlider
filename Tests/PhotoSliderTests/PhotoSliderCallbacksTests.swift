//
//  PhotoSliderCallbacksTests.swift
//  PhotoSliderTests
//

import XCTest
@testable import PhotoSlider

final class PhotoSliderCallbacksTests: XCTestCase {

    func testEmptyInit() {
        let callbacks = PhotoSliderCallbacks()
        XCTAssertNil(callbacks.onWillDismiss)
        XCTAssertNil(callbacks.onDidDismiss)
        XCTAssertNil(callbacks.onPageChanged)
        XCTAssertNil(callbacks.onShare)
        XCTAssertNil(callbacks.onRequestDelete)
    }

    @MainActor
    func testPageChangedFires() {
        let expectation = expectation(description: "onPageChanged")
        let collected = Collector()
        let callbacks = PhotoSliderCallbacks(onPageChanged: { page in
            collected.value = page
            expectation.fulfill()
        })
        callbacks.onPageChanged?(3)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(collected.value, 3)
    }

    @MainActor
    final class Collector {
        var value: Int = -1
    }
}
