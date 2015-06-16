//
//  PhotoSliderDemoUITests.swift
//  PhotoSliderDemoUITests
//
//  Created by nakajijapan on 6/16/15.
//  Copyright © 2015 net.nakajijapan. All rights reserved.
//

import Foundation
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
    
    func testPushCloseButtonExample() {

        let app = XCUIApplication()
        app.descendantsMatchingType(.Unknown)["rootView"].tap()
        app.buttons["PhotoSliderClose"].tap()

        XCTAssertEqual(app.collectionViews.matchingIdentifier("PhotoSliderCollectionView").element.exists, false)
    }
    
    func testSwitchImage() {
        let app = XCUIApplication()
        app.descendantsMatchingType(.Unknown)["rootView"].tap()

        //let element = app.windows.childrenMatchingType(.Unknown).elementAtIndex(1).childrenMatchingType(.Unknown).elementAtIndex(0)
        let element = app.collectionViews.cells.elementAtIndex(0)
        element.swipeLeft()
        element.swipeLeft()
        element.swipeLeft()
        element.swipeRight()
        element.swipeRight()
        element.swipeRight()
        app.buttons["PhotoSliderClose"].tap()
        
        XCTAssertEqual(app.collectionViews.matchingIdentifier("PhotoSliderCollectionView").element.exists, false)

    }
    
    func testCloseWithSwipingUpImage() {
        let app = XCUIApplication()
        app.descendantsMatchingType(.Unknown)["rootView"].tap()
        
        let element = app.collectionViews.cells.elementAtIndex(0)
        element.swipeUp()
        
        XCTAssertEqual(app.collectionViews.matchingIdentifier("PhotoSliderCollectionView").element.exists, false)
    }
    
    func testCloseWithSwipingDownImage() {
        let app = XCUIApplication()
        app.descendantsMatchingType(.Unknown)["rootView"].tap()
        
        let element = app.collectionViews.cells.elementAtIndex(0)
        element.swipeDown()
        
        XCTAssertEqual(app.collectionViews.matchingIdentifier("PhotoSliderCollectionView").element.exists, false)
    }
}
