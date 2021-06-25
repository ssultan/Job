//
//  TaskModel.swift
//  Job
//
//  Created by Saleh Sultan on 5/17/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class TaskModel: NSObject {
    @objc dynamic var accuracy: NSNumber = NSNumber (value: 25)
    @objc dynamic var allowNA: NSNumber?
    @objc dynamic var documentType: String?
    @objc dynamic var documentTypeId: NSNumber?
    @objc dynamic var hasChildren: NSNumber?
    @objc dynamic var longDesc: String?
    @objc dynamic var ordinal: String?
    @objc dynamic var photoRequired: NSNumber?
    @objc dynamic var taskId: String?
    @objc dynamic var taskNo: String?
    @objc dynamic var taskText: String?
    var taskType: TaskType?
    @objc dynamic var taskTypeId: String?
    @objc dynamic var required: NSNumber?
    @objc dynamic var isActive: NSNumber?
    @objc dynamic var unit: String?
    @objc dynamic var toolTip: String?
    @objc dynamic var parentId: String?
    @objc dynamic var parentTask: TaskModel!
    @objc dynamic var subTasks = [TaskModel]()
    @objc dynamic var dbRawInst: AnyObject?
//    @objc dynamic var isBranchToQues: Bool = false
    
    init(task: Task, taskParent: TaskModel? = nil) {
        super.init()
        self.accuracy = task.accuracy ?? NSNumber(value: 25)
        self.documentType = task.documentType
        self.documentTypeId = task.documentTypeId
        self.hasChildren = task.hasChildren
        self.longDesc = task.taskDesc
        self.ordinal = task.ordinal
        self.photoRequired = task.photoRequired
        self.taskId = task.taskId
        self.taskNo = task.taskNo
        self.taskText = task.taskTitle
        self.taskType = task.taskType?.getTaskType()
        self.taskTypeId = task.taskTypeId
        self.required = task.required
        self.isActive = task.isActive
        self.toolTip = task.toolTip
        self.allowNA = task.allowNA
        
        if let qParent = task.parentTask {
            self.parentId = qParent.taskId
        }
        self.parentTask = taskParent
        self.dbRawInst = task
        
        if let qSubTasks = task.subTask {
            for childTaskObj in qSubTasks.allObjects {
                if let childTask = childTaskObj as? Task {
                    self.subTasks.append(TaskModel(task: childTask, taskParent: self))
                }
            }
        }
    }
    
    func getDocumentResolution() -> ResolutionType {
        let resolutionId = Int(truncating: self.documentTypeId ?? 1)
        switch resolutionId {
        case 1:
            return .DefaultPhoto
        case 2:
            return .Pano180Photo
        case 3:
            return .SphericalPhoto
        case 4:
            return .HDPhoto
        default:
            return .DefaultPhoto
        }
    }
    
    //Recursive function to generate task number
    func generateTaskNo(jobVisits: NSMutableArray, updatedTaskNo:String, setNo: Int) -> String {
        if var orgTaskNo = self.taskNo {
            orgTaskNo = self.parentTask.generateTaskNo(jobVisits: jobVisits, updatedTaskNo: updatedTaskNo, setNo: setNo)
            
            // When we will get the parent task number of the current task, then regenerate the number with set config set number and return the task number string value.
            if let tNo = self.taskNo, let parentTaskNo = self.parentTask.taskNo {
                if let subTaskLastIdx = tNo.components(separatedBy: parentTaskNo).last {
                    return "\(orgTaskNo)\(subTaskLastIdx)"
                }
            }
        }
        return ""
    }
}
