//
//  DBTaskServices.swift
//  Job
//
//  Created by Saleh Sultan on 5/20/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit
import CoreData

class DBTaskServices: CoreDataBusiness {
    static var sharedInstance = DBTaskServices()
    var managedObjContext: NSManagedObjectContext!
    
    override init() {
        managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
    }
    
    func saveTask(_ taskModel: TaskMapping, template: JobTemplate, parentTask: Task?) {
        let task = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.TaskEntity, into: managedObjContext) as! Task
        task.accuracy = taskModel.Accuracy as NSNumber
        task.allowNA = taskModel.AllowNA as NSNumber?
        task.taskId = taskModel.Id
        task.taskNo = taskModel.QNo
        task.taskTitle = taskModel.Name
        task.hasChildren = taskModel.Children.count > 0 ? true : false
        task.documentType = taskModel.DocumentType
        task.documentTypeId = taskModel.DocumentTypeId as NSNumber
        task.photoRequired = taskModel.PhotoRequired as NSNumber
        task.required = taskModel.Required as NSNumber
        task.taskDesc = taskModel.LongDescription
        task.taskType = taskModel.DataType
        task.taskTypeId = taskModel.DataTypeId
        task.toolTip = taskModel.ToolTip
        task.jobTemplate = template
        task.parentTask = parentTask
        task.ordinal = taskModel.Ordinal
        task.weight = Int16(taskModel.Weight)
        task.isActive = taskModel.IsActive as NSNumber
        
        do {
            try managedObjContext.save()
        }
        catch {
            print("Failed to save task:\(error)")
        }
        
        for subTask in taskModel.Children {
            self.saveTask(subTask, template: template, parentTask: task)
        }
    }
    
    
    class func getTaskObject(forTaskId taskId: Int) -> Task? {
        let predicate = NSPredicate(format: "taskId = %d)", taskId)
        
        if let task = self.fetchData(CoreDataManager.sharedInstance.managedObjectContext, entityName: Constants.EntityNames.TaskEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate).first as? Task {
            return task
        }
        return nil
    }
}
