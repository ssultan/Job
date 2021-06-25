//
//  Comment+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var commentId: String?
    @NSManaged public var commentText: String?
    @NSManaged public var createdBy: String?
    @NSManaged public var createdDate: NSDate?
    @NSManaged public var flagStatus: Int16
    @NSManaged public var isComDeleted: Bool
    @NSManaged public var isFlag: Bool
    @NSManaged public var answerComment: Answer?
    @NSManaged public var instanceComment: JobInstance?
    @NSManaged public var commentServerId:Int
}
