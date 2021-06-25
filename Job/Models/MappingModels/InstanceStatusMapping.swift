//
//  InstanceStatusMapping.swift
//  Job
//
//  Created by Saleh Sultan on 12/4/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class InstanceStatusMapping: NSObject, Codable {
    let lastUpdatedBy: String
    let isSignaturePresent: Bool
    let lastUpdatedDate: String
    let percentageComplete: Int
    let completedDate: String?
    let instanceID: Int
    let isAlreadyCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case lastUpdatedBy = "LastUpdatedBy"
        case isSignaturePresent = "IsSignaturePresent"
        case lastUpdatedDate = "LastUpdatedDate"
        case percentageComplete = "PercentageComplete"
        case completedDate = "CompletedDate"
        case instanceID = "InstanceId"
        case isAlreadyCompleted = "IsAlreadyCompleted"
    }
    
    func updateLocalInstanceStatus(jobInst: JobInstanceModel) {
        jobInst.instServerId = String(self.instanceID)
        if self.percentageComplete == 100 {
            if let compDate = completedDate {
                jobInst.completedDate = Utility.dateFromGMTdateString(dateStr: compDate, withTimeZone: "UTC") as NSDate
                jobInst.instanceSentTime = Utility.dateFromGMTdateString(dateStr: compDate, withTimeZone: "UTC") as NSDate
                jobInst.isCompleted = NSNumber(value: true)
                jobInst.isSent = NSNumber(value: true)
                jobInst.isCompleteNSend = NSNumber(value: true)
                jobInst.isSentOrUpdated = NSNumber(value: true)
                jobInst.status = StringConstants.StatusMessages.SuccessfullySent + " by " + self.lastUpdatedBy
                DBJobInstanceServices.updateJobInstance(jobInstance: jobInst)
            }
            else {
                jobInst.percentCompleted = NSNumber(value: 100)
                DBJobInstanceServices.updateJobInstance(jobInstance: jobInst)
            }
        }
    }
}
