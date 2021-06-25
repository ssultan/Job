//
//  UtilitiesTest.swift
//  JobTests
//
//  Created by Saleh Sultan on 6/3/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import XCTest

class UtilitiesTest: XCTestCase {

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
    
    func testEnvironmentSetup() {
        let appInfo = AppInfo()
        appInfo.setupEnvironment(enviroment: STAGING)
        XCTAssert(appInfo.httpType == "http://")
        XCTAssert(appInfo.baseURL == "api.staging.clearthread.com")
        
        appInfo.setupEnvironment(enviroment: RELEASE)
        XCTAssert(appInfo.httpType == "https://")
        XCTAssert(appInfo.baseURL == "api.davacoinc.com")
    }

    func testTaskAnsPhotoName() {
        let today = Date();
        let todayStr = Utility.getDateStringFor(formate: "yy-MM-dd_hh:mm:ss", date: today);
        let name = Utility.generateDcoumentNameFor(projectNumber: "112445", storeNumber: "3345900", taskNumber: "1.[2].4", attribute: PhotoAttributesTypes.Center_After, documentType: Constants.JPEG_DOC_TYPE)
        XCTAssert(name == "1.[2].4_3345900_112445_CA_\(todayStr).jpeg")
    }
    
    
    func testFvPhotoName() {
        let today = Date();
        let todayStr = Utility.getDateStringFor(formate: "yy-MM-dd_hh:mm:ss", date: today);
        let name = Utility.generateDcoumentNameFor(projectNumber: "112445", storeNumber: "3345900", taskNumber: nil, attribute: PhotoAttributesTypes.Center_After, documentType: Constants.JPEG_DOC_TYPE, forDate: today)
        XCTAssert(name == "FV_3345900_112445_CA_\(todayStr).jpeg")
    }
    
    func testUpdatingDocumentName() {
        let today = Date();
        let todayStr = Utility.getDateStringFor(formate: "yy-MM-dd_hh:mm:ss", date: today);
        let newName = Utility.updateDcoumentNameFor(oldDocName: "1.[2].4_3345900_112445_CA_19-04-12_12:12:12.jpeg", documentType: Constants.JPEG_DOC_TYPE, updateDate: today)
        XCTAssert(newName == "1.[2].4_3345900_112445_CA_\(todayStr).jpeg")
    }
    
    //Will edit later.
    func testPhotoDirectory() {
        let pPath = Utility.getPhotoParentDir(imgName: "1.[2].4_3345900_112445_CA_19-04-12_12:12:12.jpeg", folderName: "1123-21-3-21-1212")
        XCTAssert(pPath == nil)
        
        let tPath = Utility.getPhotoThumbnailDir(imgName: "1.[2].4_3345900_112445_CA_19-04-12_12:12:12.jpeg", folderName: "1123-21-3-21-1212")
        XCTAssert(tPath == nil)
    }
}

