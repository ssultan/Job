//
//  TaskServices.swift
//  Job
//
//  Created by Saleh Sultan on 5/29/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class TaskServices: NSObject {

    // 'getAllTasks' function will take the list of all tasks. Resposibilites are -
    // - Ignore all the branchTo tasks if not answered.
    // - Ignore all the child tasks
    // - Ignore all the configurable tasks if not anwered. Load if answered.
    class func getAllTasks(tasks: [TaskModel]?) -> [TaskModel] {
        var filteredTaskList = [TaskModel]()
        
        // Sort the tasks based on ordinal. 'Ordinal' is set by server.
        let taskArray = tasks?.sorted(by: { Float($0.ordinal!)! < Float($1.ordinal!)! })
        
        
        for task in taskArray! {
            
            // - If the task doesn't have any parent Id, then it a parent task. Also if my custome generated array contain this taskId, then ignore that. Because if task is choice of any task then we will ingore that at the time of selecting tasks.
            if task.parentId == nil {
                filteredTaskList.append(task)
            }
                
            else if let _ = task.parentTask {
                filteredTaskList.append(task)
            }
        }
        return filteredTaskList
    }
    
    
//    class func getAllTaskInclBranchTo(tasks: [TaskModel]?) -> [TaskModel] {
//
//        let branchToTask = NSMutableArray()
//        var filteredTaskList = [TaskModel]()
//
//        // Sort the tasks based on ordinal. 'Ordinal' is set by server.
//        let taskArray = tasks?.sorted(by: { Float($0.ordinal!)! < Float($1.ordinal!)! })
//
//
//        for task in taskArray! {
//
//            // - If the task doesn't have any parent Id, then it a parent task. Also if my custom generated array contain this taskId, then ignore that. Because if task is choice of any task then we will ingore that at the time of selecting tasks.
//            if task.parentId == nil && !branchToTask.contains(task.taskId!) {
//
//                filteredTaskList.append(task)
//            }
//            else if task.parentId == nil && branchToTask.contains(task.taskId!) {
//                task.isBranchToTask = true
//                filteredTaskList.append(task)
//            }
//
//
//            else if let _ = task.parentTask {
//                    filteredTaskList.append(task)
//            }
//        }
//        return filteredTaskList
//    }
}
