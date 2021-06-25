//
//  CommentModel.swift
//  Job
//
//  Created by Saleh Sultan on 5/29/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class CommentModel: NSObject {
    dynamic var commentId: String?
    dynamic var commentText: String?
    dynamic var createdBy: String?
    dynamic var createdDate: NSDate?
    dynamic var flagStatus: Int16 = 0
    dynamic var commentServerId: Int = 0
    dynamic var isComDeleted: Bool = false
    dynamic var isFlag: Bool = false
    dynamic var answerComment: Answer?
    dynamic var instanceComment: JobInstance?
    
    init(comment: Comment) {
        super.init()
        commentId = comment.commentId
        commentServerId = comment.commentServerId
        commentText = comment.commentText
        createdBy = comment.createdBy
        createdDate = comment.createdDate
        flagStatus = comment.flagStatus
        isComDeleted = comment.isComDeleted
        isFlag = comment.isFlag
        answerComment = comment.answerComment
        instanceComment = comment.instanceComment
    }
    
    init(comment: InstanceComment) {
        super.init()
        commentId = comment.clientID.uppercased()
        commentServerId = comment.id
        commentText = comment.text
        createdBy = comment.creator
        createdDate = comment.createdOn.dateFromGMTdateString(withTimeZone: "UTC") as NSDate?
    }
    
    init(comment: AnswerComment) {
        super.init()
        commentId = comment.clientID.uppercased()
        commentServerId = comment.id
        commentText = comment.text
        createdBy = comment.lastUpdatedByFullName
        createdDate = comment.createdOn.dateFromGMTdateString(withTimeZone: "UTC") as NSDate?
    }
    
    override init() {
        super.init()
    }
    
    func makeJson() -> [String: AnyObject]  {
        var commentObj = [String: AnyObject]()
        
        commentObj[Constants.ApiRequestFields.Key_ClientId] = self.commentId! as AnyObject
        commentObj[Constants.ApiRequestFields.Key_CommentTxt] = self.commentText! as AnyObject
        commentObj[Constants.ApiRequestFields.Key_LastUpdatedOn] = Utility.gmtStringFromDate(date: self.createdDate! as Date) as AnyObject
        return commentObj
    }

    func addAnswerComment(comment: AnswerComment) {
        
    }
}
