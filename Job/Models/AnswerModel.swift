//
//  AnswerModel.swift
//  Job
//
//  Created by Saleh Sultan on 5/29/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class AnswerModel: NSObject {
    @objc dynamic var ansId: String?
    @objc dynamic var ansServerId: String?
    @objc dynamic var taskNo: String?
    @objc dynamic var taskId: String? // This is required for the sync answers, once the template got changed.
    @objc dynamic var flagStatus: NSNumber?
    @objc dynamic var isSkipped: NSNumber?
    @objc dynamic var isAnswerCompleted: NSNumber?
    @objc dynamic var type: String?
    @objc dynamic var value: String?
    dynamic var startDate: NSDate?
    dynamic var endDate: NSDate?
    @objc dynamic var ansDocuments = [DocumentModel]()
    dynamic var comments = [CommentModel]()
    @objc dynamic var task: TaskModel!
    @objc dynamic var dbRawAnsObj: Any?
    var isAnsChanged: Bool = false
    var docCountInServer: NSNumber = NSNumber(value: 0)
    
    init(task: TaskModel) {
        super.init()
        self.ansId = UUID().uuidString
        self.type = task.taskTypeId
        self.task = task
        self.taskNo = task.taskNo
        self.taskId = task.taskId
        self.value = ""
        self.isAnswerCompleted = NSNumber(value: false)
    }
    
    init(answer: Answer) {
        super.init()
        self.ansId = answer.ansId
        self.ansServerId = answer.ansServerId
        self.taskNo = answer.task?.taskNo
        self.isAnswerCompleted = answer.isCompleted
        self.type = answer.taskType
        self.value = answer.value ?? ""
        self.flagStatus = answer.flagStatus
        self.startDate = answer.startDate
        self.endDate = answer.endDate
        self.taskId = answer.taskId
        self.isAnsChanged = Bool(truncating: answer.isAnsChanged ?? 0)
        self.docCountInServer = answer.docCountInServer ?? NSNumber(value: 0);
        
        if let taskObj = answer.task {
            if let parent = taskObj.parentTask {
                self.task = TaskModel(task: taskObj, taskParent: TaskModel(task: parent))
            } else {
                self.task = TaskModel(task: taskObj)
            }
        }
        self.dbRawAnsObj = answer
        
        if let documents = answer.documents {
            for document in documents {
                if let docModel = document as? Document {
                    if !Bool(truncating: docModel.isPhotoDeleted ?? 0) {
                        self.ansDocuments.append(DocumentModel(document: docModel))
                    }
                }
            }
        }
        
        if let comments = answer.comments {
            print("Total Comments: \(comments.count)")
            for commentObj in comments {
                if let comment = commentObj as? Comment {
                    self.comments.append(CommentModel(comment: comment))
                }
            }
        }
    }
    
//    init(answer: AnswerMapper, selectedDBInstance instance: JobInstance) {
//        super.init()
//        let taskObj = DBTaskServices.getTaskObject(forTaskId: answer.questionID)
//        self.ansId = answer.clientID
//        self.ansServerId = String(answer.id)
//        self.taskNo = taskObj!.taskNo
//        self.isAnswerCompleted = answer.end != nil ? true : false
//        self.type = taskObj?.taskType
//        self.value = answer.value
//        self.flagStatus = NSNumber(value: answer.flagged)
//        self.startDate = answer.start?.dateFromString() as NSDate?
//        self.endDate = answer.end?.dateFromString() as NSDate?
//        self.taskId = taskObj!.taskId
//        self.isAnsChanged = false
//
//        if let taskObj = taskObj {
//            if let parent = taskObj.parentTask {
//                self.task = TaskModel(task: taskObj, taskParent: TaskModel(task: parent))
//            } else {
//                self.task = TaskModel(task: taskObj)
//            }
//        }
//
//        if let answerObj = DBAnswerServices.saveAnswerObject(self) { //.updateAnswerModel(forAnsMapModel: ansMapObj)
//            self.dbRawAnsObj = answerObj
//            for comment in answer.commentList {
//                if !self.comments.contains(where: {$0.commentId!.lowercased() == comment.clientID.lowercased()}) {
//                    let commentObj = CommentModel(comment: comment)
//                    commentObj.answerComment = answerObj
//                    commentObj.instanceComment = answerObj.jobInstance
//                    _ = DBJobInstanceServices.saveComment(forCommentObj: commentObj)
//                    self.comments.append(commentObj)
//                }
//            }
//
//            // add empty photo, as the task has been completed
//            if let task = answerObj.task, let eDate = answerObj.endDate, let docs = answerObj.documents {
//                print("count: \(docs.count), task: \(task.taskType ?? ""), endDate: \(eDate)")
//                if answerObj.documents!.count == 0, answerObj.task?.taskType! != TaskType.ParentTask.getTaskName()  {
//                    self.ansDocuments.append(DocumentModel(forAnswerObject: answerObj))
//                }
//            }
//        }
//    }
    
    func syncAnswerToDB() {
        if let instance = AppInfo.sharedInstance.selJobInstance {
            
            // If survey instance is not being created. That means, from field visit page, user directly came to field visit photos page or signature page and added signature name or photo of field visit, then first of all we need to create the instance and then link the field visit photo or signature photo with that instance.
            if instance.instId == nil {
                instance.startDate = NSDate()
                let instanceRawObj = DBJobInstanceServices.insertNewJobInstance(jobInstance: instance)
                instance.dbRawInstanceObj = instanceRawObj
                instance.instId = instanceRawObj.instId
            }
            
            //Save instance answer to answer object
            JobServices.saveAnswer(ansModel: self)
        }
    }
    
    func removeAnswer() {
        if let answerId = self.ansId {
            if JobServices.removeAnswer(ansId: answerId) {
                for imgDoc in self.ansDocuments {
                    if !Utility.deleteImageFromDocumentDirectory(docName: imgDoc.originalName!, folderName: imgDoc.instanceId ?? "") {
                        print("Failed to delete the document from document Directory.")
                    }
                }
            }
        }
    }
    
    func makeJsonForAnswer() -> [String: AnyObject] {
        var answerObj = [String: AnyObject]()
        if let ansServerId = self.ansServerId {
            answerObj[Constants.ApiRequestFields.Key_Id] = ansServerId as AnyObject
        }
        if let clientId = self.ansId {
            answerObj[Constants.ApiRequestFields.Key_ClientId] = clientId as AnyObject
        }
        if let taskId = self.task.taskId {
            answerObj[Constants.ApiRequestFields.Key_QuestionId] = taskId as AnyObject
        }
        if let value = self.value {
            answerObj[Constants.ApiRequestFields.Key_Value] = value as AnyObject
        }
        if let flagged = self.flagStatus {
            answerObj[Constants.ApiRequestFields.Key_Flagged] = "\(flagged.boolValue)" as AnyObject
        }
        if let sDate = self.startDate {
            answerObj[Constants.ApiRequestFields.Key_StartDate] = Utility.stringFromDate(date: sDate as Date, format: Constants.SERVER_EXPECT_DATE_FORMAT_WITH_ZONE) as AnyObject
            //Utility.gmtStringFromDate(date: sDate as Date) as AnyObject
        }
        if let eDate = self.endDate {
            answerObj[Constants.ApiRequestFields.Key_EndDate] = Utility.stringFromDate(date: eDate as Date, format: Constants.SERVER_EXPECT_DATE_FORMAT_WITH_ZONE) as AnyObject
                //Utility.gmtStringFromDate(date: eDate as Date) as AnyObject
        }
        
        let commentList = NSMutableArray()
        for comment in self.comments {
            commentList.add(comment.makeJson())
        }
        answerObj[Constants.ApiRequestFields.Key_Comments] = commentList as AnyObject
        answerObj[Constants.ApiRequestFields.Key_DocumentCount] = self.ansDocuments.count as AnyObject
        return answerObj
    }
    
    
    func isDocumentAlreadyExist(photoURL: URL) -> Bool {
        let documents = JobServices.getAllDocuments(forAnswer: self)
        if let photoId = Utility.getPhotoId(url: photoURL, param: "id") {
            
            for document in documents {
                if photoId == document.documentId! {
                    return true
                }
            }
        }
        return false
    }
    
    func getDocumentResolution() -> ResolutionType {
        return self.task.getDocumentResolution();
    }
    
    func updateLocalAnswerObj(forAnsMapModel ansMapObj: AnswerMapper, isSentInstance:Bool) {
         
        if isSentInstance {  // not sure why codition was before { self.ansServerId == nil || }
            self.isAnsChanged = false
        }
        self.ansId = ansMapObj.clientID.uppercased()
        if (self.ansId! == "00000000-0000-0000-0000-000000000000"){
            self.ansId = UUID().uuidString
        }
        self.ansServerId = String(describing: ansMapObj.id)
        self.docCountInServer = NSNumber(value: ansMapObj.documentCount)
        
        // Only update answer value, if the answer hasn't been changed.
        if !self.isAnsChanged, let taskType = self.task.taskType {
            self.value = ansMapObj.value
            self.isAnswerCompleted = NSNumber(value:   ansMapObj.value == "100"
                                                    || ansMapObj.value == "N/A"
                                                    || (taskType == .ParentTask && Int(self.value ?? "0")! > 0) ? true : false)
            if let start = ansMapObj.start {
                self.startDate = Utility.dateFromGMTdateString(dateStr: start, withTimeZone: "UTC") as NSDate
            }
            if let end = ansMapObj.end {
                self.endDate = Utility.dateFromGMTdateString(dateStr: end, withTimeZone: "UTC") as NSDate
            }
        }
        
        if let answerObj = DBAnswerServices.saveAnswerObject(self) { //.updateAnswerModel(forAnsMapModel: ansMapObj)
            self.manageAnswerComments(forAnsComments: ansMapObj.commentList, withAnsObj: answerObj)
            self.managePhotos(forAnswer: answerObj, withAnsMapper: ansMapObj)
        }
    }
    
    private func manageAnswerComments(forAnsComments ansComments: [AnswerComment], withAnsObj answerObj: Answer) {
        for comment in  ansComments {
            if !self.comments.contains(where: {$0.commentId!.lowercased() == comment.clientID.lowercased()}) {
                let commentObj = CommentModel(comment: comment)
                commentObj.answerComment = answerObj
                commentObj.instanceComment = answerObj.jobInstance
                if DBJobInstanceServices.saveComment(forCommentObj: commentObj) {
                    self.comments.append(commentObj)
                }
            }
            else if let localComment = self.comments.filter({ $0.commentId!.lowercased() == comment.clientID.lowercased() }).first {
                if localComment.commentServerId == 0 {
                    localComment.commentServerId = comment.id
                    DBJobInstanceServices.updateCommentId(commentId: localComment.commentId!, serverCommentId: comment.id)
                }
            }
        }
        
        //Delete comments from Local if not available in server
        for commentLmodel in self.comments.filter({ $0.commentServerId != 0 }) {
            if !ansComments.contains(where: { $0.id == commentLmodel.commentServerId }) {
                if DBJobInstanceServices.deleteComment(forCommentServerId: commentLmodel.commentServerId) {
                    self.comments = self.comments.filter({ $0.commentId != commentLmodel.commentId })
                } else {
                    print("++++++++++ Failed to delete ANSWER comment");
                }
            }
        }
    }
    
    private func managePhotos(forAnswer answerObj: Answer, withAnsMapper ansMapObj: AnswerMapper) {
        // add empty photo, as the task has been completed or NOT completed.
        if let task = answerObj.task, let value = answerObj.value, let docs = answerObj.documents {
            print("count: \(docs.count), ServerDocCount:\(ansMapObj.documentCount), task: \(task.taskType ?? ""), Value: \(value)")
            if answerObj.task?.taskType! != TaskType.ParentTask.getTaskName() {
                
                for documentObj in ansMapObj.documentList {
                    var photoName = Utility.generateDcoumentNameFor(projectNumber: answerObj.jobInstance!.jobTemplate!.tempProject!.projectNumber, storeNumber: answerObj.jobInstance!.jobLocation!.storeNumber, taskNumber: self.taskNo ?? "0", attribute: PhotoAttributesTypes.General, documentType: Constants.JPEG_DOC_TYPE)
                    
                    // Saving process will be first, therefore traditional naming process will cause issue since the timestamp would be same for all the photos.
                    // Continue saving the photo name as coming from the server.
                    if let last = documentObj.documentURL.components(separatedBy: "/").last {
                        photoName = last
                    }
                    
                    var isSavedDoc = false
                    let document = DocumentModel(forAnswerObject: answerObj,withDocObject: documentObj, forDocName: photoName){ (success) in
                        isSavedDoc = success
                    }
                    if isSavedDoc { self.ansDocuments.append(document) }
                }
            }
        }
    }
}
