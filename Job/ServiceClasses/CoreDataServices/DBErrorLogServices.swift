//
//  DBErrorLogServices.swift
//  Job V2
//
//  Created by Saleh Sultan on 4/4/18.
//  Copyright © 2018 Clearthread. All rights reserved.
//

import UIKit
import CoreData

class DBErrorLogServices: CoreDataBusiness {
    
    class func addUpdateErrorObject(forInstance jobInsModel:JobInstanceModel?, forDocument documentMo:DocumentModel?, forErrorCode eCode:NSInteger, forErrorMsg msg:String) -> Int {
        
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = (jobInsModel != nil) ?
            NSPredicate(format: "instanceError.instId = %@", jobInsModel?.instId ?? "") :
            NSPredicate(format: "documentError.documentId = %@", documentMo?.documentId ?? "")
        
        
        if let errorLog = self.fetchData(managedObjContext, entityName:Constants.EntityNames.ErrorLogs, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate).first as? ErrorLogs {

            if let errorMsg = errorLog.errorMsg, let count = errorLog.totalCounted {
                if Int64(errorLog.errorCode) == eCode {
                    
                    if jobInsModel != nil && errorMsg != msg {
                        managedObjContext.delete(errorLog)
                        do {
                            try managedObjContext.save()
                        } catch {
                            print("Failed to delete error data")
                        }
                    } else {
                        errorLog.totalCounted = NSNumber(value: Int(truncating: count) + 1)
                        do {
                            try managedObjContext.save()
                        } catch {
                            print("Failed to save error object")
                        }
                        return Int(truncating: count) + 1
                    }
                }
                else {
                    managedObjContext.delete(errorLog)
                    do {
                        try managedObjContext.save()
                    } catch {
                        print("Failed to delete error data")
                    }
                }
            }
        }
        
        
        let errorLog = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.ErrorLogs, into: managedObjContext) as! ErrorLogs
        errorLog.errorCode = Int64(eCode)
        errorLog.errorMsg = msg
        errorLog.totalCounted = NSNumber(value: 1)
        if let model = documentMo {
            errorLog.documentError = DBDocumentServices.getDocument(ForDocModel: model)
        }
        else if let model = jobInsModel {
            errorLog.instanceError = model.dbRawInstanceObj as? JobInstance
        }
        
        do {
            try managedObjContext.save()
        } catch {
            print("Failed to save error log.")
            return 0
        }
        return 1
    }
    
    class func isDocumentExistInErrorTable(documentMo: DocumentModel)-> Bool {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "documentError.documentId = %@", documentMo.documentId ?? "")
        
        
        if let errorLog = self.fetchData(managedObjContext, entityName:Constants.EntityNames.ErrorLogs, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate).first as? ErrorLogs {
            
            if let errorCount = errorLog.totalCounted {
                if Int(truncating: errorCount) >= Constants.DocErrorThresholdMaxCounter {
                    return true
                }
            }
        }
        return false
    }
    
    // this function is causing memory issue
    class func storeAllAPILogs(apiLogModel: ApiLogsModel) {
        
//        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
//        let apiLog = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.ApiMessageLog, into: managedObjContext) as! ApiMessageLog
//        apiLog.resTimeInSec = apiLogModel.resTimeInSec ?? NSNumber(value: 0)
//        apiLog.apiName = apiLogModel.apiName
//        apiLog.reqURL = apiLogModel.reqURL
//        apiLog.reqMethod = apiLogModel.reqMethod ?? ""
//        apiLog.requestJson = apiLogModel.requestJson ?? ""
//        apiLog.requestTime = apiLogModel.requestTime ?? NSDate()
//        apiLog.responseErrorCode = apiLogModel.responseErrorCode ?? NSNumber(value: false)
//        apiLog.responseJson = apiLogModel.responseJson ?? ""
//        apiLog.responseStatus = apiLogModel.responseStatus ?? NSNumber(value: false)
//        apiLog.responseTime = apiLogModel.responseTime ?? NSDate()
//        apiLog.username = AppInfo.sharedInstance.username ?? ""
//        
//        switch UIApplication.shared.applicationState {
//        case .active:
//            apiLog.deviceState = "Active"
//        case .background:
//            apiLog.deviceState = "Background"
//        case .inactive:
//            apiLog.deviceState = "Inactive"
//        }
//        
//        
//        do {
//            try managedObjContext.save()
//        } catch {
//            print("Store all API Failed to save error log.")
//            
//            // Sometime app is causing some merge conflict issue. This below portion of code will make sure it solve the conflict and merge them.
//            let nserror = error as NSError
//            if let conflictListArray = nserror.userInfo["conflictList"] as? [NSConstraintConflict] {
//                if conflictListArray.count > 0 {
//                    let mergePolicy = NSMergePolicy(merge: NSMergePolicyType.overwriteMergePolicyType)
//                    do {
//                        try mergePolicy.resolve(constraintConflicts: conflictListArray)
//                    } catch {
//                        //Appsee.addEvent("Failed to merge conflicts API MessageLog update", withProperties: ["Username": AppInfo.sharedInstance.username ?? ""])
//                    }
//                }
//            }
//        }
    }
    
    
    class func deleteAllOldApiLogs(forInterval interval: Int) {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "requestTime != nil AND %@ - requestTime > %ld", NSDate(), interval)
        
        if let apiLogList = self.fetchData(managedObjContext, entityName: Constants.EntityNames.ApiMessageLog, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate, fetchLimit: 25) as? [ApiMessageLog] {

            for log in apiLogList {
                managedObjContext.delete(log)
            }
        }
        
        do {
            try managedObjContext.save()
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}
