//
//  JobVisitModel.swift
//  Job
//
//  Created by Saleh Sultan on 5/29/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class JobVisitModel: NSObject {
    @objc var taskNo: String!
    @objc var task: TaskModel!
    @objc var answer: AnswerModel!
    @objc var ordinal: String!
    @objc var parentFVModel: JobVisitModel!
    var subFVModels = [JobVisitModel]()
    
    @objc static var sharedInstance = JobVisitModel()
    
    override init() {
        super.init()
    }
    
    init(taskModel: TaskModel) {
        super.init()
        self.taskNo = taskModel.taskNo
        self.task = taskModel
        self.answer = AnswerModel(task: taskModel)
    }
    
    init(taskModel: TaskModel, answerModel: AnswerModel) {
        super.init()
        self.taskNo = taskModel.taskNo
        self.task = taskModel
        self.answer = answerModel
    }
    
    func connectSubtasksWithParent(_ ansModel: AnswerModel, _ answers: [Any]) {
        self.answer = ansModel
        
        let subFvModelArr = self.subFVModels.sorted(by: { Int($0.task.ordinal ?? "0")! < Int($1.task.ordinal ?? "0")! })
        for subFV in subFvModelArr {
            
            if let taskId = subFV.task.taskId {
                if let subAnsObj = answers.filter({ ($0 as! Answer).task!.taskId ?? "-1" == taskId}).first
                {
                    if let subTaskAns = subAnsObj as? Answer {
                        let subTaskAnsModel = AnswerModel(answer: subTaskAns)
                        
                        //Update task number here. This will prevent issue after adding task at the middle of the survey.
                        subTaskAnsModel.taskNo = subFV.taskNo
                        subFV.answer = subTaskAnsModel
                    }
                }
            }
        }
    }
    
    func checkFieldVisitIfCompleted(_ numOfAnsRequired: inout Int, _ numOfPicRequired: inout Int) -> Bool {
        var isTaskCompleted = true
        
        if let task = self.task, let answer = self.answer {
            if (task.isActive ?? 0).boolValue && !Bool(truncating: answer.isAnswerCompleted ?? 0) {
                
                if task.taskType == TaskType.SubTask { // Josh said: All sub-tasks are required, even though it mark as not required
                    guard let perCompleted = Int(answer.value!) else {
                        numOfAnsRequired += 1
                        isTaskCompleted = false
                        return isTaskCompleted
                    }
                    if perCompleted < 100 || answer.startDate == nil || answer.endDate == nil { // task won't have any completed date if the percent of completed is less than 100%.
                        numOfAnsRequired += 1
                        isTaskCompleted = false
                    }
                }
                
                // Josh said: even though all the subtask required photo by default(in the template photo required field is true always), but we'll relay on 'photoReuired' field, as some OPs Mgr might want to make it optional.
                if Bool(truncating: task.photoRequired!) && answer.ansDocuments.count == 0 {
                    if Bool(truncating: task.required!) || (!Bool(truncating: task.required ?? 0) && answer.value != "") {
                        numOfPicRequired += 1;
                        isTaskCompleted = false
                    }
                }
            }
        }
        return isTaskCompleted
    }
    
    func checkSubTaskPhotoTaken(_ numOfPicRequired: inout Int) -> Bool {
        var isTaskCompleted = true
        
        if let task = self.task, let answer = self.answer {
            if (task.isActive ?? 0).boolValue && !Bool(truncating: answer.isAnswerCompleted ?? 0) {
                
                if task.taskType == TaskType.SubTask { 
                    if let perCompleted = Int(answer.value!), (Bool(truncating: task.photoRequired!) && answer.ansDocuments.count == 0) {
                        if perCompleted == 100 {
                            numOfPicRequired += 1;
                            isTaskCompleted = false
                        }
                    }
                }
            }
        }
        return isTaskCompleted
    }
    
    func countNoOfPhotosNeedToSend(_ isSent: Bool) -> Int {
        var totalPhotos = 0
        
        if let answer = self.answer {
            totalPhotos += answer.ansDocuments.count > 0 ? answer.ansDocuments.filter({ $0.isSent == NSNumber(value: isSent)  }).count : 0
            
            for subFVModel in self.subFVModels {
                totalPhotos += subFVModel.countNoOfPhotosNeedToSend(isSent)
            }
        }
        return totalPhotos
    }
}
