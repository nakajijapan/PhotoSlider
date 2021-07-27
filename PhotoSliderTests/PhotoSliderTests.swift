//
//  PhotoSliderTests.swift
//  PhotoSliderTests
//
//  Created by Daichi Nakajima on 2021/07/27.
//  Copyright © 2021 nakajijapan. All rights reserved.
//

import XCTest
import PhotoSlider

class PhotoSliderTests: XCTestCase {

    func testBundle() throws {
        let bundlePath = Bundle.main.path(
            forResource: "PhotoSlider",
            ofType: "bundle",
            inDirectory: "Frameworks/PhotoSlider.framework"
        )
        XCTAssertEqual(bundlePath, nil)
    }
    
    func testBundle2() throws {
        let bundle = Bundle(for: PhotoSlider.ViewController.self)
        let imagePath = bundle.path(forResource: "PhotoSliderClose", ofType: "png")
        XCTAssertFalse(imagePath, nil)
    }
}
