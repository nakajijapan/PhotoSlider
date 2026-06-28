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
        XCTAssertNil(callbacks.onSourceVisibilityChange)
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
    func testSourceVisibilityChangeFires() {
        let expectation = expectation(description: "onSourceVisibilityChange")
        let collected = VisibilityCollector()
        let callbacks = PhotoSliderCallbacks(onSourceVisibilityChange: { index, isHidden in
            collected.index = index
            collected.isHidden = isHidden
            expectation.fulfill()
        })
        callbacks.onSourceVisibilityChange?(7, true)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(collected.index, 7)
        XCTAssertEqual(collected.isHidden, true)
    }

    @MainActor
    final class Collector {
        var value: Int = -1
    }

    @MainActor
    final class VisibilityCollector {
        var index: Int = -1
        var isHidden: Bool?
    }
}
