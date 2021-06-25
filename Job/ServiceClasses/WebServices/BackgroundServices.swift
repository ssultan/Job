//
//  BackgroundServices.swift
//  JobV2.0
//
//  Created by Saleh Sultan on 7/24/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import FirebaseAnalytics
import Alamofire
import FirebaseCrashlytics
import UserNotifications

public let KeyInstanceId = "instanceId"
public let KeyUserId = "UserId"
public let KeyStatus     = "status"
public let KeyInstanceSentTime = "instanceSuccSentTime"
public let KeyInstServerId = "instanceServerId"

@objc class BackgroundServices: BaseService {
    let appInfo = AppInfo.sharedInstance
    static var sharedInstance = BackgroundServices()
    var timer: DispatchSourceTimer!
    let semaphore = DispatchSemaphore(value: 0)
    var isRecErrorAtTimeOfBGSending = false
    var isTimerSuspended = true
    var isRecMemWarning: Bool = false
    var isFirstThread: Bool = true
    
    // This queue can only contain job instances, if user completed one instance and tried to send that instance, while background thread was prcessing some instance or document.
    var bgQueueForCompletedInst = [JobInstanceModel]()
    
    // This lock will stop executing running time if the previous process is still running.
    let lock = NSLock()
    
    
    // These are the headers that are required at the time of Templete service call
    override func getHeaders() -> [String: String]? {
        
        let headers = [
            Constants.RequestHeaders.Accept_Type : Constants.DataSendRecType,
            Constants.RequestHeaders.Content_Type : Constants.DataSendRecType,
            Constants.RequestHeaders.DeviceID : self.appInfo.deviceId,
            Constants.RequestHeaders.AppVersion : appInfo.appVersion,
            Constants.RequestHeaders.CTClient: Constants.RequestHeaders.kClientType,
            Constants.RequestHeaders.SDKVersion : String(describing: UIDevice.current.systemVersion),
            Constants.RequestHeaders.Authorization: AppInfo.sharedInstance.userAuthToken
        ]
        
        return headers
    }
    
    func maxMbAppCanUse() -> Float{
        return 600.00
    }

    //MARK: - Intialize Timer
    func startTimer() {
        
        if timer == nil {
            isFirstThread = true
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.BG_THREAD_STARTED)
            timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
            timer.schedule(deadline: .now() + .seconds(1), repeating: .seconds(Constants.BGThreadRefreshInerval))
            timer.setEventHandler { [weak self] in
                
                // If there is no process running
                guard let selfObj = self else {
                    return
                }

                if selfObj.lock.try() == true {
                    // Keep the background process running in 'Default' thread. Because in background thread we are loading data from the database. Keep the thread separate, so that it does not conflict.
                    DispatchQueue.global().async { //[weak self] in
                        // assign this class 'utility' to long-running tasks whose progress the user does not follow actively.
                        var bgTask:UIBackgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: Constants.JobBgUpService) {}
                        
                        // For completed or incompleted instances, if the system received the memory worning, then completed the previous steps first.
                        if selfObj.isRecMemWarning {
                            selfObj.isRecMemWarning = false
                            selfObj.sendUnsentPhotoBecauseOfMemWarning()
                        }
                        
                        if !selfObj.isRecMemWarning {
                            selfObj.sendAllInstance(completion: { (isFinished) in
                                DispatchQueue.main.sync {
                                    selfObj.isFirstThread = false
                                    selfObj.lock.unlock()
                                }
                                
                                if isFinished {
                                    Utility.showAlertMsgWhenRunningInBG(withMessage: StringConstants.StatusMessages.BG_Upload_Process_Success_Message, withTitle: StringConstants.StatusMessages.BG_Upload_Process_Success_Message_Title)
                                }
                                
                                // End the background task when done
                                UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
                                bgTask = UIBackgroundTaskIdentifier.invalid
                            })
                        } else {
                            DispatchQueue.main.sync {
                                selfObj.isFirstThread = false
                                selfObj.lock.unlock()
                                
                                // End the background task when done
                                UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
                                bgTask = UIBackgroundTaskIdentifier.invalid
                            }
                        }
                    }
                }
                else { print("Already Locked. Some process is still runing in the previous thread. So don't let the thread run now."); }
            }
        }
        
        if isTimerSuspended {
            self.timer.resume()
            isTimerSuspended = false
        } else {
            print("Timer is running.")
        }
    }
    
    func stopTimer() {
        if self.timer != nil && !isTimerSuspended {
            self.timer.suspend()
            isTimerSuspended = true
        }
    }
    
    deinit {
        //Appsee.addEvent("DeInit function get called.")
        if self.timer != nil {
            self.timer.suspend()
            isTimerSuspended = true
        }
    }
    
    
    //MARK: - Get a new Token
    func loginInBackgroundToGetNewToken() -> Bool {
        
        var isGotNewToken:Bool = false
        let loginURL = appInfo.httpType + appInfo.baseURL + Constants.APIServices.loginServiceAPI
        self.fetchData(.post, serviceURL: loginURL, params: ["Username": (AppInfo.sharedInstance.username ?? "") as AnyObject,
                                                             "Password": (AppInfo.sharedInstance.password ?? "") as AnyObject]) { (jsonRes, statusCode, isSucceeded) in
            
            if(isSucceeded) {
                if let response = jsonRes {
                    if let token = response[Constants.ApiRequestFields.Key_Token] as? String {
                        self.appInfo.userAuthToken = token
                        
                        if let user = DBUserServices.getUsersForUsername(self.appInfo.username, environment: nil).first
                        {
                            user.token = token
                            if !(DBUserServices.updateUserDetails(forUserModel: user)) {
                                print("Failed to update token.")
                            }
                        }
                        isGotNewToken = true
                    }
                }
                
            }
            self.semaphore.signal()
        }
        if self.semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
            print("Login background Timed out.")
        }
        
        return isGotNewToken
    }
    
    
    func sendCompletedInstance(instance: JobInstanceModel, isUpdatingJob:Bool = false) {
        // Try to send the instance right after user hit the 'Complete and Send' button; if NSLock is free. Otherwise put it into a queue.
        if self.lock.try() == true {
            // This will make sure that if a process is running in background thread and user hit the home button then system will give some time to complete current process.
            var bgTask:UIBackgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: Constants.JobBgUpService) {}
            self.sendInstance(jobInstance: instance, isUpdating: isUpdatingJob)
            
            if let status = instance.status {
                if status.contains(StringConstants.StatusMessages.SuccessfullySent) || status.contains(StringConstants.StatusMessages.SuccessfullyUpdated) {
                    
                    Utility.showAlertMsgWhenRunningInBG(withMessage: StringConstants.StatusMessages.BG_Upload_Process_Success_Message, withTitle: StringConstants.StatusMessages.BG_Upload_Process_Success_Message_Title)
                } else {
                    Utility.showAlertMsgWhenRunningInBG(withMessage: status, withTitle: StringConstants.StatusMessages.BG_Upload_Process_Failure_Msg_Title)
                }
            }
            self.lock.unlock()
            
            // End the BG task
            UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
            bgTask = UIBackgroundTaskIdentifier.invalid
            
        } else {
            print("************************************************Added to the BG Queue")
            self.bgQueueForCompletedInst.append(instance)
        }
    }
    
    
    //MARK: - Send All the instance
    func sendAllInstance(completion: (_ isFinished: Bool) -> Void) {
        
        // Remove all objects from the queue, since background thread is going to process all of them now
        if self.bgQueueForCompletedInst.count > 0 {
            //Appsee.addEvent("Executing backlog queue for last completed Job.")
            self.bgQueueForCompletedInst.removeAll()
        }
        
        var isAnythingSent = false
        let completedInstance = DBJobInstanceServices.loadAllJobInstanceForReport(isCompleteInst: true)
        for instance in completedInstance {
            if isRecMemWarning {
                completion(false)
                return
            }
            print("Incompleted Instance from - sendAllInstance")
            sendInstance(jobInstance: instance, isUpdating: false)
            isAnythingSent = true
        }
        
        //Check if there is any incomplete instance that needs to be send to the server. Note: User can make update request of any job
        let inCompletedInstance = DBJobInstanceServices.loadAllJobInstanceForReport(isCompleteInst: false)
        for instance in inCompletedInstance {
            if isRecMemWarning {
                completion(false)
                return
            }
            sendInstance(jobInstance: instance)
            isAnythingSent = true
        }
        
        
        // if there is nothing to sent from previous process (Incomplete and completed instances), then continue below steps to follow up with database if there is any photo that needs to be sent
        if isAnythingSent == false {
            sendUnsentPhotosForCompletedInstances()
            sendUnsentPhotosForIncompletedInstances()
        }
        
        if !isFirstThread { self.requestToDeletePhotosFromServerForCompletedInstances() }
        
        // Before making background thread free to start processing again, check if there is any instances queued. i.e. user completed any instance and marked as send; while BG thread was running to do some process
        self.sendInstancesIfAvailInBGThread()
        
        //Check if system need to fire local notification or not
        if isAnythingSent == true && isRecErrorAtTimeOfBGSending == false {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    fileprivate func sendUnsentPhotosForIncompletedInstances() {
        let allUpdatedInstances = DBJobInstanceServices.getAllUpdateInstancesWhichPhotosAreNotSentYet()
        for instance in allUpdatedInstances {
            let failedToSend = self.sendDocumentsforInstance(instance: instance)
            if failedToSend > 0 && isRecMemWarning {
                return
            }
            instance.updateInstAfterPhotoUploadProcessCompleted(forNumOfFailed: failedToSend, andUpdating: true)
        }
    }
    
    fileprivate func requestToDeletePhotosFromServerForCompletedInstances() {
        // Request to delete all photos from server
        let photosNeedToDelete = DBDocumentServices.getAllDocumentsThoseAreDeleted()
        for document in photosNeedToDelete {
            self.requestToDeleteDocumentFromServer(document: document)
        }
    }
    
    fileprivate func sendInstancesIfAvailInBGThread() {
        while self.bgQueueForCompletedInst.count > 0 {
            if let instance = bgQueueForCompletedInst.first {
                print("BG QUEUE has an instance. Processing that instance.")
                
                // Send instance FIFO order. First In First Out
                if Bool(truncating: instance.isCompleted) && Bool(truncating: instance.isCompleteNSend) {
                    self.sendInstance(jobInstance: instance, isUpdating: false)
                } else {
                    self.sendInstance(jobInstance: instance, isUpdating: true)
                }
                
                self.bgQueueForCompletedInst.removeFirst()
            }
        }
    }
    
    fileprivate func sendUnsentPhotoBecauseOfMemWarning() {
        let photosNotSentYetInstances = DBJobInstanceServices.loadAllCompleteInstThatFailedBecauseOfMemWarning()
        for instance in photosNotSentYetInstances {
            
            let totalDocNeedToSend:Int = instance.getTotalPhotosOfTheInstances(isSent: false)
            if totalDocNeedToSend > 0 {
                let failedToSend = self.sendDocumentsforInstance(instance: instance)
                if failedToSend > 0 && isRecMemWarning {
                    Analytics.logEvent("Skipping photo upload process because of memory warning. Next thread will execute it.", parameters: [:])
                    return
                }
                instance.updateInstAfterPhotoUploadProcessCompleted(forNumOfFailed: failedToSend, andUpdating: false)
            }
        }
    }
    
    fileprivate func sendUnsentPhotosForCompletedInstances() {
        // The main purpose is to check All the instance which acknowldegement flag is still false and that instance object already sent to server. Then check is there any photos/documents that client need to send. If No photos are available to send, then just make that acknowledgement call to update instance flag 'acknowledgement'
        let photosNotSentYetInstances = DBJobInstanceServices.loadAllCompleteInstThatPhotosNotSentYet()
        for instance in photosNotSentYetInstances {
            
            let totalDocNeedToSend:Int = instance.getTotalPhotosOfTheInstances(isSent: false)
            if totalDocNeedToSend > 0 {
                let failedToSend = self.sendDocumentsforInstance(instance: instance)
                if failedToSend > 0 && isRecMemWarning {
                    return
                }
                instance.updateInstAfterPhotoUploadProcessCompleted(forNumOfFailed: failedToSend, andUpdating: false)
            }
            else if instance.succPhotoUploadTime == nil {
                // This is for successfully sent instances only.
                instance.errorCode = 0
                instance.succPhotoUploadTime = NSDate()
                instance.status = StringConstants.StatusMessages.SuccessfullySent
                DBJobInstanceServices.updateJobInstance(jobInstance: instance)
            }
            else if let completelySendDate = instance.succPhotoUploadTime {
                // If NO photos left to upload, then execute photo acknowledgement request after 1(Default) minute from the instance sent time
                
                if let diffInMinute = Calendar.current.dateComponents([.minute], from: completelySendDate as Date, to: Date()).minute {
                    print("\n\n************ Time Difference For Photo Acknowledgement: \(diffInMinute)")
                    if diffInMinute >= Constants.photoAckReqWaitingTimeInMin {
                        self.makePhotoAcknowledgementRequest(forInstance: instance)
                    }
                }
            }
        }
    }
    
    
    //MARK: - SendInstance
    func sendInstance(jobInstance: JobInstanceModel, isUpdating: Bool = true) {
        
        // Check if the system is trying to send/update a job of a template, which is no longer assigned to him/her
        if jobInstance.template == nil || jobInstance.project == nil {
            jobInstance.status = StringConstants.StatusMessages.TemplateNotAssigned
            DBJobInstanceServices.updateInstanceStatus(jobInstance: jobInstance)
            Analytics.logEvent(StringConstants.AppseeEventMessages.Template_Not_Assigned, parameters: ["UserId": jobInstance.user.userName ?? appInfo.deviceId, "TemplateId": jobInstance.templateId ?? ""])
            return
        }
        
        // Update status update
        jobInstance.instanceSentTime = NSDate()
        jobInstance.status = StringConstants.StatusMessages.SendingJob
        DBJobInstanceServices.updateInstanceStatus(jobInstance: jobInstance)
        notifyStatusUpdate(instance: jobInstance)
        
        
        var sendInstanceURL = self.appInfo.httpType + self.appInfo.baseURL + Constants.APIServices.sendInstanceServiceAPI
        let instanceParams = jobInstance.getJSONForJobInstance(isUpdating: isUpdating)
        let jsonStr = String(data: try! JSONSerialization.data(withJSONObject: instanceParams, options: []), encoding: .ascii)
        print(jsonStr);
        
        var method:HTTPMethod = .post
        if let serverId = jobInstance.instServerId  {
            if serverId != "" {
                method = .put
                sendInstanceURL = "\(sendInstanceURL)\(serverId)"
            }
        }
        
        var isSentSucceeded:Bool = false
        var resStatusCode: Int = 0
        var errorJSON: AnyObject!
        self.fetchData(method, serviceURL: sendInstanceURL, params: instanceParams) { (jsonRes, statusCode, isSucceeded) in
            resStatusCode = statusCode
            
            if(isSucceeded) {
                isSentSucceeded = true
                if let jsonDic = jsonRes as? [String: AnyObject] {
                    
                    if let serverId = jsonDic[Constants.ApiRequestFields.Key_Id] {
                        jobInstance.instServerId = String(describing: serverId)
                    }
                    if let userId = jsonDic[Constants.ApiRequestFields.Key_UserId] {
                        jobInstance.user.userId = String(describing: userId)
                    }
                    self.setAnswerId(jsonDic)
                    
                    if (!isUpdating) {
                        jobInstance.isSent = NSNumber(value: true)
                    }
                }
                
                jobInstance.isSentForProcessing = NSNumber(value: false)
                DBJobInstanceServices.updateJobInstance(jobInstance: jobInstance)
            }
            else {
                errorJSON = jsonRes
            }
            
            self.semaphore.signal()
        }
        
        if semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
            print("Send or update instance Timed out.")
        }
        
        if (isSentSucceeded) {
            let failedToSend = self.sendDocumentsforInstance(instance: jobInstance)
            if failedToSend > 0 && isRecMemWarning {
                //Appsee.addEvent("Skipping photo upload process because of memory warning. Next thread will execute it.")
                return
            }
            jobInstance.updateInstAfterPhotoUploadProcessCompleted(forNumOfFailed: failedToSend, andUpdating: isUpdating)
        }
        else {
            isRecErrorAtTimeOfBGSending = true
            self.handleInstanceError(resStatusCode: resStatusCode, jobInstance: jobInstance, errorJSON: errorJSON, isUpdating: isUpdating)
        }
    }
    
    fileprivate func setAnswerId(_ jsonDic: [String : AnyObject]) {
        if let answerArrObj = jsonDic[Constants.ApiRequestFields.Key_Answers] {
            if let answers = answerArrObj as? NSArray {
                for answerObj in answers {
                    if let answer = answerObj as? [String: AnyObject] {
                        if let answerId = answer[Constants.ApiRequestFields.Key_ClientId], let serverId = answer[Constants.ApiRequestFields.Key_Id] {
                            DBAnswerServices.updateAnswerObject(answerId: String(describing: answerId), ansServerId: String(describing: serverId))
                        }
                    }
                }
            }
        }
    }
    
    func getInstanceServerId(forInstance instance:JobInstanceModel) -> Bool {
        var isSentSucceeded:Bool = false
        
        if let instClientId = instance.instId {
            let url = self.appInfo.httpType + self.appInfo.baseURL + Constants.APIServices.GetInstanceIdForClientId + instClientId
            self.fetchData(.get, serviceURL: url, params: nil) { (jsonRes, statusCode, isSucceeded) in
                
                if(isSucceeded) {
                    if let jsonArr = jsonRes as? NSArray {
                        if let instanceObj = jsonArr.firstObject as? [String: AnyObject] {
                            if let instId = instanceObj[Constants.ApiRequestFields.Key_Id] {
                                instance.instServerId = String(describing: instId)
                                DBJobInstanceServices.updateJobInstance(jobInstance: instance)
                                isSentSucceeded = true
                            }
                        }
                        else {
                            Analytics.logEvent(StringConstants.AppseeEventMessages.Failed_To_Get_InstanceId, parameters: ["Response": jsonRes!, "ErrorCode": statusCode])
                        }
                    }
                }
                else {
                    Analytics.logEvent(StringConstants.AppseeEventMessages.Failed_To_Get_InstanceId, parameters: ["Response": jsonRes!, "ErrorCode": statusCode])
                }
                self.semaphore.signal()
            }
            
            if self.semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
                print("Send or update instance Timed out.")
            }
        }
        return isSentSucceeded
    }
    
    
    
    //MARK: - send all the documents for an Instance. Return number of photos failed to send
    fileprivate func uploadAllDocuments(forDocList docList: [DocumentModel], withAnswer answer:AnswerModel?, forInstance instance: JobInstanceModel, _ alreadySent: inout Int, _ totalDocNeedToSend: Int) -> Int {
        
        var ordinal = 1
        var numberOfPhotosFailed:Int = 0
        
        for document in docList {
            let isSent = Bool(truncating: document.isSent ?? 0)
            let isNeedToSend = Bool(truncating: document.isNeedToSend ?? 0)
            
            if !isSent || (isSent && isNeedToSend) {
                if let ansObj = answer {
                    if let ansServerId = ansObj.ansServerId {
                        document.ansServerId = ansServerId
                    }
                }
                if isRecMemWarning {
                    numberOfPhotosFailed += 1
                    continue
                }
                
                instance.status = "Sending Photos \(alreadySent) of \(totalDocNeedToSend)"
                DBJobInstanceServices.updateInstanceStatus(jobInstance: instance)
                
                if (self.uploadDocument(document: document, ordinal: ordinal, jobInstance: instance)) {
                    alreadySent += 1
                }
                else {
                    numberOfPhotosFailed += 1
                }
            }
            
            ordinal += 1
        }
        return numberOfPhotosFailed
    }
    
    // Recurrsive function
    fileprivate func uploadAnswerPhotos(_ fieldVisit: JobVisitModel, _ instance: JobInstanceModel, _ alreadySent: inout Int, _ totalDocNeedToSend: Int) -> Int {
        
        var numberOfPhotosFailed = 0
        if let answer = fieldVisit.answer {
            let documentList = answer.ansDocuments.filter { $0.isPhotoDeleted == NSNumber(value: false) }
                .sorted(by: { (($0.createdDate?.compare(($1.createdDate as Date?)!)) == .orderedAscending) })
            
            numberOfPhotosFailed += self.uploadAllDocuments(forDocList: documentList, withAnswer: answer, forInstance: instance, &alreadySent, totalDocNeedToSend)
        }
        
        // Send photos for sub field visit models. Like multchoice question answers
        for subFVModel in fieldVisit.subFVModels {
            numberOfPhotosFailed += uploadAnswerPhotos(subFVModel, instance, &alreadySent, totalDocNeedToSend)
        }
        return numberOfPhotosFailed
    }
    
    func sendDocumentsforInstance(instance: JobInstanceModel) -> Int {
        var alreadySent:Int = instance.getTotalPhotosOfTheInstances(isSent: true) + 1
        
        // Old approch to get total photos count for an instance from database. This is does not check if the document answer is a branchToQuestion. For now keep it as it is. even i should use the other function 'DBJobInstanceServices.getAllDocumentsThatNeedsToSendForInstnace'
        var totalDocNeedToSend:Int = instance.getTotalPhotosOfTheInstances(isSent: false)
        if totalDocNeedToSend == 0 {
            return 0
        }
        totalDocNeedToSend += (alreadySent-1)
        
        
        let fvPhotos = instance.documents.filter { $0.isPhotoDeleted == NSNumber(value: false) }
            .sorted(by: { (($0.createdDate?.compare(($1.createdDate as Date?)!)) == .orderedAscending) })
        var numberOfPhotosFailed:Int = uploadAllDocuments(forDocList: fvPhotos, withAnswer: nil, forInstance: instance, &alreadySent, totalDocNeedToSend)
        
        for fvModel in instance.jobVisits {
            if let fieldVisit = fvModel as? JobVisitModel {
                numberOfPhotosFailed += uploadAnswerPhotos(fieldVisit, instance, &alreadySent, totalDocNeedToSend)
            }
        }
        return numberOfPhotosFailed
    }
    
    //MARK: - Upload document to the server
    func uploadDocument(document: DocumentModel, ordinal: Int, jobInstance: JobInstanceModel) -> Bool {

        var isSentSuccessfully = false
        var docParams = document.makeJsonForDocument()
        let isSentAlready = Bool(truncating: document.isSent ?? 0)
        let documentClientId = document.documentId != nil ? document.documentId! : ""
        
        //Prepare the URL for document insert or update request
        let sendDocURL = self.appInfo.httpType + self.appInfo.baseURL + (isSentAlready ? Constants.APIServices.DocumentDeleteUpdateAPI : Constants.APIServices.DocumentAPI) + (isSentAlready ? documentClientId : "")
        
        // If the document is not sent yet and JSON parameters returned empty data field, that means physical file doesn't exist anymore. Do not make send request.
        if !isSentAlready && docParams[Constants.ApiRequestFields.Key_Data] == nil {
            return isSentSuccessfully
        }
        
        // Set the oridnal value; which will be responsible for sorting the images in server side
        docParams[Constants.ApiRequestFields.Key_Ordinal] = ordinal as AnyObject
        
        if let status = jobInstance.status, let clientId = jobInstance.instId, let instServerId = jobInstance.instServerId {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.ReloadReportTableNotifier),
                                        object: nil, userInfo: [KeyInstanceId: clientId,
                                                                KeyStatus : status,
                                                                KeyInstServerId: instServerId])
        }
        
        var resStatusCode: Int = 0
        var errorJSON: AnyObject!
        
        Crashlytics.crashlytics().setCustomValue("MB in Use: \(Helper.getMegabytesUsed() ?? 0.0)Mb out of \(Float(ProcessInfo.processInfo.physicalMemory/1000/1000))Mb", forKey: "Memory Usages")
        if isRecMemWarning { return false }
        else if Helper.getMegabytesUsed() ?? 0.0 > maxMbAppCanUse() {
            Analytics.logEvent("App is using over \(maxMbAppCanUse())Mb, so system is going to kill the thread", parameters: [:])
            isRecMemWarning = true
            return false
        }
        
        self.fetchData((isSentAlready ? .put : .post), serviceURL: sendDocURL, params: docParams) { (jsonRes, statusCode, isSucceeded) in
            resStatusCode = statusCode
            
            if(isSucceeded) {
                isSentSuccessfully = true
                
                if let jsonDic = jsonRes as? [String: AnyObject] {
                    if let serverId = jsonDic[Constants.ApiRequestFields.Key_Id] {
                        document.docServerId =  String(describing: serverId)
                    }
                    document.isSent = NSNumber(value: true)
                    document.isNeedToSend = NSNumber(value: false)
                    document.sentTime = NSDate()
                    DBDocumentServices.updateDocument(documentModel: document)
                }
            }
            else {
                errorJSON = jsonRes
            }
            self.semaphore.signal()
        }
        
        if semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
            print("Upload photo Timed out.")
        }
        
        if !isSentSuccessfully {
            isRecErrorAtTimeOfBGSending = true
            handleDocumentErrors(resStatusCode, jobInstance, &isSentSuccessfully, document, ordinal, errorJSON)
        }
        return isSentSuccessfully
    }
    
    func makePhotoAcknowledgementRequest(forInstance instance: JobInstanceModel) {
        guard let instanceId = instance.instServerId else {
            _ = self.getInstanceServerId(forInstance: instance)
            return
        }
        
        // https://staging.clearthread.com/api/document?instanceid=19779&includealldocs=true
        //"http://api.staging.clearthread.com/api/document?instanceid=24318&pageNumber=1&pageSize=1000&includeAllDocs=true"
        let getDocURL = self.appInfo.httpType + self.appInfo.baseURL + Constants.APIServices.GetAllInstanceDocumentsAPI2nd + instanceId + "&pageNumber=1&pageSize=10000&includeAllDocs=true"
        
        var resStatusCode: Int = 0
        var errorJSON: AnyObject!
        self.fetchData(.get, serviceURL: getDocURL, params: nil) { (jsonRes, statusCode, isSucceeded) in
            resStatusCode = statusCode
            
            if(isSucceeded) {
                var docIdList = [String]()
                var docServerIds = [String]()
                
                if let docArray = jsonRes as? NSArray {
                    for docObj in docArray {
                        if let docDic = docObj as? NSDictionary {
                            
                            if let documentId = docDic[Constants.ApiRequestFields.Key_DocumentId] as? String{
                                docIdList.append(documentId.uppercased())
                            }
                            if let docServerId = docDic[Constants.ApiRequestFields.Key_Id] as? Int64 {
                                docServerIds.append(String(docServerId))
                            }
                        }
                    }
                }
                
                instance.finalizeInstance(forDocIdList: docIdList, andServerDocIds: docServerIds)
            }
            else {
                print("Error: failed to get documents")
                errorJSON = jsonRes
            }
            self.semaphore.signal()
        }
        
        if semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
            print("Upload photo Timed out.")
        }
        
        if resStatusCode == HttpRespStatusCodes.TokenExpiredCode.rawValue {
            Analytics.logEvent(StringConstants.AppseeEventMessages.Token_Expired_BG_SendProcess, parameters: ["UserId": instance.user.userName ?? appInfo.deviceId])
            if loginInBackgroundToGetNewToken() {
                self.makePhotoAcknowledgementRequest(forInstance: instance)
            }
        }
        else if resStatusCode == HttpRespStatusCodes.RequestHasErrorCode.rawValue {
            if let resDict = errorJSON as? NSDictionary {
                if let eCode = resDict[Constants.ApiRequestFields.Key_ErrorCode], let message = resDict[Constants.ApiRequestFields.Key_Message] {
                    print("Error \(String(describing: eCode)): \(String(describing: message))")
                    Analytics.logEvent("Failed to make photo Acknowledgment Request", parameters: ["Username": AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId])
                }
            }
        }
    }
    
    //MARK: - Get a document
    func getDocumentDetailsFromServer(document: DocumentModel) {
        let docURL = self.appInfo.httpType + self.appInfo.baseURL + Constants.APIServices.DocumentAPI
        let docParams = document.makeJsonForDocument()
        
        self.fetchData(.get, serviceURL: docURL, params: docParams) { (jsonRes, statusCode, isSucceeded) in
            
            print(jsonRes ?? "")
            if (isSucceeded) {
                // Need to work
            }
            self.semaphore.signal()
        }
        
        if semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
            print("Upload photo Timed out.")
        }
    }
    
    // MARK: - Update or Delete a document
    // Request to delete specific photo document from server, since that photo user deleted from client side
    func requestToDeleteDocumentFromServer(document: DocumentModel) {
        
        //DELETE http://api.staging.clearthread.com/api/MobileDocument/{client_GUID}
        let docDeleteURL = self.appInfo.httpType + self.appInfo.baseURL + Constants.APIServices.DocumentDeleteUpdateAPI + document.documentId!
        
        
        // For deleting a document we don't need to send the parameters
        self.fetchData(.delete, serviceURL: docDeleteURL, params: nil) { (jsonRes, statusCode, isSucceeded) in

            if (statusCode == HttpRespStatusCodes.HTTP_200_OK.rawValue) {
                if !document.deleteDocument() {
                    Analytics.logEvent("\(StringConstants.AppseeEventMessages.Failed_To_Delete_Img_Device)\(AppInfo.sharedInstance.username ?? "")", parameters: ["ImgName": document.name ?? ""])
                }
            } else {
                Analytics.logEvent("\(StringConstants.AppseeEventMessages.Failed_To_Delete_Img_Device)\(AppInfo.sharedInstance.username ?? "")", parameters: ["ImgName": document.name ?? ""])
                print(jsonRes ?? "")
            }
        }
    }
    
    
    func tracErrorInCrashlytics(forErrorJson errorJSON:AnyObject?, withStatusCode eCode:Int, msgToDisplay msg: String) {
        
        // Store Error log in Crashlytics
        if let dic = errorJSON {
            if let userInfo = dic as? [String: Any] {
//                userInfo["AppseeSessionId"] = "https://dashboard.//Appsee.com/home/survey-management#/Videos/Index/\(appInfo.curAppseeSessionId)#ios/all/month/all"
                let error = NSError(domain: msg, code: eCode, userInfo: userInfo)
                Crashlytics.crashlytics().record(error: error as Error)
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
