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
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPushCloseButtonExample() {
        
        let app = XCUIApplication()
        app.descendantsMatchingType(XCUIElementType.Other)["rootView"].tap()

        XCTAssertEqual(app.scrollViews.matchingIdentifier("PhotoSliderScrollView").element.exists, true)
        
        app.buttons["PhotoSliderClose"].tap()

        XCTAssertEqual(app.scrollViews.matchingIdentifier("PhotoSliderScrollView").element.exists, false)
    }
    
    func testSwitchImage() {
        let app = XCUIApplication()
        app.descendantsMatchingType(XCUIElementType.Other)["rootView"].tap()
        
        let element = app.scrollViews.matchingIdentifier("PhotoSliderScrollView").elementBoundByIndex(0)
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        element.swipeRight()
        element.swipeRight()
        element.swipeRight()
        app.buttons["PhotoSliderClose"].tap()
        
        XCTAssertEqual(app.scrollViews.matchingIdentifier("PhotoSliderScrollView").element.exists, false)
        
    }
    
    func testCloseWithSwipingUpImage() {
        let app = XCUIApplication()
        app.descendantsMatchingType(XCUIElementType.Other)["rootView"].tap()
        
        let element = app.scrollViews.matchingIdentifier("PhotoSliderScrollView").elementBoundByIndex(0)
        element.swipeUp()
        
        XCTAssertEqual(app.scrollViews.matchingIdentifier("PhotoSliderScrollView").element.exists, false)
    }
    
    func testCloseWithSwipingDownImage() {
        let app = XCUIApplication()
        app.descendantsMatchingType(XCUIElementType.Other)["rootView"].tap()
        
        let element = app.scrollViews.matchingIdentifier("PhotoSliderScrollView").elementBoundByIndex(0)
        element.swipeDown()
        
        XCTAssertEqual(app.scrollViews.matchingIdentifier("PhotoSliderScrollView").element.exists, false)
    }
    
    func testRightRotation() {

        let app = XCUIApplication()
        app.otherElements["rootView"].tap()

        let element = app.scrollViews.matchingIdentifier("PhotoSliderScrollView").elementBoundByIndex(0)
        element.swipeLeft()
        element.swipeLeft()

        XCUIDevice.sharedDevice().orientation = .LandscapeRight
        XCUIDevice.sharedDevice().orientation = .PortraitUpsideDown
        XCUIDevice.sharedDevice().orientation = .LandscapeLeft
        XCUIDevice.sharedDevice().orientation = .Portrait
        app.buttons["PhotoSliderClose"].tap()
    }
    
    

}
