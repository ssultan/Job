//
//  DBAnswerServices.swift
//  Job V2
//
//  Created by Saleh Sultan on 3/6/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import CoreData

class DBAnswerServices: NSObject {
    
    class func saveAnswerObject(_ answerModel: AnswerModel) -> Answer? {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        do {
            if let ansArr = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.AnswerEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "(ansId = %@ OR ansId = %@) AND jobInstance.manifest.user.userName = %@", answerModel.ansId?.uppercased() ?? "0", answerModel.ansId?.lowercased() ?? "0", AppInfo.sharedInstance.username!)) as? [Answer]
            {
                if let answer = ansArr.first {
                    answer.ansId = answerModel.ansId
                    answer.task = answerModel.task.dbRawInst as? Task
                    answer.ansServerId = answerModel.ansServerId
                    answer.isCompleted = answerModel.isAnswerCompleted ?? NSNumber(value: false)
                    answer.value = answerModel.value ?? ""
                    answer.startDate = answerModel.startDate
                    answer.endDate = answerModel.endDate
                    answer.docCountInServer = answerModel.docCountInServer
                    answer.isAnsChanged = NSNumber(value: answerModel.isAnsChanged)
                    try managedObjContext.save()
                    return answer
                }
            }
            
            let answer = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.AnswerEntity, into: managedObjContext) as! Answer
            answer.ansId = answerModel.ansId
            answer.isCompleted = answerModel.isAnswerCompleted ?? NSNumber(value: false)
            answer.taskType = answerModel.type
            answer.value = answerModel.value ?? ""
            answer.task = answerModel.task.dbRawInst as? Task
            answer.taskId = answerModel.task.taskId
            answer.startDate = answerModel.startDate
            answer.endDate = answerModel.endDate
            answer.docCountInServer = answerModel.docCountInServer
            answer.jobInstance = AppInfo.sharedInstance.selJobInstance.dbRawInstanceObj as? JobInstance
            answer.isAnsChanged = NSNumber(value: answerModel.isAnsChanged)
            try managedObjContext.save()
            return answer
        }
        catch {
            print("Failed to save Answer: \(error)")
            return nil
        }
    }
    
    class func removeAnswerObject( answerId: String) -> Bool {
        let predicateNew = NSPredicate(format: "(ansId = %@ OR ansId = %@) AND jobInstance.manifest.user.userName = %@", answerId.uppercased(), answerId.lowercased(), AppInfo.sharedInstance.username!)
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let isDeleted = CoreDataBusiness.deleteData(managedObjContext, entityName: Constants.EntityNames.AnswerEntity, fetchByPredicate: predicateNew)
        
        if let instance = AppInfo.sharedInstance.selJobInstance.dbRawInstanceObj as? JobInstance {
            for ansObj in instance.answers! {
                if let answer = ansObj as? Answer {
                    if let ansId = answer.ansId {
                        if ansId == answerId {
                            instance.removeFromAnswers(answer)
                            break
                        }
                    }
                }
            }
        }
        return isDeleted
    }
    
    class func updateAnswerId(answerId: String, ansServerId: String) {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicateNew = NSPredicate(format: "(ansId = %@ OR ansId = %@) AND jobInstance.manifest.user.userName = %@", answerId.uppercased(), answerId.lowercased(), AppInfo.sharedInstance.username!)
        if let answer = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.AnswerEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicateNew).first as? Answer {
            
            answer.ansServerId = ansServerId
            do {
                try managedObjContext.save()
            } catch {
                print("Failed to update answer object")
            }
        }
    }
    
    class func answerUpdated(answerId: String, isUpdated: Bool = true) {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicateNew = NSPredicate(format: "(ansId = %@ OR ansId = %@) AND jobInstance.manifest.user.userName = %@", answerId.uppercased(), answerId.lowercased(), AppInfo.sharedInstance.username!)
        if let answer = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.AnswerEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicateNew).first as? Answer {
            
            answer.isAnsChanged = NSNumber(value: isUpdated)
            do {
                try managedObjContext.save()
            } catch {
                print("Failed to update answer object")
            }
        }
    }
    
    class func updateAnswerModel(forAnsMapModel ansModel: AnswerMapper) {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        let predicate = NSPredicate(format: "taskId = %d AND jobInstance.manifest.user.userName = %@", ansModel.questionID, AppInfo.sharedInstance.username!)
        
        if let answer = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.AnswerEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate).first as? Answer {
            
            if Int(answer.ansServerId ?? "0") != ansModel.id {
                answer.ansServerId = String(ansModel.id)
            }
            if answer.ansId != ansModel.clientID {
                answer.ansId = ansModel.clientID
            }
            if let endDate = answer.endDate, let remoteEndD = ansModel.end {
                if remoteEndD != "" && !endDate.isEqual(to: remoteEndD.dateFromString()!) {
                    answer.endDate = remoteEndD.dateFromGMTdateString(withTimeZone: "UTC") as NSDate
                }
            }
            if let startDate = answer.startDate, let remoteStD = ansModel.start {
                if remoteStD != "" && !startDate.isEqual(to: remoteStD.dateFromString()!) {
                    answer.startDate = remoteStD.dateFromGMTdateString(withTimeZone: "UTC") as NSDate
                }
            }
            if (answer.value ?? "") != ansModel.value {
                answer.value = ansModel.value
            }
            
            do {
                try managedObjContext.save()
            } catch {
                print("Failed to update answer object")
            }
        }
    }
}
