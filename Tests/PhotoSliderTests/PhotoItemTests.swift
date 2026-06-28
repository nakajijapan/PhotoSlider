//
//  PhotoItemTests.swift
//  PhotoSliderTests
//

import XCTest
import UIKit
@testable import PhotoSlider

final class PhotoItemTests: XCTestCase {

    func testRemoteSource() {
        let url = URL(string: "https://example.com/a.jpg")!
        let item = PhotoItem(source: .remote(url), caption: "Aurora")
        XCTAssertEqual(item.source, .remote(url))
        XCTAssertEqual(item.caption, "Aurora")
    }

    func testUIImageSource() {
        let image = UIImage()
        let item = PhotoItem(source: .uiImage(image))
        XCTAssertEqual(item.source, .uiImage(image))
        XCTAssertNil(item.caption)
    }

    func testDataSource() {
        let data = Data([0x1, 0x2, 0x3])
        let item = PhotoItem(source: .data(data))
        XCTAssertEqual(item.source, .data(data))
    }

    func testEachItemHasUniqueID() {
        let url = URL(string: "https://example.com/a.jpg")!
        let a = PhotoItem(source: .remote(url))
        let b = PhotoItem(source: .remote(url))
        XCTAssertNotEqual(a.id, b.id)
    }
}
