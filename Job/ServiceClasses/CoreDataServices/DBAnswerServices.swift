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
            if let ansArr = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.AnswerEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "ansId = %@", answerModel.ansId?.uppercased() ?? "0")) as? [Answer]
            {
                if let answer = ansArr.first {
                    answer.task = answerModel.task.dbRawInst as? Task
                    answer.isCompleted = answerModel.isAnswerCompleted ?? NSNumber(value: false)
                    answer.value = answerModel.value ?? ""
                    answer.startDate = answerModel.startDate
                    answer.endDate = answerModel.endDate
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
            answer.jobInstance = AppInfo.sharedInstance.selJobInstance.dbRawInstanceObj as? JobInstance
            try managedObjContext.save()
            return answer
        }
        catch {
            print("Failed to save Answer: \(error)")
            return nil
        }
    }
    
    class func removeAnswerObject( answerId: String) -> Bool {
        let predicateNew = NSPredicate(format: "ansId = %@", answerId.uppercased())
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
    
    class func updateAnswerObject(answerId: String, ansServerId: String) {
        let managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
        if let answer = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.AnswerEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "ansId = %@", answerId.uppercased())).first as? Answer {
            
            answer.ansServerId = ansServerId
            
            do {
                try managedObjContext.save()
            } catch {
                print("Failed to update answer object")
            }
        }
    }
}
