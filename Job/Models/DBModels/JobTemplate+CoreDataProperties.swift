//
//  JobTemplate+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension JobTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JobTemplate> {
        return NSFetchRequest<JobTemplate>(entityName: "JobTemplate")
    }

    @NSManaged public var lastUpdatedOn: NSDate?
    @NSManaged public var signatureRequired: NSNumber?
    @NSManaged public var templateId: String?
    @NSManaged public var templateLongDesc: String?
    @NSManaged public var templateName: String?
    @NSManaged public var templateShortDesc: String?
    @NSManaged public var templateType: String?
    @NSManaged public var instance: NSSet?
    @NSManaged public var task: NSSet?
    @NSManaged public var tempProject: Project?

}

// MARK: Generated accessors for instance
extension JobTemplate {

    @objc(addInstanceObject:)
    @NSManaged public func addToInstance(_ value: JobInstance)

    @objc(removeInstanceObject:)
    @NSManaged public func removeFromInstance(_ value: JobInstance)

    @objc(addInstance:)
    @NSManaged public func addToInstance(_ values: NSSet)

    @objc(removeInstance:)
    @NSManaged public func removeFromInstance(_ values: NSSet)

}

// MARK: Generated accessors for task
extension JobTemplate {

    @objc(addTaskObject:)
    @NSManaged public func addToTask(_ value: Task)

    @objc(removeTaskObject:)
    @NSManaged public func removeFromTask(_ value: Task)

    @objc(addTask:)
    @NSManaged public func addToTask(_ values: NSSet)

    @objc(removeTask:)
    @NSManaged public func removeFromTask(_ values: NSSet)

}
