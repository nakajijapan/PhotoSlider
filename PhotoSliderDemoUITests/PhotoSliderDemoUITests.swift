//
//  PhotoSliderDemoUITests.swift
//  PhotoSliderDemoUITests
//
//  Created by nakajijapan on 2015/09/23.
//  Copyright © 2015 net.nakajijapan. All rights reserved.
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
        
        XCUIApplication().terminate()
    }
    
    func existsPhotoSliderScrollView(app: XCUIApplication) {

        sleep(1)
        XCTAssertEqual(app.scrollViews.matching(identifier: "PhotoSliderScrollView").element.exists, false)

    }
    
    func testPushCloseButtonExample() {
        
        let app = XCUIApplication()
        app.otherElements["rootView"].tap()
        sleep(1)
        XCTAssertEqual(app.scrollViews.matching(identifier: "PhotoSliderScrollView").element.exists, true)
        
        app.buttons["PhotoSliderClose"].tap()
        
        self.existsPhotoSliderScrollView(app: app)
    }
    
    func testSwitchImage() {
        let app = XCUIApplication()
        app.otherElements["rootView"].tap()
        
        let element = app.scrollViews.matching(identifier: "PhotoSliderScrollView").element(boundBy: 0)
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        element.swipeRight()
        element.swipeRight()
        element.swipeRight()
        app.buttons["PhotoSliderClose"].tap()
        
        self.existsPhotoSliderScrollView(app: app)
    }
    
    func testCloseWithSwipingUpImage() {
        let app = XCUIApplication()
        app.otherElements["rootView"].tap()
        
        let element = app.scrollViews.matching(identifier: "PhotoSliderScrollView").element(boundBy: 0)
        element.swipeUp()
        
        self.existsPhotoSliderScrollView(app: app)
    }
    
    func testCloseWithSwipingDownImage() {
        let app = XCUIApplication()
        app.otherElements["rootView"].tap()
        
        let element = app.scrollViews.matching(identifier: "PhotoSliderScrollView").element(boundBy: 0)
        element.swipeDown()
        
        self.existsPhotoSliderScrollView(app: app)
    }
    
    func testRightRotation() {

        let app = XCUIApplication()
        app.otherElements["rootView"].tap()

        let element = app.scrollViews.matching(identifier: "PhotoSliderScrollView").element(boundBy: 0)
        element.swipeLeft()
        element.swipeLeft()

        XCUIDevice.shared.orientation = .landscapeRight
        XCUIDevice.shared.orientation = .portraitUpsideDown
        XCUIDevice.shared.orientation = .landscapeLeft
        XCUIDevice.shared.orientation = .portrait
        app.buttons["PhotoSliderClose"].tap()
    }
    
    func testZooming() {
        XCUIDevice.shared.orientation = .portrait
        
        let app = XCUIApplication()
        app.otherElements["rootView"].tap()

        let element = app.scrollViews.matching(identifier: "PhotoSliderScrollView").element(boundBy: 0)
        element.doubleTap()
        element.swipeUp()
        element.swipeDown()
        element.doubleTap()
        app.buttons["PhotoSliderClose"].tap()
        
        self.existsPhotoSliderScrollView(app: app)

    }
}
