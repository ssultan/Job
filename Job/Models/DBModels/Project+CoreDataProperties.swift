//
//  Project+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var customerId: NSNumber?
    @NSManaged public var customerName: String?
    @NSManaged public var lastUpdatedOn: NSDate?
    @NSManaged public var programId: NSNumber?
    @NSManaged public var programName: String?
    @NSManaged public var projectDesc: String?
    @NSManaged public var projectId: String?
    @NSManaged public var projectName: String?
    @NSManaged public var projectNumber: String?
    @NSManaged public var jobTemplate: NSSet?
    @NSManaged public var location: NSSet?
    @NSManaged public var manifest: Manifest?

}

// MARK: Generated accessors for jobTemplate
extension Project {

    @objc(addJobTemplateObject:)
    @NSManaged public func addToJobTemplate(_ value: JobTemplate)

    @objc(removeJobTemplateObject:)
    @NSManaged public func removeFromJobTemplate(_ value: JobTemplate)

    @objc(addJobTemplate:)
    @NSManaged public func addToJobTemplate(_ values: NSSet)

    @objc(removeJobTemplate:)
    @NSManaged public func removeFromJobTemplate(_ values: NSSet)

}

// MARK: Generated accessors for location
extension Project {

    @objc(addLocationObject:)
    @NSManaged public func addToLocation(_ value: Location)

    @objc(removeLocationObject:)
    @NSManaged public func removeFromLocation(_ value: Location)

    @objc(addLocation:)
    @NSManaged public func addToLocation(_ values: NSSet)

    @objc(removeLocation:)
    @NSManaged public func removeFromLocation(_ values: NSSet)

}
