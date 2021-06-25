//
//  DBJobInstanceServices.swift
//  Job
//
//  Created by Saleh Sultan on 5/29/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit
import CoreData
import ImageIO
import Crashlytics
//import Appsee

class DBJobInstanceServices: CoreDataBusiness {
    
    // This function is responsible for adding a new job instance object to the database from local instance singleton object.
    class func insertNewJobInstance(jobInstance: JobInstanceModel) -> JobInstance {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let instanceId = UUID().uuidString
        
        let instance = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.JobInstanceEntity, into: managedObjectContext) as! JobInstance
        instance.instId = instanceId
        instance.startDate = jobInstance.startDate
        instance.isCompleted = NSNumber(value: false)
        instance.isSent = NSNumber(value: false)
        instance.isSentForProcessing = NSNumber(value: false)
        instance.isCompleteNSend = NSNumber(value: false)
        instance.photoAckReceived = NSNumber(value: false)
        instance.isSentOrUpdated = NSNumber(value: false)
        instance.status = ""
        
        if let template = jobInstance.template.dbRawTempObj as? JobTemplate {
            instance.jobTemplate = template
            instance.templateId = template.templateId
            instance.templateName = template.templateName // When assignemed a template, if there is an incompleted instance; then this will help us to find ou the instance.
        }
        if let location = jobInstance.location.dbRawLocObj as? Location {
            instance.jobLocation = location
            instance.storeNumber = location.storeNumber
            instance.locationId = location.locationId
        }
        
        instance.manifest = jobInstance.user.dbRawManifestObj as? Manifest
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to insert instance.")
        }
        return instance
    }
    
    class func removeDocument(documentId: String) -> Bool {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        return self.deleteData(managedObjectContext, entityName:Constants.EntityNames.DocumentEntity, fetchByPredicate: NSPredicate(format: "documentId = %@", documentId))
    }
    
    class func loadJobInstIfExist(instModel instance: JobInstanceModel) -> JobInstanceModel {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "jobTemplate.tempProject.projectId = %@ AND templateId = %@ AND jobLocation.locationId = %@ AND isSent = %@ AND isSentForProcessing = %@ AND isCompleted = %@ AND manifest.user.userName = %@", instance.template.projectId ?? "", instance.template.templateId ?? "", instance.location.locationId ?? "", NSNumber(value: false), NSNumber(value: false), NSNumber(value:false), AppInfo.sharedInstance.username)
        
        
        if let instance = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate).first as? JobInstance {
            return JobInstanceModel(jobInstance: instance)
        }
        return instance
    }
    
    class func loadAllJobInstance(isCompleteInst:Bool, existingInst:[JobInstanceModel]) -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        var instanceList = [JobInstanceModel]()
        
        let predicate = NSPredicate(format: "isCompleted = %@ AND isSent = %@ AND isCompleteNSend = %@ AND manifest.user.userName = %@", NSNumber(value: isCompleteInst), NSNumber(value: false), NSNumber(value: false), AppInfo.sharedInstance.username)
        
        if let suveyInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in suveyInstList {
                instanceList.append(JobInstanceModel(jobInstance: instance))
            }
        }
        
        return instanceList
    }
    
    class func loadAllJobInstance(isCompleteInst:Bool) -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        var instanceList = [JobInstanceModel]()
        
        let predicate = NSPredicate(format: "isCompleted = %@ AND isSent = %@ AND isCompleteNSend = %@ AND manifest.user.userName = %@", NSNumber(value: isCompleteInst), NSNumber(value: false), NSNumber(value: false), AppInfo.sharedInstance.username)
        
        if let suveyInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in suveyInstList {
                instanceList.append(JobInstanceModel(jobInstance: instance))
            }
        }
        
        return instanceList
    }
    
    class func loadAllJobInstanceCounter(isCompleteInst:Bool) -> Int {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        let predicate = NSPredicate(format: "isCompleted = %@ AND isSent = %@ AND isCompleteNSend = %@ AND manifest.user.userName = %@", NSNumber(value: isCompleteInst), NSNumber(value: false), NSNumber(value: false), AppInfo.sharedInstance.username)
        let completedCount = self.countFetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, fetchByPredicate: predicate)
        return completedCount
    }
    
    
    class func loadAllJobInstanceForReport(isCompleteInst:Bool) -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        var instanceList = [JobInstanceModel]()
        managedObjectContext.performAndWait {
            let predicate = NSPredicate(format: "isCompleted = %@ AND isSentForProcessing = %@ AND isSent = %@ AND manifest.user.userName = %@", NSNumber(value: isCompleteInst), NSNumber(value: true), NSNumber(value: false), AppInfo.sharedInstance.username)
            
            if let suveyInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
                
                for instance in suveyInstList {
                    instanceList.append(JobInstanceModel(jobInstance: instance))
                }
            }
        }
        
        return instanceList
    }
    
    // In Main menu page put this string for counting total transmit report
    class func getTransmitReportCounter() -> String {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        // Photo Acknowledgement flag is added in the query because, if photo data property null is found, then we are considering that instance as sent, since user has no way to retake that photo.
        let predicate = NSPredicate(format: "(status = %@ OR status = %@) AND manifest.user.userName = %@", StringConstants.StatusMessages.SuccessfullySent, StringConstants.StatusMessages.SuccessfullyUpdated, AppInfo.sharedInstance.username)
        let predicate2 = NSPredicate(format: "isSentOrUpdated = %@ AND manifest.user.userName = %@", NSNumber(value: true), AppInfo.sharedInstance.username)
        
        let completedCount = self.countFetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, fetchByPredicate: predicate)
        let totalInstanceCount = self.countFetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, fetchByPredicate: predicate2)
        return "\(completedCount)/\(totalInstanceCount)"
    }
    
    
    // Before Instance acknowledgement request check all the instances those photos are not sent yet, but instances sent properly
    class func loadAllCompleteInstThatPhotosNotSentYet() -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isCompleted = %@ AND isSent = %@ AND manifest.user.userName = %@ AND photoAckReceived = %@", NSNumber(value: true), NSNumber(value: true), AppInfo.sharedInstance.username, NSNumber(value: false))
        
        var instanceList = [JobInstanceModel]()
        if let suveyInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in suveyInstList {
                instanceList.append(JobInstanceModel(jobInstance: instance))
            }
        }
        return instanceList
    }
    
    // Before Instance acknowledgement request check all the instances those photos are not sent yet, but instances sent properly
    class func loadAllCompleteInstThatFailedBecauseOfMemWarning() -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isSentOrUpdated = %@ AND isSent = %@ AND manifest.user.userName = %@ AND photoAckReceived = %@", NSNumber(value: true), NSNumber(value: true), AppInfo.sharedInstance.username, NSNumber(value: false))
        
        var instanceList = [JobInstanceModel]()
        if let suveyInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in suveyInstList {
                if let status = instance.status {
                    if status.contains("Sending Photos ") {
                        instanceList.append(JobInstanceModel(jobInstance: instance))
                    }
                }
            }
        }
        return instanceList
    }
    
    
    class func getAllUpdateInstancesWhichPhotosAreNotSentYet() -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isSentOrUpdated = %@ AND isCompleted = %@ AND status != %@ AND error.errorCode = %@ AND manifest.user.userName = %@", NSNumber(value: true), NSNumber(value: false), StringConstants.StatusMessages.SuccessfullyUpdated, NSNumber(value: 0), AppInfo.sharedInstance.username)
        
        var instanceList = [JobInstanceModel]()
        if let suveyInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in suveyInstList {
                instanceList.append(JobInstanceModel(jobInstance: instance))
            }
        }
        return instanceList
    }
    
    static let CompleteDate = "completedDate"
    static let InstanceSentTime = "instanceSentTime"
    class func loadAllInstancesReport() -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isSentOrUpdated = %@ AND manifest.user.userName = %@", NSNumber(value: true), AppInfo.sharedInstance.username)
        
        var instanceList = [JobInstanceModel]()
        if let suveyInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: "instanceSentTime", IsAscending: false, fetchByPredicate: predicate, fetchLimit: 25) as? [JobInstance] {
            //"instanceSentTime", it should be this key field for sorting. We will change it in next release.
            for instance in suveyInstList {
                instanceList.append(JobInstanceModel(jobInstance: instance))
            }
        }
        return instanceList
    }
    
    
    
    // This function is responsible to make the relationship with existing incomplete job instance to Template and Location objects, if the instance is not associated with any template or location for a specific user. If the instance is not associate any template or location available in our database for that specific user, then it's an orphane instance. That means, that job instance template is no longer assigned to that user.
    class func syncUnlinkedInstances() {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isCompleted = %@ OR isCompleted = %@ AND isSent = %@ AND manifest.user.userName = %@", NSNumber(value: true), NSNumber(value: false), NSNumber(value: false), AppInfo.sharedInstance.username)
        
        
        if let jobInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in jobInstList {
                if instance.jobTemplate == nil {
                    if let template = DBTemplateServices.sharedInstance.getTemplateUsingTemplateId(templateId: instance.templateId!) {
                        instance.jobTemplate = template
                        
                        if let answers = instance.answers {
                            for ansObj in answers {
                                if let answer = ansObj as? Answer {
                                    if let taskArray = template.task?.filtered(using: NSPredicate(format: "taskId == %@", answer.taskId!)) {
                                        if taskArray.count > 0 {
                                            answer.task = taskArray.first as? Task
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if instance.jobLocation == nil {
                    if let location = DBLocationServices.sharedInstance.getLocation(forStoreNo: instance.storeNumber!, forLocId: instance.locationId!) {
                        instance.jobLocation = location
                    }
                }
            }
            
            
            do {
                try managedObjectContext.save()
            } catch {
                print("Failed to Sync unlinked instances")
            }
        }
    }
    
    
    class func updateInstanceStatus(jobInstance: JobInstanceModel) {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        managedObjectContext.perform {
            if let instanceId = jobInstance.instId {
                if let instance = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "instId = %@", instanceId)).first as? JobInstance {
                    
                    if let status = jobInstance.status {
                        instance.status = status
                        
                        do {
                            try managedObjectContext.save()
                        } catch {
                            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["ErrorPlace": "Updating instance status."])
                            //Appsee.addEvent("Failed to update Instance status.", withProperties: ["Username": AppInfo.sharedInstance.username ?? "", "InstanceClientId": jobInstance.instId ?? ""])
                            
                            
                            // Sometime app is causing some merge conflict issue. This below portion of code will make sure it solve the conflict and merge them.
                            let nserror = error as NSError
                            if let conflictListArray = nserror.userInfo["conflictList"] as? [NSConstraintConflict] {
                                if conflictListArray.count > 0 {
                                    let mergePolicy = NSMergePolicy(merge: NSMergePolicyType.overwriteMergePolicyType)
                                    do {
                                        try mergePolicy.resolve(constraintConflicts: conflictListArray)
                                    } catch {
                                        //Appsee.addEvent("Failed to merge conflicts of Instance status Update.", withProperties: ["Username": AppInfo.sharedInstance.username ?? ""])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    class func updateJobInstance(jobInstance: JobInstanceModel) {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        managedObjectContext.perform {
            if let instance = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "instId = %@", jobInstance.instId!)).first as? JobInstance {
                
                if instance.instServerId != jobInstance.instServerId {
                    instance.instServerId = jobInstance.instServerId
                }
                if !(instance.isCompleted?.isEqual(to: jobInstance.isCompleted))! {
                    instance.isCompleted = jobInstance.isCompleted
                }
                if let completedDate = jobInstance.completedDate {
                    instance.completedDate = completedDate
                }
                if !(instance.isSent?.isEqual(to: jobInstance.isSent))! {
                    instance.isSent = jobInstance.isSent
                }
                if !(instance.isSentForProcessing?.isEqual(to: jobInstance.isSentForProcessing))! {
                    instance.isSentForProcessing = jobInstance.isSentForProcessing
                }
                if !(instance.isCompleteNSend?.isEqual(to: jobInstance.isCompleteNSend))! {
                    instance.isCompleteNSend = jobInstance.isCompleteNSend
                }
                if !(instance.isSentOrUpdated?.isEqual(to: jobInstance.isSentOrUpdated))! {
                    instance.isSentOrUpdated = jobInstance.isSentOrUpdated
                }
                if let instanceSentTime = jobInstance.instanceSentTime {
                    if instance.instanceSentTime == nil {
                        instance.instanceSentTime = instanceSentTime
                    }
                    else if !instanceSentTime.isEqual(to: instance.instanceSentTime! as Date) {
                        instance.instanceSentTime = instanceSentTime
                    }
                }
                if !(instance.photoAckReceived?.isEqual(to: jobInstance.photoAckReceived))! {
                    instance.photoAckReceived = jobInstance.photoAckReceived
                }
                if let uploadTime = jobInstance.succPhotoUploadTime {
                    instance.succPhotoUploadTime = uploadTime
                }
                if let status = jobInstance.status, instance.status != jobInstance.status {
                    instance.status = jobInstance.status
                    if status.contains("Successfully") && instance.error != nil {
                        instance.error?.errorCode = 0
                    }
                }
                
                if let user = self.fetchData(managedObjectContext, entityName:Constants.EntityNames.UserEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "userName = %@ AND userId = nil", jobInstance.user.userName!)).first as? User {
                    user.userId = jobInstance.user.userId
                }
                
                do {
                    try managedObjectContext.save()
                } catch {
                    
                    // Sometime app is causing some merge conflict issue. This below portion of code will make sure it solve the conflict and merge them.
                    let nserror = error as NSError
                    if let conflictListArray = nserror.userInfo["conflictList"] as? [NSConstraintConflict] {
                        if conflictListArray.count > 0 {
                            let mergePolicy = NSMergePolicy(merge: NSMergePolicyType.overwriteMergePolicyType)
                            do {
                                try mergePolicy.resolve(constraintConflicts: conflictListArray)
                            } catch {
                                //Appsee.addEvent("Failed to merge conflicts of Instance Update.", withProperties: ["Username": AppInfo.sharedInstance.username ?? ""])
                            }
                        }
                    }
                    
                    Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["ErrorPlace": "At the time of updating all the details of the instance"])
                }
            }
        }
    }
    
    class func getAllOldInstance(forInterval interval: Int) -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isSent = %@ AND photoAckReceived = %@ AND manifest.user.userName = %@ AND completedDate != nil AND %@ - completedDate > %ld", NSNumber(value: true), NSNumber(value: true), AppInfo.sharedInstance.username, NSDate(), interval)
        
        var instModelList = [JobInstanceModel]()
        if let instanceList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in instanceList {
                instModelList.append(JobInstanceModel(jobInstance: instance))
            }
        }
        return instModelList
    }
    
    
    class func removeInstance(ForInstId instanceId: String) -> Bool {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        return self.deleteData(managedObjectContext, entityName:Constants.EntityNames.JobInstanceEntity, fetchByPredicate: NSPredicate(format: "instId = %@", instanceId))
    }
    
    
    
    // FOR TESTING
    class func loadAllJobInstanceForReport_TEST(isCompleteInst:Bool) -> [JobInstanceModel] {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "isCompleted = %@ AND isSent = %@ AND manifest.user.userName = %@", NSNumber(value: isCompleteInst), NSNumber(value: false), "ssultan")
        
        var instanceList = [JobInstanceModel]()
        if let suveyInstList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in suveyInstList {
                instanceList.append(JobInstanceModel(jobInstance: instance))
            }
        }
        return instanceList
    }
    
    class func updateJobAckStatus(instIdList:[String], status: Bool) -> Bool {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "instServerId in (%@)", instIdList)
        
        if let instList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
            
            for instance in instList {
                instance.photoAckReceived = NSNumber(value: status)
            }
            do {
                try managedObjectContext.save()
                return true
            } catch {
                print("Failed to update the document: \(error)")
            }
        }
        return false
    }
    
    class func getSurveyInstance(ForInstModel instModel:JobInstanceModel) -> JobInstance? {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        
        if let instance = self.fetchData(managedObjContext, entityName:Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "instId = %@", instModel.instId!)).first as? JobInstance {
            
            return instance
        }
        return nil
    }
    
    class func saveComment(forCommentObj commentModel: CommentModel) -> Bool {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let comment = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.CommentEntity, into: managedObjContext) as! Comment
        comment.commentId = commentModel.commentId
        comment.instanceComment = commentModel.instanceComment
        comment.createdDate = commentModel.createdDate
        comment.createdBy = commentModel.createdBy
        comment.commentText = commentModel.commentText
        comment.answerComment = commentModel.answerComment
        do {
            try managedObjContext.save()
            return true
        } catch {
            print("Failed to insert instance.")
            return false
        }
    }
    
    class func updateCommentId(commentId: String, serverId: String) {
//        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
//        let predicate = NSPredicate(format: "isSent = %@ AND photoAckReceived = %@ AND manifest.user.userName = %@ AND completedDate != nil AND %@ - completedDate > %ld", NSNumber(value: true), NSNumber(value: true), AppInfo.sharedInstance.username, NSDate(), interval)
//
//        var instModelList = [JobInstanceModel]()
//        if let instanceList = self.fetchData(managedObjectContext, entityName: Constants.EntityNames.JobInstanceEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [JobInstance] {
//
//            for instance in instanceList {
//                instModelList.append(JobInstanceModel(jobInstance: instance))
//            }
//        }
//        return instModelList
    }
}
