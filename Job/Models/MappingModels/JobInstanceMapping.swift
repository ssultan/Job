//
//  JobInstanceMapping.swift
//  Job
//
//  Created by Saleh Sultan on 12/3/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit
import Foundation

// MARK: - JobInstanceMapping
struct JobInstanceMapping: Codable {
    let instanceStatus: InstanceStatus
    let id: Int
    let clientID: String
    let templateID: Int
    let templateName: String
    let answers: [AnswerMapper]
    let projectID, locationID: Int
    let comments: String?
    let startedOn: String
    let completedOn: String?
    let flagged: Bool
    let documentCount, userID: Int
    let userName: String
    let transactionID: Int
    let deviceID: String?
    let discrepancyPercentage, discrepancyOccurranceCount, discrepancyDefinitionCount, severityID: String?
    let authorizedUserName, isApproved, originalTimeZone: String?
    let percentComplete: Int
    let statusName: String
    let statusID: Int
    let instanceComments: [InstanceComment]
    let lastUpdatedBy: String?
    let documentList:[DocumentObj]

    enum CodingKeys: String, CodingKey {
        case instanceStatus = "InstanceStatus"
        case id = "Id"
        case clientID = "ClientId"
        case templateID = "TemplateId"
        case templateName = "TemplateName"
        case answers = "Answers"
        case projectID = "ProjectId"
        case locationID = "LocationId"
        case comments = "Comments"
        case startedOn = "StartedOn"
        case completedOn = "CompletedOn"
        case flagged = "Flagged"
        case documentCount = "DocumentCount"
        case userID = "UserId"
        case userName = "UserName"
        case transactionID = "TransactionId"
        case deviceID = "DeviceId"
        case discrepancyPercentage = "DiscrepancyPercentage"
        case discrepancyOccurranceCount = "DiscrepancyOccurranceCount"
        case discrepancyDefinitionCount = "DiscrepancyDefinitionCount"
        case severityID = "SeverityId"
        case authorizedUserName = "AuthorizedUserName"
        case isApproved = "IsApproved"
        case originalTimeZone = "OriginalTimeZone"
        case percentComplete = "PercentComplete"
        case statusName = "StatusName"
        case statusID = "StatusId"
        case instanceComments = "CtPostsList"
        case lastUpdatedBy = "LastUpdatedBy"
        case documentList = "Documents"
    }
}

// MARK: - Answer
struct AnswerMapper: Codable {
    let id: Int
    let clientID: String
    let questionID: Int
    let value: String
    let flagged: Bool = false
    let setNumber: Int
    let comments: String?
    let commentList: [AnswerComment]
    let start, end: String?
    let documentCount: Int
    let lastUpdatedBy: Int = 0
    let lastUpdatedByFullName: String?
    let isException: Bool
    let documentList:[DocumentObj]

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case clientID = "ClientId"
        case questionID = "QuestionId"
        case value = "Value"
        case flagged = "Flagged"
        case setNumber = "SetNumber"
        case comments = "Comments"
        case commentList = "CommentList"
        case start = "Start"
        case end = "End"
        case documentCount = "DocumentCount"
        case lastUpdatedBy = "LastUpdatedBy"
        case lastUpdatedByFullName = "LastUpdatedByFullName"
        case isException = "IsException"
        case documentList = "Documents"
    }
}

// MARK: - CommentList
struct AnswerComment: Codable {
    let text: String
    let lastUpdatedOn: String?
    let lastUpdatedBy: Int
    let lastUpdatedByFullName: String?
    let clientID: String?
    let id: Int
    let name: String?
    let createdOn: String

    enum CodingKeys: String, CodingKey {
        case text = "Text"
        case lastUpdatedOn = "LastUpdatedOn"
        case lastUpdatedBy = "LastUpdatedBy"
        case lastUpdatedByFullName = "LastUpdatedByFullName"
        case clientID = "ClientId"
        case id = "Id"
        case name = "Name"
        case createdOn = "CreatedOn"
    }
}

// MARK: - InstanceComments
struct InstanceComment: Codable {
    let id: Int
    let createdOn: String
    let createdBy: Int
    let creator: String?
    let lastUpdatedBy: Int = 0
    let updator: String?
    let lastUpdatedOn: String?
    let type, resourceID: Int
    let parentID: Int64?
    let text: String
    let replies: [InstanceComment]?
    let clientID: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case createdOn = "CreatedOn"
        case createdBy = "CreatedBy"
        case creator = "Creator"
        case lastUpdatedBy = "LastUpdatedBy"
        case updator = "Updator"
        case lastUpdatedOn = "LastUpdatedOn"
        case type = "Type"
        case resourceID = "ResourceId"
        case parentID = "ParentId"
        case text = "Text"
        case replies = "Replies"
        case clientID = "ClientId"
    }
}

// MARK: - InstanceStatus
struct InstanceStatus: Codable {
    let instanceID: Int
    let completedDate: String?
    let percentageComplete: Int
    let lastUpdatedBy, lastUpdatedDate: String?
    let isSignaturePresent, isAlreadyCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case instanceID = "InstanceId"
        case completedDate = "CompletedDate"
        case percentageComplete = "PercentageComplete"
        case lastUpdatedBy = "LastUpdatedBy"
        case lastUpdatedDate = "LastUpdatedDate"
        case isSignaturePresent = "IsSignaturePresent"
        case isAlreadyCompleted = "IsAlreadyCompleted"
    }
}


struct DocumentObj: Codable {
    let documentURL: String
    let docServerId: Int64
    let docId: String?

    enum CodingKeys: String, CodingKey {
        case documentURL = "DocumentURL"
        case docServerId = "Id"
        case docId = "ClientId"
    }
}
