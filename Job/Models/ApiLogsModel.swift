//
//  ApiLogsModel.swift
//  Job V2
//
//  Created by Saleh Sultan on 4/4/18.
//  Copyright © 2018 Clearthread. All rights reserved.
//

import UIKit

class ApiLogsModel: NSObject {
    @objc dynamic var resTimeInSec: NSNumber?
    @objc dynamic var apiName: String?
    @objc dynamic var reqURL: String?
    @objc dynamic var reqMethod: String?
    @objc dynamic var requestJson: String = ""
    @objc dynamic var requestTime: NSDate?
    @objc dynamic var responseErrorCode: NSNumber?
    @objc dynamic var responseJson: String = ""
    @objc dynamic var responseStatus: NSNumber?
    @objc dynamic var responseTime: NSDate?
    @objc dynamic var username: String?
}
