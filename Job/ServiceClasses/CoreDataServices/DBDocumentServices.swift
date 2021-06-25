//
//  DBDocumentServices.swift
//  Job V2
//
//  Created by Saleh Sultan on 1/15/18.
//  Copyright © 2018 Clearthread. All rights reserved.
//

import UIKit
import CoreData

class DBDocumentServices: CoreDataBusiness {
    
    class func insertNewPhoto(documentModel: DocumentModel, isAddedByOtherUser otherTaken:Bool = false) -> Bool{
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        if let localDoc = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "documentId = %@ AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", documentModel.documentId ?? "", AppInfo.sharedInstance.username!, AppInfo.sharedInstance.username!)).first as? Document
        {
            localDoc.docServerId = documentModel.docServerId
            localDoc.photoServerURL = documentModel.photoServerURL
            do {
                try managedObjectContext.save()
            } catch {
                print("Failed to update the document: \(error)")
            }
            return false
        }
        
        let document = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.DocumentEntity, into: managedObjectContext) as! Document
        document.name = documentModel.name
        document.originalName = documentModel.originalName
        document.comment = documentModel.comment
        document.isSent = documentModel.isSent
        document.type = documentModel.type
        document.documentId = documentModel.documentId
        document.mimeType = documentModel.mimeType
        document.attribute = documentModel.attribute
        document.attributeId = documentModel.attributeId
        document.photoAttrType = documentModel.photoAttrType
        document.createdDate = documentModel.createdDate as Date?
        document.isNeedToSend = documentModel.isNeedToSend
        document.isPhotoDeleted = documentModel.isPhotoDeleted
        document.isDataNull = documentModel.isDataNull ?? NSNumber(value: false)
        document.answer = documentModel.documentAnswer
        document.jobInstance = documentModel.documentInstance
        document.photoServerURL = documentModel.photoServerURL
        document.isAddedByOthers = otherTaken
        document.docServerId = documentModel.docServerId
        //if let instane = documentModel.documentInstance {} else {}
        
        if let dic = documentModel.exifDic {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                if let dicStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String? {
                    document.exifDic = dicStr
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        do {
            try managedObjectContext.save()
            return true
        } catch {
            print("Failed to save the document : \(error)")
            return false
        }
    }
    
    class func saveComment(forCommentObj commentModel: CommentModel) -> Bool {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let comment = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.CommentEntity, into: managedObjContext) as! Comment
        comment.commentId = commentModel.commentId
        comment.commentServerId = Int32(commentModel.commentServerId)
        comment.instanceComment = commentModel.instanceComment
        comment.createdDate = commentModel.createdDate as Date?
        comment.createdBy = commentModel.createdBy
        comment.commentText = commentModel.commentText
        comment.answerComment = commentModel.answerComment
        comment.lastUpdatedBy = commentModel.lastUpdatedBy
        comment.lastUpdatedOn = commentModel.lastUpdatedOn
        do {
            try managedObjContext.save()
            return true
        } catch {
            print("Failed to insert instance.")
            return false
        }
    }
    
    
    class func addDocument(documentModel: DocumentModel, documentType: PhotoAttributesTypes) {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        let document = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.DocumentEntity, into: managedObjectContext) as! Document
        document.name = documentModel.name
        document.originalName = documentModel.originalName
        document.comment = documentModel.comment
        document.isSent = documentModel.isSent
        document.type = documentModel.type
        document.documentId = documentModel.documentId
        document.mimeType = documentModel.mimeType
        document.attribute = documentModel.attribute
        document.attributeId = documentType.rawValue.getAttributeId()
        document.createdDate = documentModel.createdDate as Date?
        document.isNeedToSend = documentModel.isNeedToSend
        document.isPhotoDeleted = documentModel.isPhotoDeleted
        document.isDataNull = documentModel.isDataNull ?? NSNumber(value: false)
        
        if let dic = documentModel.exifDic {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                
                if let dicStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String? {
                    document.exifDic = dicStr
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        if documentType == .FieldVisit || documentType == .Signature {
            if let surveyIns = AppInfo.sharedInstance.selJobInstance.dbRawInstanceObj as? JobInstance {
                document.jobInstance = surveyIns
            }
        }
        else if let answer = JobVisitModel.sharedInstance.answer.dbRawAnsObj as? Answer {
            document.answer = answer
        }
        
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save the document : \(error)")
        }
    }
    
    class func markAllDocumentsAsNotSent(forInstance instanceId: String) {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        if let documents = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "jobInstance.instId = %@ AND jobInstance.manifest.user.userName = %@", instanceId, AppInfo.sharedInstance.username!)) as? [Document]
        {
            for document in documents {
                document.isSent = NSNumber(value: false)
            }
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to update the document: \(error)")
        }
    }
    
    // Mainly instance update request, if there is any documents left to sent to server
    class func getAllDocumentsThatNeedsToSend() -> [DocumentModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isNeedToSend = %@ AND isSent = %@  AND isPhotoDeleted = %@ AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", NSNumber(value: true), NSNumber(value: false), NSNumber(value: false), AppInfo.sharedInstance.username, AppInfo.sharedInstance.username)
        
        var docList = [DocumentModel]()
        if let documentList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [Document] {
            
            for document in documentList {
                docList.append(DocumentModel(document: document))
            }
        }
        return docList
    }
    
    // To count number of total photos system need to send for a specific instance
    class func countDocumentsThatNeedsToSendForInstnace(instance: JobInstanceModel) -> Int {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        if let instId = instance.instId {
            let predicate = NSPredicate(format: "(jobInstance.instId = %@ OR answer.jobInstance.instId = %@) AND isPhotoDeleted = %@" +
                                            "AND (isSent = %@ OR (isSent = %@ AND isNeedToSend = %@)) AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", instId, instId, NSNumber(value: false), NSNumber(value: false), NSNumber(value: true), NSNumber(value: true), AppInfo.sharedInstance.username!, AppInfo.sharedInstance.username!)
            
            return self.countFetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, fetchByPredicate: predicate)
        }
        return 0
    }
    
    
    class func updateBatchDocuments(jobInst: JobInstanceModel, propertiesToUpdate: [AnyHashable: Any]) {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        if let instId = jobInst.instId {
            _ = self.updateData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, fetchByPredicate: NSPredicate(format: "(jobInstance.instId = %@ OR answer.jobInstance.instId = %@) AND isSent = %@ AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", instId, instId, NSNumber(value: false), AppInfo.sharedInstance.username!, AppInfo.sharedInstance.username!), propertiesToUpdate: propertiesToUpdate)
        }
    }
    
    
    class func getAllDocumentsThoseAreDeleted() -> [DocumentModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isSent = %@ AND isPhotoDeleted = %@ AND (jobInstance.photoAckReceived = %@ OR answer.jobInstance.photoAckReceived = %@) AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", NSNumber(value: true), NSNumber(value: true), NSNumber(value: true), NSNumber(value: true), AppInfo.sharedInstance.username ?? "", AppInfo.sharedInstance.username ?? "")
        
        var docList = [DocumentModel]()
        if let documentList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate, fetchLimit: 5) as? [Document] {
            
            for document in documentList {
                docList.append(DocumentModel(document: document))
            }
        }
        return docList
    }
    
    class func updateDocument(documentModel: DocumentModel) {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        managedObjectContext.perform {
            if let document = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "documentId = %@ AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", documentModel.documentId ?? "", AppInfo.sharedInstance.username!, AppInfo.sharedInstance.username!)).first as? Document
            {
                if let docServerId = documentModel.docServerId {
                    document.docServerId = docServerId
                }
                if document.name != documentModel.name {
                    document.name = documentModel.name
                }
                if document.comment != documentModel.comment {
                    document.comment = documentModel.comment
                }
                if document.docTags != documentModel.docTags {
                    document.docTags = documentModel.docTags
                }
                if document.originalName != documentModel.originalName {
                    document.originalName = documentModel.originalName
                }
                if document.attribute != documentModel.attribute || document.attributeId != documentModel.attributeId {
                    document.attribute = documentModel.attribute
                    document.attributeId = documentModel.attributeId
                }
                if document.isSent != documentModel.isSent {
                    document.isSent = documentModel.isSent
                }
                if document.isPhotoDeleted != documentModel.isPhotoDeleted {
                    document.isPhotoDeleted = documentModel.isPhotoDeleted
                }
                if let isNeedToSend = document.isNeedToSend, let instDocNeedToSend = documentModel.isNeedToSend {
                    if isNeedToSend != instDocNeedToSend {
                        document.isNeedToSend = documentModel.isNeedToSend
                    }
                }
                if let docServerURL = documentModel.photoServerURL {
                    document.photoServerURL = docServerURL
                }
                if let docCreatedDate = documentModel.serverCreatedDate {
                    document.serverCreatedDate = docCreatedDate as Date
                }
                if let sentTime = documentModel.sentTime {
                    document.sentTime = sentTime as Date
                }
                document.isDataNull = documentModel.isDataNull ?? NSNumber(value: false)
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print("Failed to update the document: \(error)")
                }
            }
        }
    }
    
    class func getDocument(ForDocModel docModel:DocumentModel) -> Document? {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        
        if let document = self.fetchData(managedObjContext, entityName:Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "documentId = %@ AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", docModel.documentId!, AppInfo.sharedInstance.username!, AppInfo.sharedInstance.username!)).first as? Document {
            
            return document
        }
        return nil
    }
    
    class func getAllDocuments(forInstance instance: JobInstanceModel) -> [DocumentModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        var doclist = [DocumentModel]()
        if let instId = instance.instId {
            let predicate = NSPredicate(format: "(jobInstance.instId = %@ OR answer.jobInstance.instId = %@) AND isSent = %@ AND isPhotoDeleted = %@ AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", instId, instId, NSNumber(value: true), NSNumber(value: false), AppInfo.sharedInstance.username!, AppInfo.sharedInstance.username!)
            
            if let documents = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [Document] {
                
                for doc in documents {
                    doclist.append(DocumentModel(document: doc))
                }
            }
        }
        return doclist
    }
    
    class func getDocumentList(forInstanceId instanceId: String) -> [DocumentModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        var doclist = [DocumentModel]()
        let predicate = NSPredicate(format: "(jobInstance.instId = %@ OR answer.jobInstance.instId = %@) AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", instanceId, instanceId, AppInfo.sharedInstance.username!, AppInfo.sharedInstance.username!)
        
        if let documents = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [Document] {
            
            for doc in documents {
                doclist.append(DocumentModel(document: doc))
            }
        }
        return doclist
    }
    
    class func getAllDocuments(forAnswer answer: AnswerModel) -> [DocumentModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        var doclist = [DocumentModel]()
        if let ansId = answer.ansId {
            let predicate = NSPredicate(format: "answer.ansId = %@ AND answer.jobInstance.manifest.user.userName = %@", ansId, AppInfo.sharedInstance.username!)
            
            if let documents = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [Document] {
                
                for doc in documents {
                    doclist.append(DocumentModel(document: doc))
                }
            }
        }
        return doclist
    }
    
    class func isDocumentAvailInDb(documentName:String)->Bool {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        let predicate = NSPredicate(format: "originalName = %@ AND (jobInstance.manifest.user.userName = %@ OR answer.jobInstance.manifest.user.userName = %@)", documentName, AppInfo.sharedInstance.username!, AppInfo.sharedInstance.username!)
        
        if let _ = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate).first {
            return true
        }
        return false
    }
}
