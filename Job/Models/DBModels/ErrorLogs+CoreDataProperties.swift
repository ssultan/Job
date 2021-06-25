//
//  ErrorLogs+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension ErrorLogs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErrorLogs> {
        return NSFetchRequest<ErrorLogs>(entityName: "ErrorLogs")
    }

    @NSManaged public var errorCode: Int64
    @NSManaged public var errorMsg: String?
    @NSManaged public var lastErrorDate: NSDate?
    @NSManaged public var totalCounted: NSNumber?
    @NSManaged public var documentError: Document?
    @NSManaged public var instanceError: JobInstance?

}
