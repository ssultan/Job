//
//  ProjectModel.swift
//  Job V2
//
//  Created by Saleh Sultan on 7/25/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class ProjectModel: NSObject {
    @objc dynamic var customerId: NSNumber?
    @objc dynamic var customerName: String?
    @objc dynamic var lastUpdatedOn: NSDate?
    @objc dynamic var programId: NSNumber?
    @objc dynamic var programName: String?
    @objc dynamic var projectDesc: String?
    @objc dynamic var projectId: String?
    @objc dynamic var projectName: String?
    @objc dynamic var projectNumber: String?
    @objc dynamic var locationList = [LocationModel]()
    
    
    init(project: Project) {
        self.customerId = project.customerId
        self.customerName = project.customerName
        self.lastUpdatedOn = project.lastUpdatedOn
        self.programId = project.programId
        self.programName = project.programName
        self.projectDesc = project.projectDesc
        self.projectId = project.projectId
        self.projectName = project.projectName
        self.projectNumber = project.projectNumber
    }
    
    init(template: JobTemplate) {
        self.customerId = template.tempProject?.customerId
        self.customerName = template.tempProject?.customerName
        self.lastUpdatedOn = template.tempProject?.lastUpdatedOn
        self.programId = template.tempProject?.programId
        self.programName = template.tempProject?.programName
        self.projectDesc = template.tempProject?.projectDesc
        self.projectId = template.tempProject?.projectId
        self.projectName = template.tempProject?.projectName
        self.projectNumber = template.tempProject?.projectNumber
                
//        for locObj in (template.tempProject?.location)! {
//            if let location = locObj as? Location {
//                self.locationList.append(LocationModel(location: location))
//            }
//        }
    }
}
