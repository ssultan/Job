//
//  LocationWService.swift
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
import CoreLocation
import FirebaseAnalytics

let GoogleGeoCodeAPI = "http://maps.google.com/maps/api/geocode/json?sensor=false"
class LocationWService: BaseService {
//    static let sharedInstance = LocationWService()
    let appInfo = AppInfo.sharedInstance
    
    var delegate:LoginOberverDelegate! = nil
    
    override func getHeaders() -> [String: String]? {
        
        let headers = [
            Constants.RequestHeaders.Accept_Type : Constants.DataSendRecType,
            Constants.RequestHeaders.Content_Type : Constants.DataSendRecType,
            Constants.RequestHeaders.DeviceID : appInfo.deviceId,
            Constants.RequestHeaders.AppVersion : appInfo.appVersion,
            Constants.RequestHeaders.SDKVersion : String(describing: UIDevice.current.systemVersion),
            Constants.RequestHeaders.CTClient: Constants.RequestHeaders.kClientType,
            Constants.RequestHeaders.Authorization: appInfo.userAuthToken
        ]
        
        return headers;
    }
    
    
    //This function is reponsible to download Locations For list of projectIDs that we calculated at the time of adding project.
    func fetchAllLocations(projectList: NSMutableArray) {
        
        // Check the database that how many project has no location, i.e. location field is empty for for that project. Get the count and compaire with the list of project location we are about to download here. If the count is not same then we have a problem in our logic
        let projList = DBTemplateServices.sharedInstance.getAllProjListIfNoLocation()
        if projList.count != projectList.count {
            print("Error in Logic to download locations list.................--------------------------------");
        }
        else {
            print("*************************************")
        }
        
        var totalLocDownloaded = 0
        for item in projectList {
            if let project = item as? Project {
                
                self.downloadLocations(project, completion: {
                    totalLocDownloaded = totalLocDownloaded + 1
                    
                    self.delegate.increaseProgressbar()
                    
                    if totalLocDownloaded == projectList.count {
                        self.delegate.locationDownloaded = true
                        self.delegate.loginSuccess(isOfflineLogin: false)
                    }
                })
            }
            else {
                //Appsee.addEvent("Problem with Project Location Download. Please check Coredata.")
            }
        }
    }
    
    func downloadLocations(_ project: Project, completion:@escaping () ->()) {
        if let projId = project.projectId {
            let dlLocURL = appInfo.httpType + appInfo.baseURL + Constants.APIServices.locationServiceAPI + "\(projId)" + "/locations"
            
            // This is NEW for dowloading Location
            let lastUpdateDate = project.lastUpdatedOn
            DBLocationServices.sharedInstance.roleBackProjectLastUpdatedDate(project: project)
            // End of New code

            self.fetchData(.get, serviceURL: dlLocURL, params: nil) { (jsonRes, statusCode, isSucceeded) in
                if isSucceeded {
                    if let locArr = jsonRes as? NSArray {
                        for location in locArr {
                            let locModel = LocationMapping(dictionary: location as! NSDictionary)
                            locModel.ProjectId = project.projectId! as String
                            DBLocationServices.sharedInstance.saveLocation(locModel, project: project)
                        }
                        DBLocationServices.sharedInstance.updateProject(projectId: project.projectId!, updateDate: lastUpdateDate!)
                    }
                } else {
                    if let errorJson = jsonRes as? NSMutableDictionary {
                        errorJson.setValue(AppInfo.sharedInstance.username, forKey: Constants.ApiRequestFields.Key_Username)
                        errorJson.setValue(project.projectName ?? "", forKey: "Project")
                        Analytics.logEvent("Failed to download Project Location, StatusCode: \(statusCode)", parameters: errorJson as? [String: Any])
                    } else {
                        Analytics.logEvent("Failed to download Project Location, StatusCode: \(statusCode)", parameters: ["Username": AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId, "Project": project.projectName ?? ""])
                    }
                }
                completion()
            }
        } else {
            if let projectName = project.projectName {
                Analytics.logEvent("Project ID null during location download", parameters: ["Username": AppInfo.sharedInstance.username ?? "", "ProjectName": projectName])
            }
            completion()
        }
    }
    
    class func geoCodeUsingAddress(address: String, completionHandler:(_ coordinate: CLLocationCoordinate2D)->()) {
        var latitude: Double = 0
        var longitude: Double = 0
        let addressstr : NSString = "\(GoogleGeoCodeAPI)&address=\(address)" as NSString
        let urlStr  = addressstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let searchURL = URL(string: urlStr! as String)!
        do {
            let newdata = try Data(contentsOf: searchURL as URL)
            if let responseDictionary = try JSONSerialization.jsonObject(with: newdata, options: []) as? NSDictionary {
                
                let array = responseDictionary.object(forKey: "results") as! NSArray
                if let dicObj = array.firstObject{
                    let dic = dicObj as! NSDictionary
                    let locationDic = (dic.object(forKey: "geometry") as! NSDictionary).object(forKey: "location") as! NSDictionary
                    latitude = locationDic.object(forKey: "lat") as! Double
                    longitude = locationDic.object(forKey: "lng") as! Double
                }
            }
        }
        catch {
        }
        var center = CLLocationCoordinate2D()
        center.latitude = latitude
        center.longitude = longitude
        completionHandler(center)
    }
}
