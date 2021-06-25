//
//  Location+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 7/26/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var address: String?
    @NSManaged public var city: String?
    @NSManaged public var jobInstanceCount: Int16
    @NSManaged public var latitude: String?
    @NSManaged public var locationDesc: String?
    @NSManaged public var locationId: String?
    @NSManaged public var locationName: String?
    @NSManaged public var longitude: String?
    @NSManaged public var state: String?
    @NSManaged public var storeId: String?
    @NSManaged public var storeNumber: String?
    @NSManaged public var zipCode: String?
    @NSManaged public var jobInstance: NSSet?
    @NSManaged public var project: Project?

}

// MARK: Generated accessors for jobInstance
extension Location {

    @objc(addJobInstanceObject:)
    @NSManaged public func addToJobInstance(_ value: JobInstance)

    @objc(removeJobInstanceObject:)
    @NSManaged public func removeFromJobInstance(_ value: JobInstance)

    @objc(addJobInstance:)
    @NSManaged public func addToJobInstance(_ values: NSSet)

    @objc(removeJobInstance:)
    @NSManaged public func removeFromJobInstance(_ values: NSSet)

}
