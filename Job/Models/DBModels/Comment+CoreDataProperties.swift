//
//  Comment+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 10/15/20.
//  Copyright © 2020 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var commentId: String?
    @NSManaged public var commentServerId: Int32
    @NSManaged public var commentParentId: Int32
    @NSManaged public var commentText: String?
    @NSManaged public var createdBy: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var flagStatus: Int16
    @NSManaged public var isComDeleted: Bool
    @NSManaged public var isFlag: Bool
    @NSManaged public var lastUpdatedBy: String?
    @NSManaged public var lastUpdatedOn: Date?
    @NSManaged public var answerComment: Answer?
    @NSManaged public var instanceComment: JobInstance?

}
