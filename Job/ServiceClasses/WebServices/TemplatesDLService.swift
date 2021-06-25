//
//  TemplatesDLService.swift
//  Job V2.0
//
//  Created by Saleh Sultan on 05/19/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import FirebaseAnalytics

class TemplatesDLService: BaseService {
    
    static let sharedInstance = TemplatesDLService()
    let appInfo = AppInfo.sharedInstance
    
    var delegate:LoginOberverDelegate! = nil
    
    // These are the headers that are required at the time of Templete service call
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
    
    
    // Download All job templates
    func fetchAllTemplates(_ jobTempArr: NSMutableArray) {
        var totalDownloaded = 0
        for item in jobTempArr {
            if let template = item as? JobTemplate {
                
                self.downloadTemplate(template, completion: {
                    totalDownloaded = totalDownloaded + 1
                    
                    self.delegate.increaseProgressbar()
                    
                    //If all the templates are downloaded then tell the delegate that login was successful and do further steps
                    if totalDownloaded == jobTempArr.count {
                        self.delegate.templateDownloaded = true
                        self.delegate.loginSuccess(isOfflineLogin: false)
                    }
                })
            }
        }
    }
    
    func downloadTemplate(_ template: JobTemplate, completion:@escaping () ->()) {
        let templateURL = appInfo.httpType + appInfo.baseURL + Constants.APIServices.templateServiceAPI + "\(template.templateId! as String)"
        print("Template URL: " + templateURL);
        self.fetchData(.get, serviceURL: templateURL, params: nil) { (jsonRes, statusCode, isSucceeded) in
            
            if isSucceeded, let json = jsonRes {
                //print("Template: ", json)
                if let tasks = json.object(forKey: "Children") as? NSArray {
                    for item in tasks {
                        DBTaskServices.sharedInstance.saveTask(TaskMapping(dictionary:item as! NSDictionary), template: template, parentTask: nil)
                    }
                }
            } else {
                if let errorJson = jsonRes as? NSMutableDictionary {
                    errorJson.setValue(AppInfo.sharedInstance.username, forKey: "Username")
                    errorJson.setValue(template.templateName ?? "", forKey: "Template")
                    Analytics.logEvent("Failed to download Template, StatusCode: \(statusCode)", parameters: errorJson as? [String : Any])
                } else {
                    Analytics.logEvent("Failed to download Template, StatusCode: \(statusCode)", parameters: ["Username": AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId, "Template": template.templateName ?? ""])
                }
                DBTemplateServices.sharedInstance.roleBackTemplateLastUpdatedDate(template: template)
            }
            
            completion()
        }
    }
}
