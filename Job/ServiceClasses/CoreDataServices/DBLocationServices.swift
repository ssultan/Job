//
//  DBLocationServices.swift
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

class DBLocationServices: NSObject {
    static var sharedInstance = DBLocationServices()
    var managedObjContext: NSManagedObjectContext!
    
    override init() {
        managedObjContext = CoreDataManager.sharedInstance.managedObjectContext
    }
    
    func getLocation(forStoreNo storeNo: String, forLocId locId:String) -> Location? {
        
        if let locArr = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.LocationEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "storeNumber = %@ AND locationId = %@ AND project.manifest.user.userName = %@", storeNo, locId, AppInfo.sharedInstance.username)) as? [Location]
        {
            if let location = locArr.first {
                return location
            }
        }
        return nil
    }
    
    func updateProject(projectId: String, updateDate: NSDate) {
        if let project = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.ProjectEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "projectId = %@ AND manifest.user.userName = %@", projectId, AppInfo.sharedInstance.username!)).first as? Project
        {
            project.lastUpdatedOn = updateDate
            do {
                try managedObjContext.save()
            } catch {
                print("Failed to update project.")
            }
        }
    }
    
    func roleBackProjectLastUpdatedDate(project: Project) {
        if let project = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.ProjectEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "projectId = %@ AND manifest.user.userName = %@", project.projectId!, AppInfo.sharedInstance.username ?? "")).first as? Project
        {
            project.lastUpdatedOn = Utility.dateFromString(dateStr: "2016-06-15", format: "yyyy-MM-dd")
            do {
                try managedObjContext.save()
            } catch {
                //Appsee.addEvent("Failed to roleback last updated project date.")
            }
        }
    }
    
    
    func saveLocation(_ locationModel: LocationMapping, project: Project) {
        
        if let _ = CoreDataBusiness.fetchData(managedObjContext, entityName:Constants.EntityNames.LocationEntity,
                                                   shortDescriptor: nil, IsAscending: nil,
                                                   fetchByPredicate: NSPredicate(format:
                                                    "storeNumber = %@ AND locationId = %@ AND project.projectId = %@ AND project.manifest.user.userName = %@",
                                                                                 locationModel.Number, locationModel.Id, project.projectId!, AppInfo.sharedInstance.username)).first as? Location {
            
        }
        else {
            let location = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.LocationEntity, into: managedObjContext) as! Location
            location.address = locationModel.Address
            location.city = locationModel.City
            location.locationId = locationModel.Id
            location.locationName = locationModel.Name
            location.state = locationModel.State
            location.zipCode = locationModel.Zip
            location.locationDesc = locationModel.Description
            location.storeId = locationModel.Number
            location.storeNumber = locationModel.Number
            location.jobInstanceCount = Int16(locationModel.JobInstanceCount)
            location.project = project
            location.jobInstance = nil
            
            if let geoLoc = locationModel.GeoLocation {
                if geoLoc.components(separatedBy: ",").count == 2, let lat = geoLoc.components(separatedBy: ",").first, let long = geoLoc.components(separatedBy: ",").last{
                    location.latitude = lat
                    location.longitude = long
                }
            }
            do {
                try managedObjContext.save()
            } catch {
                //print("Failed to save location: \(locationModel.Number). Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func getStateListForProjectId(_ projectId: String) -> [String] {
        if let stateList = CoreDataBusiness.fetchData(managedObjContext, entityName: Constants.EntityNames.LocationEntity, shortDescriptor: "state", IsAscending: true, fetchByPredicate: NSPredicate(format: "project.projectId = %@ AND project.manifest.user.userName = %@", projectId, AppInfo.sharedInstance.username)) as? [Location] {
            
            if let distinctArr = NSSet(array: stateList.map { $0.state! }).sortedArray(using: [NSSortDescriptor(key: nil, ascending: true)]) as? [String] {
                return distinctArr
            }
        }
        return [String]()
    }
    
    
    func getCityListForState(_ projectId: String, state: String) -> [String] {
        if let stateList = CoreDataBusiness.fetchData(managedObjContext, entityName: Constants.EntityNames.LocationEntity, shortDescriptor: "city", IsAscending: true, fetchByPredicate: NSPredicate(format: "project.projectId = %@ AND state = %@ AND project.manifest.user.userName = %@", projectId, state, AppInfo.sharedInstance.username)) as? [Location] {
            
            if let distinctArr = NSSet(array: stateList.map { $0.city! }).sortedArray(using: [NSSortDescriptor(key: nil, ascending: true)]) as? [String] {
                return distinctArr
            }
        }
        return [String]()
    }
    
    func getLocationListForCityState(_ projectId: String, state: String, city: String) -> [LocationModel] {
        
        if let locList = CoreDataBusiness.fetchData(managedObjContext, entityName: Constants.EntityNames.LocationEntity, shortDescriptor: "locationName", IsAscending: true, fetchByPredicate: NSPredicate(format: "project.projectId = %@ AND state = %@ AND city = [cd] %@ AND project.manifest.user.userName = %@", projectId, state, city, AppInfo.sharedInstance.username)) as? [Location] {
            
            var locModelList = [LocationModel]()
            for location in locList {
                locModelList.append(LocationModel(location: location))
            }
            return locModelList
        }
        return [LocationModel]()
    }
}
