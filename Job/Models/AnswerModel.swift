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
            for commentObj in comments {
                if let comment = commentObj as? Comment {
                    self.comments.append(CommentModel(comment: comment))
                }
            }
        }
    }
    
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
            answerObj[Constants.ApiRequestFields.Key_StartDate] = Utility.gmtStringFromDate(date: sDate as Date) as AnyObject
        }
        if let eDate = self.endDate {
            answerObj[Constants.ApiRequestFields.Key_EndDate] = Utility.gmtStringFromDate(date: eDate as Date) as AnyObject
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
}
