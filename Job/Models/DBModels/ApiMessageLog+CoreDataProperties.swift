//
//  ApiMessageLog+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension ApiMessageLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ApiMessageLog> {
        return NSFetchRequest<ApiMessageLog>(entityName: "ApiMessageLog")
    }

    @NSManaged public var apiName: String?
    @NSManaged public var deviceState: String?
    @NSManaged public var reqMethod: String?
    @NSManaged public var requestJson: String?
    @NSManaged public var requestTime: NSDate?
    @NSManaged public var reqURL: String?
    @NSManaged public var responseErrorCode: NSNumber?
    @NSManaged public var responseJson: String?
    @NSManaged public var responseStatus: NSNumber?
    @NSManaged public var responseTime: NSDate?
    @NSManaged public var resTimeInSec: NSNumber?
    @NSManaged public var username: String?

}
