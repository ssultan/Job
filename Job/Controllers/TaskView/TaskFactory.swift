//
//  TaskFactory.swift
//  Job
//
//  Created by Saleh Sultan on 6/10/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit


class ParentTaskView: UIViewController {
    
    var jobVisit: JobVisitModel!
    var parentQDelegate: TaskViewDelegate!
    var parFrameHeight: CGFloat = 0
    
    func initFun (jobVisitInfo: JobVisitModel, delegate: TaskViewDelegate) {
        jobVisit = jobVisitInfo
        parentQDelegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class TaskFactory: NSObject {
    class func getTaskVC(forJobVisit jobVisitInfo:JobVisitModel, withViewHeight height:CGFloat) ->ParentTaskView? {
        let storyBoard = UIStoryboard.init(name: "Task", bundle: nil)
        var taskChildView:ParentTaskView!
        
        if let quesType = jobVisitInfo.task.taskType {
            if quesType == .ParentTask {
                AppInfo.sharedInstance.pageAboutToLoad =  StringConstants.AppseePageTitles.TASK_PARENT_PAGE
                return nil
            }
            else {
                AppInfo.sharedInstance.pageAboutToLoad =  StringConstants.AppseePageTitles.TASK_DETAILS_PAGE
                taskChildView = storyBoard.instantiateViewController(withIdentifier: "TaskDetailsVC") as! TaskDetailsViewController
            }
        }
        return taskChildView
    }
}
