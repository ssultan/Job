//
//  DBTemplateServices.swift
//  Job V2.0
//
//  Created by Saleh Sultan on 05/19/19.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import CoreData
//import Appsee

class DBTemplateServices: NSObject {
    static var sharedInstance = DBTemplateServices()
    var tempManifest: Manifest!
    var managedObjContext: NSManagedObjectContext!
    
    override init() {
        managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
    }
    
    
    func getTemplateUsingTemplateId(templateId: String) -> JobTemplate? {
        if let tempArr = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.TemplateEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "templateId = %@ AND tempProject.manifest.user.userName = %@", templateId, AppInfo.sharedInstance.username)) as? [JobTemplate]
        {
            if tempArr.count > 0 {
                return tempArr[0]
            }
            return nil
        }
        return nil
    }
    
    func getAllTemplatesForCurrentUser() -> [TemplateModel]? {
        if let tempArr = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.TemplateEntity, shortDescriptor: "templateName", IsAscending: true, fetchByPredicate: NSPredicate(format: "tempProject.manifest.user.userName = %@", AppInfo.sharedInstance.username)) as? [JobTemplate]
        {
            var tempModelArr = [TemplateModel]()
            for template in tempArr {
                tempModelArr.append(TemplateModel.init(template: template))
            }
            return tempModelArr
        }
        return nil
    }
    
    
    func getDownloadableJobListAfterDBsync(_ templateMoList: NSMutableArray, manifest: Manifest, completionHandler:(_ needToDLTempList:NSMutableArray, _ needToDLLocList:NSMutableArray)->()) {
        
        let needToDLTemplates = NSMutableArray()
        let needToDLLocations = NSMutableArray()
        self.tempManifest = manifest
        
        if let tempArr = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.TemplateEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "tempProject.manifest.user.userName = %@", self.tempManifest.user!.userName!)) as? [JobTemplate]
        {
            for template in tempArr {
                if let templateId = template.templateId, let _ = template.tempProject, let projectId = template.tempProject?.projectId {
                    let predicate = NSPredicate(format: "Id = %d and ProjectId = %@", Int(templateId)!, projectId)
                    
                    //If the same template is already availalbe in Database
                    if let templateObj = templateMoList.filtered(using: predicate).first {
                        if let item = templateObj as? TemplateMapping, let lastDBUpdateOn = template.lastUpdatedOn {
                            
                            // If the template project last update date is the same as the user's device that template date. Then remove this item from queue list as we already downloaed that templates details. Otherwise remove that template and associated all the template details
                            if item.LastUpdatedOn == lastDBUpdateOn, let tasks = template.task  {
                                
                                // If no tasks are available for that template, we task download request was failed last time
                                if tasks.count == 0 {
                                    managedObjContext.delete(template)
                                    try! managedObjContext.save()
                                    continue
                                }
                                
                                
                                //If the template is already downloaded into our database and we are not going to download it again, then check the project details. If the project last update date is not the same is user's current database, then update the project details and redownload the associated locations.
                                self.addUpdateProjectDetails(item, completion: { (proj, isNeedToDlLoc) in
                                    
                                    // if 'isNeedToDlLoc' flag return true, that means there is a change in the project and we need to download the locations again
                                    if isNeedToDlLoc == true {
                                        needToDLLocations.add(proj)
                                    }
                                })
                                templateMoList.remove(templateObj)
                            }
                            else  {
                                managedObjContext.delete(template)
                                try! managedObjContext.save()
                            }
                        }
                    }
                    else {
                        // If the template(local DB) is not available in the received Manifest response, then remove it from the database.
                        managedObjContext.delete(template)
                        try! managedObjContext.save()
                    }
                }
            }
            
            
            // 'templateMoList' contain the list of templates, we need to add in our database, these are new templates that came in the manifest.
            for item in templateMoList {
                if let templateModel = item as? TemplateMapping {
                    self.addUpdateProjectDetails(templateModel, completion: { (project, isNeedToDlLoc) in
                        if isNeedToDlLoc == true {
                            needToDLLocations.add(project)
                        }
                        if let jobTemp = insertTemplateObject(templateModel: templateModel, project: project) {
                            needToDLTemplates.add(jobTemp)
                        }
                    })
                }
            }
        }
        
        //Syncronize the project and locations. If no template is associated with any project, then delete it and also delete the locations associated with that.
        self.syncProjectsAndLocations()
        
        
        //Check how many project has no location
        let projNoLocList = getAllProjListIfNoLocation()
        if projNoLocList.count > needToDLLocations.count {
            for project in projNoLocList {
                
                let predicate = NSPredicate(format: "projectId = %@", project.projectId!)
                
                if needToDLLocations.filtered(using: predicate).count == 0 {
                    needToDLLocations.add(project)
                }
            }
        }
        
        completionHandler(needToDLTemplates, needToDLLocations)
    }
    
    
    func insertTemplateObject(templateModel: TemplateMapping, project: Project) -> JobTemplate? {
        let template = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.TemplateEntity, into: self.managedObjContext) as! JobTemplate
        template.templateId = String(templateModel.Id)
        template.lastUpdatedOn = templateModel.LastUpdatedOn as NSDate?
        template.templateShortDesc = templateModel.ShortDescription
        template.templateName = templateModel.Name
        template.signatureRequired = templateModel.SignatureRequired as NSNumber?
        template.templateType = templateModel.TypeName
        template.templateLongDesc = templateModel.LongDescription
        template.tempProject = project
        
        do {
            try self.managedObjContext.save()
            return template
        } catch {
            print("Failed to insert new template.")
            return nil
        }
    }
    
    
    
    // Since we are NOT making any separate call to get the list of project. So in the template list that we are getting from Manifest response, we are going to check the project details. If the projectID is NOT available in our database, then add the project details in 'Project' table in sqlite database. IsNeedToDownloadLocation flag should be true here in this sceraio.
    //OR check the Project last updatedOn date, if the date is not the same as we received from the manifest response, then delete the project details and reinsert it. IsNeedToDownloadLocation flag should be true here in this sceraio.
    // Otherwise, IsNeedToDownloadLocation flag will be false. NO need to download locations associated with this Project.
    
    fileprivate func updateProject(_ project: Project, _ tempModel: TemplateMapping) -> Project {
        project.projectName = tempModel.ProjectName
        project.projectNumber = tempModel.ProjectNumber
        project.lastUpdatedOn = tempModel.ProjectLastUpdatedOn as NSDate?
        project.customerId = tempModel.CustomerId as NSNumber?
        project.customerName = tempModel.CustomerName
        project.programId = tempModel.ProgramId as NSNumber?
        project.programName = tempModel.ProgramName
        project.projectId = String(tempModel.ProjectId)
        
        do {
            try managedObjContext.save()
        } catch {
            print("Failed to insert Project.")
        }
        return project
    }
    
    func addUpdateProjectDetails(_ tempModel: TemplateMapping, completion:(_ project:Project, _ isNeedToDlLoc: Bool)->()) {
        
        if let project = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.ProjectEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "projectId = %@ AND manifest.user.userName = %@", tempModel.ProjectId, self.tempManifest.user!.userName!)).first as? Project
        {
            if !project.lastUpdatedOn!.isEqual(to: tempModel.ProjectLastUpdatedOn as Date) {
                _ = CoreDataBusiness.deleteData(managedObjContext, entityName: Constants.EntityNames.LocationEntity, fetchByPredicate: NSPredicate(format: "project.projectId = %@ and project.manifest.user.userName = %@", project.projectId!, self.tempManifest.user!.userName!))
                completion(self.updateProject(project, tempModel), true)
            }
            else {
                completion(project, false)
            }
        }
        else {
            let project = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.ProjectEntity, into: managedObjContext) as! Project
            project.manifest = self.tempManifest
            completion(self.updateProject(project, tempModel), true)
        }
    }
    
    
    
    // This will delete the projects that is not associated with any job template anymore and it will automatically delete the Locations associated with this project, since 'Project' table is One-To-Many Cascade relationship with 'Location' Table.
    
    func syncProjectsAndLocations () {
        let predicate = NSPredicate(format: "ANY jobTemplate.templateId=nil AND manifest.user.userName = %@", AppInfo.sharedInstance.username)
        if let projectList = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.ProjectEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate) as? [Project]
        {
            for project in projectList {
                managedObjContext.delete(project)
            }
            
            do {
                try managedObjContext.save()
            } catch {
                print("Failed to delete project and locations.")
            }
        }
    }
    
    
    // Get the list of project details by project Id and logged in userName.
    func getProjectDetailsForProjectId(projectId: String) -> Project? {
        if let projectList = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.ProjectEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "manifest.user.userName = %@ AND projectId = %@", AppInfo.sharedInstance.username, projectId)) as? [Project]
        {
            if projectList.count > 0 {
                return projectList[0]
            }
        }
        return nil
    }
    
    
    
    
    // This function is for second check if number of project locations we are about to download is same as our project location null field or not.
    func getAllProjListIfNoLocation(forUsername username:String = AppInfo.sharedInstance.username) -> [Project] {
        var projectMoList = [Project]()
        
        if let projectArr = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.ProjectEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "manifest.user.userName = %@ AND ANY location.locationId = nil", username)) as? [Project]
        {
            for project in projectArr {
                projectMoList.append(project)
            }
        }
        
        return projectMoList
    }
    
    
    func roleBackTemplateLastUpdatedDate(template: JobTemplate) {
        template.lastUpdatedOn = Utility.dateFromString(dateStr: "2016-06-15", format: "yyyy-MM-dd")
        do {
            try managedObjContext.save()
        } catch {
            //Appsee.addEvent("Failed to roleback last updated on Date for Template.")
        }
    }
}
