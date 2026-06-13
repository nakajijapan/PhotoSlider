//
//  KingfisherImageLoaderTests.swift
//  PhotoSliderKingfisherTests
//

import XCTest
import PhotoSlider
@testable import PhotoSliderKingfisher

final class KingfisherImageLoaderTests: XCTestCase {

    func testInitConformsToImageLoader() {
        let loader: any ImageLoader = KingfisherImageLoader()
        XCTAssertTrue(loader is KingfisherImageLoader)
    }

    func testStaticFactory() {
        let loader = KingfisherImageLoader.kingfisher()
        XCTAssertTrue((loader as any ImageLoader) is KingfisherImageLoader)
    }
}
