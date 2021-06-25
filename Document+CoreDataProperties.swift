//
//  Document+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 10/9/20.
//  Copyright © 2020 Davaco Inc. All rights reserved.
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
    @NSManaged public var comment: String?
    @NSManaged public var createdDate: Date?
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
    @NSManaged public var photoAttrType: String?
    @NSManaged public var photoServerURL: String?
    @NSManaged public var sentTime: Date?
    @NSManaged public var serverCreatedDate: Date?
    @NSManaged public var type: String?
    @NSManaged public var isAddedByOthers: Bool
    @NSManaged public var answer: Answer?
    @NSManaged public var error: ErrorLogs?
    @NSManaged public var jobInstance: JobInstance?

}
