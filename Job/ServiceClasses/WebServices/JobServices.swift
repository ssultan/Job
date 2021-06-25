//
//  JobServices.swift
//  Job
//
//  Created by Saleh Sultan on 5/29/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class JobServices: BaseService {
    
    weak var delegate:LoginOberverDelegate!
    
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
            
            // From next version we will use 'photoAttrType'
            if documentObj.attribute! == PhotoAttributesTypes.FieldVisit.rawValue {
                if let jobIns = AppInfo.sharedInstance.selJobInstance.dbRawInstanceObj as? JobInstance {
                    documentObj.documentInstance = jobIns
                }
            }
            else if let answer = JobVisitModel.sharedInstance.answer.dbRawAnsObj as? Answer {
                documentObj.documentAnswer = answer
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
    
    class func removeDocument(docId: String) -> Bool{
        // remove document from local database.
        return (DBJobInstanceServices.removeDocument(documentId: docId))
    }
    
    
    class func loadJobInstance(isCompleted: Bool, currentList:[JobInstanceModel]) -> [JobInstanceModel] {
        return DBJobInstanceServices.loadAllJobInstance(isCompleteInst: isCompleted, existingInst: currentList)
    }
    
    
    // NO NEED
    class func loadJobInstance(isCompleted: Bool, completion:(_ instances: [JobInstanceModel])->()) {
        completion(DBJobInstanceServices.loadAllJobInstance(isCompleteInst: isCompleted))
    }
    
    class func loadJobInstance(completion:(_ instances: [JobInstanceModel])->()) {
        completion(DBJobInstanceServices.loadAllJobInstance())
    }
    
    
    class func loadJobInstanceCounter() -> Int {
        return DBJobInstanceServices.shreardJobInstCounter()
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
        if ansModel != nil {
            commentObj.answerComment = ansModel?.dbRawAnsObj as? Answer
            DBAnswerServices.answerUpdated(answerId: commentObj.answerComment!.ansId!)
        }
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
    
    
    
    //This function is reponsible to download Locations For list of projectIDs that we calculated at the time of adding project.
    func checkAllInstanceUpdate(instanceList: [JobInstanceModel]) {
        var totalJobInstChecked = 0
        for instance in instanceList {
            self.getInstanceStatus(forInstance: instance, completion: {
                self.delegate.increaseProgressbar()
                
                totalJobInstChecked = totalJobInstChecked + 1
                if totalJobInstChecked == instanceList.count {
                    self.delegate.inCompleteJobStatusChecked = true
                    self.delegate.loginSuccess(isOfflineLogin: false)
                }
            })
        }
    }
    
    func getInstanceStatus(forInstance instance:JobInstanceModel, completion:@escaping () ->()) {
        
        if let projectId = instance.project?.projectId, let templateId = instance.templateId, let locationId = instance.locationId {
            var url = AppInfo.sharedInstance.httpType + AppInfo.sharedInstance.baseURL + Constants.APIServices.GET_InstanceStatusUpdate + "0" + "?projectid=\(projectId)&templateid=\(templateId)&locationid=\(locationId)"
            if let instanceServerId = instance.instServerId {
                url = AppInfo.sharedInstance.httpType + AppInfo.sharedInstance.baseURL + Constants.APIServices.GET_InstanceStatusUpdate + instanceServerId
            }
            
            print("Status URL: \(url)")
            self.fetchReponseInData(forRequestType: .get, forServiceURL: url, params: nil) { (resJson, resData, statusCode, isSucceeded) in
                if(isSucceeded) {
                    if let data = resData {
                        do {
                            let jsonStr = String(data: try! JSONSerialization.data(withJSONObject: resJson as Any, options: []), encoding: .ascii)
                            print("Status JsonOutput: \(String(describing: jsonStr ?? ""))");
                            
                            let instStatus = try JSONDecoder().decode(InstanceStatusMapping.self, from: data)
                            instStatus.updateLocalInstanceStatus(jobInst: instance)
                        }catch {
                            print("Error: \(error)")
//                            Appsee.addEvent(StringConstants.AppseeEventMessages.Failed_To_Get_InstanceId_For_Status, withProperties: resJson as? [String: AnyObject])
                        }
                    }
                }
                else {
                    print("**************** Status: Instance NOT exist.****************")
//                    Appsee.addEvent(StringConstants.AppseeEventMessages.Failed_To_Get_InstanceId_For_Status, withProperties: ["Response": resJson!, "ErrorCode": statusCode])
                }
                completion()
            }
        }
        else {

            print("TemplateName :\(String(describing: instance.templateName)), templateId: \(String(describing: instance.templateId)), locationId:\(String(describing: instance.locationId))")
            completion()
        }
    }
    
    
    func getJobInstance(forInstance instance: JobInstanceModel, completionHandler:@escaping (_ jobInstance: JobInstanceModel)->()){
        
        if let projectId = instance.project?.projectId, let templateId = instance.templateId, let locationId = instance.locationId {
            var url = AppInfo.sharedInstance.httpType + AppInfo.sharedInstance.baseURL + Constants.APIServices.GET_SharedInstance  + "0" + "?projectid=\(projectId)&templateid=\(templateId)&locationid=\(locationId)"
            if let instanceServerId = instance.instServerId {
                url = AppInfo.sharedInstance.httpType + AppInfo.sharedInstance.baseURL + Constants.APIServices.GET_SharedInstance + instanceServerId
            }
            
            print("URL: \(url)")
            self.fetchReponseInData(forRequestType: .get, forServiceURL: url, params: nil) { (resJson, resData, statusCode, isSucceeded) in
                if(isSucceeded) {
                    if let data = resData {
                        do {
                            let jsonStr = String(data: try! JSONSerialization.data(withJSONObject: resJson as Any, options: []), encoding: .ascii)
                            print("Shared JSON Output: \(String(describing: jsonStr ?? ""))");
                            
                            let instMapper = try JSONDecoder().decode(JobInstanceMapping.self, from: data)
                            instance.updateLocalInstance(forMInstance: instMapper)
                        }catch {
                            print("Error: \(error)\n\n Output: \(String(describing: resJson))")
//                            Appsee.addEvent(StringConstants.AppseeEventMessages.Failed_To_Get_InstanceId_For_Status, withProperties: resJson as? [String: AnyObject])
                        }
                    }
                }
                else {
                    print("------------------------Instance NOT exist-------------------------")
//                    Appsee.addEvent(StringConstants.AppseeEventMessages.Failed_To_Get_InstanceId_For_Status, withProperties: ["Response": resJson!, "ErrorCode": statusCode])
                }
                completionHandler(instance)
            }
        }
        else {
            completionHandler(instance)
        }
    }
}
