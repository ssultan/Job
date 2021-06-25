//
//  JobServices.swift
//  Job
//
//  Created by Saleh Sultan on 5/29/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class JobServices: NSObject {
    class func isResizePhoto(photoType: String) -> Bool {
        // From next version we will use 'photoAttrType'
        if photoType != PhotoAttributesTypes.FieldVisit.rawValue, let resId = JobVisitModel.sharedInstance.task.documentTypeId {
            if Int(truncating: resId) == ResolutionType.HDPhoto.getResolutionId() || Int(truncating: resId) == ResolutionType.Pano180Photo.getResolutionId() || Int(truncating: resId) == ResolutionType.SphericalPhoto.getResolutionId() {
                return false
            }
        }
        return true
    }
    
    class func saveImageNew(image: UIImage, documentObj: DocumentModel) -> DocumentModel? {
        
        if let imgData = Utility.savePhotoInDocumentDirectoryNew(photo: image, documentObj: documentObj, lossyData: isResizePhoto(photoType: documentObj.attribute!)){
            Utility.saveThumbnailPhoto(withPhotoName: documentObj.originalName ?? "Unknown", withImage: image, folderName: documentObj.instanceId!)
            
            if let dic = Utility.getMetaDataFromImgData(imgData: imgData as NSData) {
                documentObj.exifDic = dic
            }
            DBDocumentServices.insertNewPhoto(documentModel: documentObj)
        } else {
            return nil
        }
        // From next version we will use 'photoAttrType'
        if documentObj.attribute == PhotoAttributesTypes.FieldVisit.rawValue  {
            AppInfo.sharedInstance.selJobInstance.documents.append(documentObj)
        }
        else {
            if let answer = JobVisitModel.sharedInstance.answer {
                documentObj.resolutionId = Int(truncating: answer.task.documentTypeId ?? 1)
                documentObj.resolution = answer.task.documentType ?? "Default"
                documentObj.answerId = answer.ansId
            }
            JobVisitModel.sharedInstance.answer.ansDocuments.append(documentObj)
        }
        
        return documentObj
    }
    
    class func saveUpdateSignature(image: UIImage, documentObj: DocumentModel, isUpdatingSign: Bool = false) -> DocumentModel? {
        let instance = createInstanceObjectIfNotAvilable()
        var docIndex = 0
        var oldDocName = ""
        var isSignatureAvailable = false
        
        for document in instance.documents {
            if document.type == Constants.DocSignatureType {
                
                oldDocName = document.name!
                if isUpdatingSign {
                    if (DBJobInstanceServices.removeDocument(documentId: document.documentId!)) {
                        if (Utility.deleteImageFromDocumentDirectory(docName: document.name!, folderName: document.instanceId ?? "")) {
                            instance.documents.remove(at: docIndex)
                        }
                    }
                } else {
                    documentObj.documentId = document.documentId
                    isSignatureAvailable = true
                }
                break
            }
            docIndex += 1
        }
        
        if !isUpdatingSign {
            if documentObj.originalName! != oldDocName {
                if !Utility.renameFileInAppDocDirectory(oldImgName: oldDocName, newImgName: documentObj.originalName!, folderName: documentObj.instanceId!) {
                    print("Failed to rename the photo to it's new Path.")
                }
            }
        } else {
            if Utility.saveDocumentInDocumentDirectory(image: image, docName: documentObj.originalName!, folderName: documentObj.instanceId!) == nil {
                return nil
            }
        }
        
        if isSignatureAvailable {
            DBDocumentServices.updateDocument(documentModel: documentObj)
            AppInfo.sharedInstance.selJobInstance.removeDocumentFromInst(documentId: documentObj.documentId!)
        } else {
            documentObj.documentId = UUID().uuidString
            DBDocumentServices.addDocument(documentModel: documentObj, documentType: PhotoAttributesTypes.Signature)
        }
        AppInfo.sharedInstance.selJobInstance.documents.append(documentObj)
        return documentObj
    }
    
    
    class func createInstanceObjectIfNotAvilable() -> JobInstanceModel {
        let instance = AppInfo.sharedInstance.selJobInstance
        if instance?.instId == nil {
            instance?.startDate = NSDate()
            let instanceRawObj = DBJobInstanceServices.insertNewJobInstance(jobInstance: instance!)
            instance?.dbRawInstanceObj = instanceRawObj
            instance?.instId = instanceRawObj.instId
        }
        return instance!
    }
    
    @objc class func updateDocument(document: DocumentModel) {
        DBDocumentServices.updateDocument(documentModel: document)
    }
    
    class func updateJobInstance(jobInstance: JobInstanceModel) {
        DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
    }
    
    class func completeNSendInstUpdate(jobInstance: JobInstanceModel) {
        // Remove all the orphane answers when user mark it as completed.
        // For configurable task, we keep all the answers until user mark the survey as completed and send.
        for ansModel in jobInstance.orphaneAnsModels {
            ansModel.removeAnswer()
        }
        
        jobInstance.completedDate = NSDate()
        jobInstance.instanceSentTime = NSDate()
        jobInstance.isCompleted = NSNumber(value: true)
        jobInstance.isSentForProcessing = NSNumber(value: true)
        jobInstance.isCompleteNSend = NSNumber(value: true)
        jobInstance.isSentOrUpdated = NSNumber(value: true)
        jobInstance.status = StringConstants.StatusMessages.SendingJob
        DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
    }
    
    class func removeDocument(docId: String) -> Bool{
        // remove document from local database.
        return (DBJobInstanceServices.removeDocument(documentId: docId))
    }
    
    
    class func loadJobInstance(isCompleted: Bool, currentList:[JobInstanceModel]) -> [JobInstanceModel] {
        return DBJobInstanceServices.loadAllJobInstance(isCompleteInst: isCompleted, existingInst: currentList)
    }
    
    class func loadJobInstance(isCompleted: Bool, completion:(_ instances: [JobInstanceModel])->()) {
        completion(DBJobInstanceServices.loadAllJobInstance(isCompleteInst: isCompleted))
    }
    
    class func loadJobInstanceCounter(isCompleted: Bool) -> Int {
        return DBJobInstanceServices.loadAllJobInstanceCounter(isCompleteInst: isCompleted)
    }
    
    class func getTransmitReportCounter() -> String {
        return DBJobInstanceServices.getTransmitReportCounter()
    }
    
    class func saveAnswer(ansModel: AnswerModel) {
        ansModel.dbRawAnsObj = DBAnswerServices.saveAnswerObject(ansModel)
    }
    
    class func saveComment(commentObj: CommentModel, ansModel:AnswerModel?) -> CommentModel? {
        let instance = createInstanceObjectIfNotAvilable()
        commentObj.instanceComment = instance.dbRawInstanceObj as? JobInstance
        if ansModel != nil { commentObj.answerComment = ansModel?.dbRawAnsObj as? Answer }
        if DBJobInstanceServices.saveComment(forCommentObj: commentObj) {
            return commentObj
        }
        return nil
    }
    
    class func removeAnswer(ansId: String) -> Bool {
        return DBAnswerServices.removeAnswerObject(answerId: ansId)
    }
    
    
    class func makeJsonForDeletedDocument(documents: [DocumentModel]) -> [String: AnyObject] {
        
        let deleteDocArr = NSMutableArray()
        for document in documents {
            var docJson = [String: AnyObject]()
            
            docJson[Constants.ApiRequestFields.Key_DeviceId] = AppInfo.sharedInstance.deviceId as AnyObject
            
            if let instanceId = document.insServerId {
                docJson[Constants.ApiRequestFields.Key_FieldVisitId] = instanceId as AnyObject
            }
            if let answerId = document.ansServerId {
                docJson[Constants.ApiRequestFields.Key_SurveyAnswerId] = answerId as AnyObject
            }
            
            deleteDocArr.add(docJson)
        }
        return ["Documents": deleteDocArr]
    }
    
    //Recurrsive Function
    //After removing the directory no need to run this function. but still keep for for old File system
    fileprivate func deleteAnswerPhotos(_ jobVisit: JobVisitModel, _ instanceId: String) {
        
        if let answer = jobVisit.answer {
            for document in answer.ansDocuments {
                
                // Delete document from application document directory
                if (Utility.deleteImageFromDocumentDirectory(docName: document.originalName ?? "", folderName: instanceId)) {
                    if !(Utility.deleteThumbnailImgDocumentFromDirectory(docName: document.originalName ?? "", folderName: instanceId)) {
                        print("Failed to delete thumbnail photo")
                    }
                } else {
                    print("Failed to delete the photo or it's been deleted already as folder deleted")
                }
            }
        }
        for eachSubFv in jobVisit.subFVModels {
            self.deleteAnswerPhotos(eachSubFv, instanceId)
        }
    }
    
    func deleteOldInstances(interval: Int) {
        let backupInterval = interval * 24 * 60 * 60
        let allInstanceToBeDeleted = DBJobInstanceServices.getAllOldInstance(forInterval: backupInterval)
        
        for instance in allInstanceToBeDeleted {
            if let instanceId = instance.instId {
                if DBJobInstanceServices.removeInstance(ForInstId: instanceId) {
                    
                    //Delete instance Directory.
                    Utility.deleteInstanceDirectory(instanceId: instanceId)
                    
                    //After removing the directory no need to run this function. but still keep for for old File system
                    for document in instance.documents {
                        if Utility.deleteImageFromDocumentDirectory(docName: document.originalName ?? "", folderName: instanceId) {
                            if !(Utility.deleteThumbnailImgDocumentFromDirectory(docName: document.originalName ?? "", folderName: instanceId)) {
                                print("Failed to delete thumbnail FV Photo")
                            }
                        } else {
                            print("Failed to delete the photo or it's been deleted already as folder deleted")
                        }
                    }
                    
                    for fvModel in instance.jobVisits {
                        if let jobVisit = fvModel as? JobVisitModel {
                            deleteAnswerPhotos(jobVisit, instanceId)
                        }
                    }
                }
            }
        }
    }
    
    func deleteAPILogs(interval:Int) {
        let backupInterval = interval * 24 * 60 * 60
        DBErrorLogServices.deleteAllOldApiLogs(forInterval: backupInterval)
    }
    
    class func getAllDocuments(forAnswer ansModel: AnswerModel) -> [DocumentModel] {
        return DBDocumentServices.getAllDocuments(forAnswer: ansModel)
    }
    
    class func getInstance(forLocation loc: LocationModel) -> JobInstanceModel{
        let instance = JobInstanceModel(tempModel: AppInfo.sharedInstance.selectedTemplate)
        instance.user = UserModel()
        instance.location = loc
        instance.locationId = loc.locationId
        instance.storeNumber = loc.storeNumber
        return DBJobInstanceServices.loadJobInstIfExist(instModel: instance)
    }
}
