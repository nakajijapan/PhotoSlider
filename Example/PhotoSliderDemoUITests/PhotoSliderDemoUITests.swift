//
//  PhotoSliderDemoUITests.swift
//  PhotoSliderDemoUITests
//
//  Created by nakajijapan on 2015/09/23.
//  Copyright © 2015年 net.nakajijapan. All rights reserved.
//

import XCTest

class PhotoSliderDemoUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
