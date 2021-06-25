//
//  Document+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var attribute: String?
    @NSManaged public var attributeId: String?
    @NSManaged public var photoAttrType: String?
    @NSManaged public var comment: String?
    @NSManaged public var createdDate: NSDate?
    @NSManaged public var docServerId: String?
    @NSManaged public var docTags: String?
    @NSManaged public var documentId: String?
    @NSManaged public var exifDic: String?
    @NSManaged public var isDataNull: NSNumber?
    @NSManaged public var isNeedToSend: NSNumber?
    @NSManaged public var isPhotoDeleted: NSNumber?
    @NSManaged public var isSent: NSNumber?
    @NSManaged public var location: String?
    @NSManaged public var mimeType: String?
    @NSManaged public var name: String?
    @NSManaged public var originalName: String?
    @NSManaged public var photo180GalleryPath: String?
    @NSManaged public var photoServerURL: String?
    @NSManaged public var sentTime: NSDate?
    @NSManaged public var serverCreatedDate: NSDate?
    @NSManaged public var type: String?
    @NSManaged public var answer: Answer?
    @NSManaged public var error: ErrorLogs?
    @NSManaged public var jobInstance: JobInstance?

}
