//
//  ListSwiftly_UI_Tests.swift
//  ListSwiftly UI Tests
//
//  Created by Anthony Michael Fennell on 8/12/15.
//  Copyright © 2015 Ford Prefect. All rights reserved.
//

import Foundation
import XCTest

class ListSwiftly_UI_Tests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.navigationBars["Tasks"].buttons["Add"].tap()
        app.buttons["purple"].tap()
        
        let noteTextField = app.textFields["Note"]
        noteTextField.tap()
        noteTextField.typeText("toilet paper")
        app.navigationBars["Setup Task"].buttons["Tasks"].tap()
        app.alerts["Task due soon"].collectionViews.buttons["Ok"].tap()


    }
    
}
