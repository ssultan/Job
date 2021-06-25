//
//  BgServiceErrorHandle.swift
//  JobV2.0
//
//  Created by Saleh Sultan on 1/2/19.
//  Copyright © 2019 Clearthread. All rights reserved.
//

import Foundation
import FirebaseAnalytics

extension BackgroundServices {
    
    func notifyStatusUpdate(instance: JobInstanceModel) {
        if let status = instance.status, let clientId = instance.instId {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.ReloadReportTableNotifier), object: nil,
                                            userInfo: [KeyInstanceId: clientId,
                                                       KeyStatus : status,
                                                       KeyUserId : instance.user.userName ?? appInfo.deviceId,
                                                       Constants.BgUIUpdateNotifierKeys.KeyInstProjId: instance.project.projectId ?? "",
                                                       Constants.BgUIUpdateNotifierKeys.KeyInstTempId: instance.template.templateId ?? "",
                                                       Constants.BgUIUpdateNotifierKeys.KeyInstLocId: instance.location.locationId ?? ""])
        }
    }
    
    //MARK: - Instance Error Handle
    func handleInstanceError(resStatusCode: Int, jobInstance: JobInstanceModel, errorJSON: AnyObject?, isUpdating: Bool)
    {
        // StatusCode = 403 means 'Token Expired', Refresh and get a new token and continue the same process.
        if resStatusCode == HttpRespStatusCodes.TokenExpiredCode.rawValue {
            
            //Show status that refreshing token
            jobInstance.status = StringConstants.StatusMessages.TokenExpired
            notifyStatusUpdate(instance: jobInstance)
            
            Analytics.logEvent(StringConstants.AppseeEventMessages.Token_Expired_BG_SendProcess, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId])
            DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
            
            //Refresh token
            if loginInBackgroundToGetNewToken() {
                
                // Change this flag back to false; so that we can notify to the system for local notification when runnin in Background.
                self.isRecErrorAtTimeOfBGSending = false
                
                //Send same instance upload request again
                self.sendInstance(jobInstance: jobInstance, isUpdating: isUpdating)
            }
        }
        else if resStatusCode == HttpRespStatusCodes.BadRequestCode.rawValue {
            jobInstance.status = StringConstants.StatusMessages.BAD_REQUEST
            Analytics.logEvent(StringConstants.AppseeEventMessages.BAD_REQUEST, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId])
            
            notifyStatusUpdate(instance: jobInstance)
            DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
            Utility.showAlertMsgWhenRunningInBG(withMessage: StringConstants.StatusMessages.BAD_REQUEST)
        }
        else if resStatusCode == HttpRespStatusCodes.NotFoundCode.rawValue {
            jobInstance.status = StringConstants.StatusMessages.NOT_FOUND_ERROR
            Analytics.logEvent(StringConstants.AppseeEventMessages.NOT_FOUND_ERROR, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId])
            notifyStatusUpdate(instance: jobInstance)
            DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
            Utility.showAlertMsgWhenRunningInBG(withMessage: StringConstants.StatusMessages.NOT_FOUND_ERROR)
        }
            
        else if resStatusCode == HttpRespStatusCodes.RequestTimeOut.rawValue {
            jobInstance.status = StringConstants.StatusMessages.Request_Timeout
            Analytics.logEvent(StringConstants.AppseeEventMessages.Request_Timeout_BG_SendProcess_Instance, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId])
            notifyStatusUpdate(instance: jobInstance)
            DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
            Utility.showAlertMsgWhenRunningInBG(withMessage: StringConstants.StatusMessages.Request_Timeout)
        }
            
        else if let jsonDic = errorJSON as? [String: AnyObject] {
            // Status code = 500; means there was an error in the request we made
            if let eCode = jsonDic[Constants.ApiRequestFields.Key_ErrorCode], let messageObj = jsonDic[Constants.ApiRequestFields.Key_Message] {
                
                var message = String(describing: messageObj)
                if !message.lowercased().contains("error") {
                    message = "Error: \(message)"
                }
                
                Analytics.logEvent("Failed to \(!isUpdating ? "send" : "update") Survey Instance", parameters: [
                "UserId": jobInstance.user.userName ?? appInfo.deviceId,
                "ResStatusCode" : String(describing: resStatusCode),
                "ErrorCode": String(describing: eCode),
                "InstClientId": jobInstance.instId ?? "",
                "ErrorMessage": message])
                
                if let errorCode = eCode as? NSInteger {
                    jobInstance.errorCode = Int64(errorCode)
                    
                    // Store instance error details and number of times occurred
                    let totalErrCount = DBErrorLogServices.addUpdateErrorObject(forInstance: jobInstance, forDocument: nil, forErrorCode: errorCode, forErrorMsg: message)
                    if totalErrCount >= Constants.ErrorThresholdMaxCounter {
                        print("***************Total Error Counted: \(totalErrCount)")
                        
                        // Store Error log in Crashlytics
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: resStatusCode, msgToDisplay: "Simple Instance API Error Reached Max Threshould")
                        
                        jobInstance.isCompleted = NSNumber(value: false)
                        jobInstance.isCompleteNSend = NSNumber(value: false)
                        jobInstance.isSentForProcessing = NSNumber(value: false)
                        jobInstance.status = "Error: \(StringConstants.StatusMessages.INSTANCE_ERROR_GEN_MSG)"
                        
                        notifyStatusUpdate(instance: jobInstance)
                        DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
                        return
                    }
                    
                    
                    
                    // Allow user's to update instance again
                    if errorCode == SendProcErrorCode.InsertFailed.rawValue || errorCode == SendProcErrorCode.InstDoesNotExistOrDeletedInServerDB.rawValue {
                        
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: resStatusCode, msgToDisplay: "Simple Instance API Error: \(SendProcErrorCode.InstDoesNotExistOrDeletedInServerDB.rawValue)")
                        
                        if errorCode == SendProcErrorCode.InsertFailed.rawValue {
                            jobInstance.isCompleted = NSNumber(value: false)
                        }
                        jobInstance.isCompleteNSend = NSNumber(value: false)
                        jobInstance.isSentForProcessing = NSNumber(value: false)
                        if let actualMsg = message.components(separatedBy: "CreateInstance:").last {
                            jobInstance.status = "Error:\(actualMsg)"
                            message = "Error:\(actualMsg)"
                        } else { jobInstance.status = message }
                        
                        notifyStatusUpdate(instance: jobInstance)
                    }
                        // instance client ID already exist. Get instance Id for clientId
                    else if errorCode == SendProcErrorCode.DuplicateItmAvailInServerDB.rawValue {
                        
                        // Do not show any error message, since we will get the surver instance Id from another request.
                        // Get the instance server Id first
                        if self.getInstanceServerId(forInstance: jobInstance){
                            if jobInstance.isCompleted.boolValue == false {
                                // Then call the update request again
                                self.sendInstance(jobInstance: jobInstance, isUpdating: isUpdating)
                            }
                            else {
                                // For complete instance, we don't need to make 'Update' request again. So simply mark the instance as 'sent' flag to true and start sending all the associted documents.
                                jobInstance.isSentForProcessing = NSNumber(value: false)
                                jobInstance.isSent = NSNumber(value: true)
//                                self.initiateDocumentSendProcess(jobInstance: jobInstance, isUpdating: false)
                                
                                let failedToSend = self.sendDocumentsforInstance(instanceObj: jobInstance)
                                jobInstance.updateInstAfterPhotoUploadProcessCompleted(forNumOfFailed: failedToSend, andUpdating: isUpdating)
                            }
                        }
                    }
                        
                        // ******************************************
                        // More than 1 answer has same questionId; OR more than one answer has same set number for a configurable question
                        // NOT sure what to do in this scenario. Need to discuss.
                        // Second scerario: Server is not responding
                        // Anthing which is not handled by any error code in server side will receive this error code
                    else if errorCode == SendProcErrorCode.UnknownErrorCode.rawValue {
                        // Store Error log in Crashlytics
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: resStatusCode, msgToDisplay: "Simple Instance API Unknown Error: 11235")
                        
                        jobInstance.status = String(describing: message)
                        notifyStatusUpdate(instance: jobInstance)
                    }
                        
                        // *****************************************
                        // This is default scenario, anything unwanted or unknown
                    else {
                        
                        // Store Error log in Crashlytics
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: resStatusCode, msgToDisplay: "Simple Instance API Unknown Error!!!")
                        
                        jobInstance.status = String(describing: message)
                        notifyStatusUpdate(instance: jobInstance)
                    }
                }
                
                DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
                Utility.showAlertMsgWhenRunningInBG(withMessage: message)
            }
            else {
                jobInstance.status = StringConstants.StatusMessages.UnknownError
                notifyStatusUpdate(instance: jobInstance)
                
                DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
                Utility.showAlertMsgWhenRunningInBG(withMessage: StringConstants.StatusMessages.UnknownErrorInstance)
            }
        }
        else {
            Analytics.logEvent("Failed to \(!isUpdating ? "send" : "update") Survey Instance", parameters:
            ["UserId": jobInstance.user.userName ?? appInfo.deviceId,
             "RequestStatusCode": resStatusCode,
             "ErrorMessage": StringConstants.StatusMessages.UnknownError])
            
            jobInstance.status = StringConstants.StatusMessages.UnknownError
            notifyStatusUpdate(instance: jobInstance)
            Utility.showAlertMsgWhenRunningInBG(withMessage: StringConstants.StatusMessages.UnknownErrorInstance)
        }
    }
    
    
    //MARK: - Document Error Handle
    func handleDocumentErrors(_ resStatusCode: Int, _ jobInstance: JobInstanceModel, _ isSentSuccessfully: inout Bool, _ document: DocumentModel, _ ordinal: Int, _ errorJSON: AnyObject?) {
        // StatusCode = 403 means 'Token Expired', Refresh and get a new token and continue the same process.
        if resStatusCode == HttpRespStatusCodes.TokenExpiredCode.rawValue {
            
            //Show status that refreshing token
            jobInstance.status = StringConstants.StatusMessages.TokenExpired
            
            if let serverId = jobInstance.instServerId {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.ReloadReportTableNotifier),
                                            object: nil, userInfo: [KeyInstanceId: jobInstance.instId!,
                                                                    KeyStatus : StringConstants.StatusMessages.TokenExpired,
                                                                    KeyInstServerId: serverId,
                                                                    Constants.BgUIUpdateNotifierKeys.KeyInstProjId: jobInstance.project.projectId ?? "",
                                                                    Constants.BgUIUpdateNotifierKeys.KeyInstTempId: jobInstance.template.templateId ?? "",
                                                                    Constants.BgUIUpdateNotifierKeys.KeyInstLocId: jobInstance.location.locationId ?? ""])
            }
            Analytics.logEvent(StringConstants.AppseeEventMessages.Token_Expired_BG_SendProcess, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId])
            
            //Refresh token
            if loginInBackgroundToGetNewToken() {
                //make the flag flase after successfully retrieve a new token
                isRecErrorAtTimeOfBGSending = false
                
                //Upload the same photo again.
                isSentSuccessfully = self.uploadDocument(document: document, ordinal: ordinal, jobInstance: jobInstance)
            }
        }
        else if resStatusCode == HttpRespStatusCodes.BadRequestCode.rawValue {
            jobInstance.status = StringConstants.StatusMessages.BAD_REQUEST
            Analytics.logEvent(StringConstants.AppseeEventMessages.BAD_REQUEST, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId])
            jobInstance.status = StringConstants.StatusMessages.UnknownError
        }
        else if resStatusCode == HttpRespStatusCodes.NotFoundCode.rawValue {
            jobInstance.status = StringConstants.StatusMessages.NOT_FOUND_ERROR
            Analytics.logEvent(StringConstants.AppseeEventMessages.BAD_REQUEST, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId])
            jobInstance.status = StringConstants.StatusMessages.UnknownError
        }
            
        else if resStatusCode == HttpRespStatusCodes.RequestTimeOut.rawValue {
            jobInstance.status = StringConstants.StatusMessages.Request_Timeout
            Analytics.logEvent(StringConstants.AppseeEventMessages.Request_Timeout_BG_SendProcess_Photo, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId])
            jobInstance.status = StringConstants.StatusMessages.UnknownError
        }
            
            // Status code = 500; means there was a error in the request we made
        else if resStatusCode == HttpRespStatusCodes.RequestHasErrorCode.rawValue, let jsonDic = errorJSON as? [String: AnyObject] {
            if let eCode = jsonDic[Constants.ApiRequestFields.Key_ErrorCode], let message = jsonDic[Constants.ApiRequestFields.Key_Message] {
                
                Analytics.logEvent(StringConstants.AppseeEventMessages.Failed_To_Upload_Image, parameters: [
                "UserId": jobInstance.user.userName ?? appInfo.deviceId,
                "ResStatusCode" : String(describing: resStatusCode),
                "InstanceId": jobInstance.instServerId ?? "(unknown)",
                "DocumentId": document.documentId ?? "",
                "ErrorCode": String(describing: eCode),
                "ErrorMessage": String(describing: message)])
                
                if let errorCode = eCode as? NSInteger {
                    
                    // Store document error details and number of times occurred
                    let totalErrCount = DBErrorLogServices.addUpdateErrorObject(forInstance: nil, forDocument: document, forErrorCode: errorCode, forErrorMsg: String(describing: message))
                    if totalErrCount >= Constants.DocErrorThresholdMaxCounter {
                        
                        Analytics.logEvent("Document tried to send more than \(Constants.DocErrorThresholdMaxCounter) times", parameters: ["Username": appInfo.username ?? "",
                        "DocumentId": document.documentId ?? "NoID",
                        "InstanceId": jobInstance.instServerId ?? "Unknown"])
                        document.isSent = NSNumber(value: true)
                        DBDocumentServices.updateDocument(documentModel: document)
                        isSentSuccessfully = true
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: resStatusCode, msgToDisplay: "Photo Upload API Error Reached Max Threshould")
                        
                        return
                    }

                    if errorCode == SendProcErrorCode.InsertFailed.rawValue {
                        jobInstance.status = String(describing: message as? String ?? StringConstants.StatusMessages.UnknownError)
                        // Store Error log in Crashlytics
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: errorCode, msgToDisplay: "Photo Insert Failed")
                        notifyStatusUpdate(instance: jobInstance)
                    }

                    else if errorCode == SendProcErrorCode.DocumentDataNullorEmpty.rawValue {
                        isSentSuccessfully = true
                        document.isDataNull = NSNumber(value: true)
                        document.isSent = NSNumber(value: true)
                        DBDocumentServices.updateDocument(documentModel: document)
                        Analytics.logEvent(StringConstants.AppseeEventMessages.Empty_Photo_Data_Property, parameters: [:])
                        
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: errorCode, msgToDisplay: "Photo Insert Failed: Data Property NULL")
                    }
                    else if errorCode == SendProcErrorCode.DuplicateItmAvailInServerDB.rawValue {
                        // document already exist. make the document as sent
                        document.isSent = NSNumber(value: true)
                        isSentSuccessfully = true
                        DBDocumentServices.updateDocument(documentModel: document)
                    }
                    else if errorCode == SendProcErrorCode.InstIdorClientIdNullInJSON.rawValue {
                        Analytics.logEvent(StringConstants.AppseeEventMessages.InstanceId_ClientId_Empty_In_JSON, parameters: [:])
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: errorCode, msgToDisplay: "Photo Insert Failed: Instance Id null")
                        
                        // This is not applicable for iOS, as database does not allow to add empty clientInstanceId. As roberto asked, I added it.
                        // Get the instance Id again for the clientId.
                        if self.getInstanceServerId(forInstance: jobInstance) {
                            //make the flag flase after successfully retrieve a new token
                            isRecErrorAtTimeOfBGSending = false
                            
                            //Upload the same photo again.
                            isSentSuccessfully = self.uploadDocument(document: document, ordinal: ordinal, jobInstance: jobInstance)
                        }
                    }
                    else if errorCode == SendProcErrorCode.InstDoesNotExistOrDeletedInServerDB.rawValue {
                        
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: errorCode, msgToDisplay: "Photo Upload Failure: Instance not exist")
                        if jobInstance.instServerId != nil && jobInstance.instServerId != "" {
                            Analytics.logEvent(StringConstants.AppseeEventMessages.InstanceId_ClientInstanceId_Not_Found, parameters: [:])
                            
                            //System will make the instance POST request next time.
                            jobInstance.instServerId = ""
                            jobInstance.isSent = NSNumber(value: false)
                            jobInstance.isSentForProcessing = NSNumber(value: true)
                            DBDocumentServices.markAllDocumentsAsNotSent(forInstance: jobInstance.instId ?? "")
                            DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
                        }
                    }
                    else if errorCode == SendProcErrorCode.InvalidBackSlash.rawValue {
                        // This is not applicable for iOS app, since we generate the image json on fly before send it to server.
                        //Appsee.addEvent(StringConstants.AppseeEventMessages.BackSlash_Found_In_Doc)
                        // continue sending process. System will generate the image JSON again.
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: errorCode, msgToDisplay: "Photo Insert Failed: Invalid Back Slash")
                    }
                    else {
                        jobInstance.status = String(describing: message as? String ?? StringConstants.StatusMessages.UnknownError)
                        notifyStatusUpdate(instance: jobInstance)
                        
                        self.tracErrorInCrashlytics(forErrorJson: errorJSON, withStatusCode: errorCode, msgToDisplay: "Photo Insert Failed: Unknown Error")
                    }
                }
            }
        }
        else {
            Analytics.logEvent(StringConstants.AppseeEventMessages.Failed_To_Upload_Image, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId, "RequestStatusCode": resStatusCode,"ErrorMessage": StringConstants.StatusMessages.UnknownError])
            
            jobInstance.status = StringConstants.StatusMessages.UnknownError
            notifyStatusUpdate(instance: jobInstance)
        }
        DBJobInstanceServices.updateInstanceStatus(jobInstance: jobInstance)
    }
}
