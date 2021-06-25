//
//  JobInstance+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension JobInstance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JobInstance> {
        return NSFetchRequest<JobInstance>(entityName: "JobInstance")
    }

    @NSManaged public var completedDate: NSDate?
    @NSManaged public var instanceSentTime: NSDate?
    @NSManaged public var instId: String?
    @NSManaged public var instServerId: String?
    @NSManaged public var isCompleted: NSNumber?
    @NSManaged public var isCompleteNSend: NSNumber?
    @NSManaged public var isSent: NSNumber?
    @NSManaged public var isSentForProcessing: NSNumber?
    @NSManaged public var isSentOrUpdated: NSNumber?
    @NSManaged public var photoAckReceived: NSNumber?
    @NSManaged public var isDeletedInstance: NSNumber?
    @NSManaged public var percentCompleted: NSNumber?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var status: String?
    @NSManaged public var succPhotoUploadTime: NSDate?
    @NSManaged public var answers: NSSet?
    @NSManaged public var comments: NSSet?
    @NSManaged public var documents: NSSet?
    @NSManaged public var error: ErrorLogs?
    @NSManaged public var jobLocation: Location?
    @NSManaged public var locationId: String?
    @NSManaged public var storeNumber: String?
    @NSManaged public var jobTemplate: JobTemplate?
    @NSManaged public var manifest: Manifest?
    @NSManaged public var templateId: String?
    @NSManaged public var templateName: String? // When assignemed a template, if there is an incompleted instance; then this will help us to find ou the instance.
    @NSManaged public var lastUpdatedBy: String?
}

// MARK: Generated accessors for answers
extension JobInstance {

    @objc(addAnswersObject:)
    @NSManaged public func addToAnswers(_ value: Answer)

    @objc(removeAnswersObject:)
    @NSManaged public func removeFromAnswers(_ value: Answer)

    @objc(addAnswers:)
    @NSManaged public func addToAnswers(_ values: NSSet)

    @objc(removeAnswers:)
    @NSManaged public func removeFromAnswers(_ values: NSSet)

}

// MARK: Generated accessors for comments
extension JobInstance {

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
extension JobInstance {

    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)

    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)

    @objc(addDocuments:)
    @NSManaged public func addToDocuments(_ values: NSSet)

    @objc(removeDocuments:)
    @NSManaged public func removeFromDocuments(_ values: NSSet)

}
