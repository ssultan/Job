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
    
    
    class func insertNewPhoto(documentModel: DocumentModel) {
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
        document.attributeId = documentModel.attributeId
        document.photoAttrType = documentModel.photoAttrType
        document.createdDate = documentModel.createdDate
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
        
        // From next version we will use 'photoAttrType'
        if documentModel.attribute! == PhotoAttributesTypes.FieldVisit.rawValue {
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
        document.createdDate = documentModel.createdDate
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
        
        if let documents = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "jobInstance.instId = %@", instanceId)) as? [Document]
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
        let predicate = NSPredicate(format: "isNeedToSend = %@ AND isSent = %@  AND isPhotoDeleted = %@ AND (jobInstance.manifest.user.userName = %@ OR jobAnswer.jobInstance.instManifest.userName = %@)", NSNumber(value: true), NSNumber(value: false), NSNumber(value: false), AppInfo.sharedInstance.username, AppInfo.sharedInstance.username)
        
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
                "AND (isSent = %@ OR (isSent = %@ AND isNeedToSend = %@))", instId, instId, NSNumber(value: false), NSNumber(value: false),
                                                                            NSNumber(value: true), NSNumber(value: true))
            
            return self.countFetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, fetchByPredicate: predicate)
        }
        return 0
    }
    
    
    class func updateBatchDocuments(jobInst: JobInstanceModel, propertiesToUpdate: [AnyHashable: Any]) {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        if let instId = jobInst.instId {
            _ = self.updateData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, fetchByPredicate: NSPredicate(format: "(jobInstance.instId = %@ OR answer.jobInstance.instId = %@) AND isSent = %@", instId, instId, NSNumber(value: false)), propertiesToUpdate: propertiesToUpdate)
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
            if let document = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "documentId = %@", documentModel.documentId ?? "")).first as? Document
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
                    document.serverCreatedDate = docCreatedDate
                }
                if let sentTime = documentModel.sentTime {
                    document.sentTime = sentTime
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
        
        if let document = self.fetchData(managedObjContext, entityName:Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "documentId = %@", docModel.documentId!)).first as? Document {
            
            return document
        }
        return nil
    }
    
    class func getAllDocuments(forInstance instance: JobInstanceModel) -> [DocumentModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        var doclist = [DocumentModel]()
        if let instId = instance.instId {
            let predicate = NSPredicate(format: "(jobInstance.instId = %@ OR answer.jobInstance.instId = %@) AND isSent = %@ AND isPhotoDeleted = %@", instId, instId, NSNumber(value: true), NSNumber(value: false))
            
            if let documents = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [Document] {
                
                for doc in documents {
                    doclist.append(DocumentModel(document: doc))
                }
            }
        }
        return doclist
    }
    
    class func getAllDocuments(forAnswer answer: AnswerModel) -> [DocumentModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        var doclist = [DocumentModel]()
        if let ansId = answer.ansId {
            let predicate = NSPredicate(format: "answer.ansId = %@", ansId)
            
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
        
        let predicate = NSPredicate(format: "originalName = %@", documentName)
        
        if let _ = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.DocumentEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate).first {
            return true
        }
        return false
    }
}
