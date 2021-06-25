//
//  TemplateModel.swift
//  Job V2
//
//  Created by Saleh Sultan on 10/31/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class TemplateModel: NSObject {

    @objc dynamic var templateId: String?
    @objc dynamic var templateLongDesc: String?
    @objc dynamic var templateName: String?
    @objc dynamic var templateShortDesc: String?
    @objc dynamic var templateType: String?
    @objc dynamic var lastUpdatedOn: NSDate?
    @objc dynamic var signatureRequired: Bool = false
    @objc dynamic var isShared: Bool = false
    @objc dynamic var projectNumber: String?
    @objc dynamic var projectName: String?
    @objc dynamic var projectId: String?
//    @objc dynamic var hiddenQuestions: String?
    @objc dynamic var project: ProjectModel!
    @objc dynamic var tasks = [TaskModel]()
    @objc dynamic var dbRawTempObj: AnyObject?
    
    init(template: JobTemplate) {
        self.templateId = template.templateId
        self.templateLongDesc = template.templateLongDesc
        self.templateName = template.templateName
        self.templateType = template.templateType
        self.lastUpdatedOn = template.lastUpdatedOn
        self.projectNumber = template.tempProject?.projectNumber
        self.projectName = template.tempProject?.projectName
        self.projectId = template.tempProject?.projectId
        self.signatureRequired = (template.signatureRequired ?? NSNumber(value: false)).boolValue
        self.isShared = (template.isShared ?? NSNumber(value: false)).boolValue
        self.dbRawTempObj = template
        self.project = ProjectModel(template: template)
        
        if let taskList = template.task {
            for item in taskList.allObjects {
                if let taskItem = item as? Task {
                    self.tasks.append(TaskModel(task: taskItem))
                }
            }
        }
    }
}
