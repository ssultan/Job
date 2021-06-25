//
//  Answer+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Answer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Answer> {
        return NSFetchRequest<Answer>(entityName: "Answer")
    }

    @NSManaged public var ansId: String?
    @NSManaged public var taskId: String?
    @NSManaged public var ansServerId: String?
    @NSManaged public var endDate: NSDate?
    @NSManaged public var flagStatus: NSNumber?
    @NSManaged public var isCompleted: NSNumber?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var taskType: String?
    @NSManaged public var value: String?
    @NSManaged public var comments: NSSet?
    @NSManaged public var documents: NSSet?
    @NSManaged public var jobInstance: JobInstance?
    @NSManaged public var task: Task?
    @NSManaged public var isAnsChanged: NSNumber?
    @NSManaged public var docCountInServer: NSNumber?
}

// MARK: Generated accessors for comments
extension Answer {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}

// MARK: Generated accessors for documents
extension Answer {

    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)

    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)

    @objc(addDocuments:)
    @NSManaged public func addToDocuments(_ values: NSSet)

    @objc(removeDocuments:)
    @NSManaged public func removeFromDocuments(_ values: NSSet)

}
