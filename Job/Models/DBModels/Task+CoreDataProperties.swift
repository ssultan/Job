//
//  Task+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var accuracy: NSNumber?
    @NSManaged public var documentType: String?
    @NSManaged public var documentTypeId: NSNumber?
    @NSManaged public var hasChildren: NSNumber?
    @NSManaged public var ordinal: String?
    @NSManaged public var photoRequired: NSNumber?
    @NSManaged public var required: NSNumber?
    @NSManaged public var weight: Int16
    @NSManaged public var taskDesc: String?
    @NSManaged public var taskId: String?
    @NSManaged public var taskNo: String?
    @NSManaged public var taskTitle: String?
    @NSManaged public var taskType: String?
    @NSManaged public var taskTypeId: String?
    @NSManaged public var toolTip: String?
    @NSManaged public var answer: NSSet?
    @NSManaged public var jobTemplate: JobTemplate?
    @NSManaged public var parentTask: Task?
    @NSManaged public var subTask: NSSet?
    @NSManaged public var isActive: NSNumber?
    @NSManaged public var allowNA: NSNumber?
}

// MARK: Generated accessors for answer
extension Task {

    @objc(addAnswerObject:)
    @NSManaged public func addToAnswer(_ value: Answer)

    @objc(removeAnswerObject:)
    @NSManaged public func removeFromAnswer(_ value: Answer)

    @objc(addAnswer:)
    @NSManaged public func addToAnswer(_ values: NSSet)

    @objc(removeAnswer:)
    @NSManaged public func removeFromAnswer(_ values: NSSet)

}

// MARK: Generated accessors for subTask
extension Task {

    @objc(addSubTaskObject:)
    @NSManaged public func addToSubTask(_ value: Task)

    @objc(removeSubTaskObject:)
    @NSManaged public func removeFromSubTask(_ value: Task)

    @objc(addSubTask:)
    @NSManaged public func addToSubTask(_ values: NSSet)

    @objc(removeSubTask:)
    @NSManaged public func removeFromSubTask(_ values: NSSet)

}
