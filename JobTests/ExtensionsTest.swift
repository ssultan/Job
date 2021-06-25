//
//  ExtensionsTest.swift
//  JobTests
//
//  Created by Saleh Sultan on 6/3/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import XCTest

class ExtensionsTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testFindingPhotoAttrIdx(){
        XCTAssert("FV_3345900_112445_CA_19-05-24_01:02:34.jpeg".findPhotoAttrIdx() == 3)      // New Approcah
        XCTAssert("1.[2].4_3345900_112445_CA_19-05-24_01:02:34.jpeg".findPhotoAttrIdx() == 3) // New Approach
        XCTAssert("1.[2].4_112445_CA_19-05-24_01:02:34.jpeg".findPhotoAttrIdx() == 2)         // Old Approach
        XCTAssert("Custome Name".findPhotoAttrIdx() == -1)
        XCTAssert("Custome Name_Testing_AD_Test nai".findPhotoAttrIdx() == 2)
    }
}
