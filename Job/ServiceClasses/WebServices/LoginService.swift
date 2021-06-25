//
//  LoginService.swift
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
import FirebasePerformance
import FirebaseAnalytics
import FirebaseCrashlytics
import Alamofire

let JobTemplateQS = "&TemplateType=Job"

class LoginService: BaseService {

    static var sharedInstance = LoginService()
    let appInfo = AppInfo.sharedInstance
    var delegate:LoginOberverDelegate! = nil
    var receivedLoginDic = NSMutableDictionary()
    var manifest: Manifest!
    
    override func getHeaders() -> [String: String]? {
        
        var headers = [
            Constants.RequestHeaders.Accept_Type : Constants.DataSendRecType,
            Constants.RequestHeaders.Content_Type : Constants.DataSendRecType,
            Constants.RequestHeaders.SDKVersion : String(describing: UIDevice.current.systemVersion),
            Constants.RequestHeaders.AppVersion : appInfo.appVersion,
            Constants.RequestHeaders.DeviceID : appInfo.deviceId,
            Constants.RequestHeaders.Manufacturer : Constants.RequestHeaders.DeviceManufacturer,
            Constants.RequestHeaders.DeviceModel : appInfo.deviceModel,
            Constants.RequestHeaders.Product : appInfo.deviceType,
            Constants.RequestHeaders.CTClient: Constants.RequestHeaders.kClientType
        ]
        
        // If login process has been completed.
        if appInfo.userAuthToken != "" {
            headers[Constants.RequestHeaders.Authorization] = appInfo.userAuthToken
        }
        
        return headers;
    }
    
    
    //This method is for testing purpose only
    func bgFetchTestLogin(userId:String, password:String, continueBlock:@escaping (_ isSucceeded:Bool)->()) {
        
        let loginURL = appInfo.httpType + appInfo.baseURL + Constants.APIServices.loginServiceAPI
        self.fetchData(.post, serviceURL: loginURL, params: [Constants.ApiRequestFields.Key_Username: userId as AnyObject, Constants.ApiRequestFields.Key_Password: password as AnyObject]) { (jsonRes, statusCode, isSucceeded) in
            
            if(isSucceeded) {
                if let response = jsonRes {
                    if let token = response[Constants.ApiRequestFields.Key_Token] as? String {
                        self.appInfo.userAuthToken = token
                        
                        if let user = DBUserServices.getUsersForUsername(self.appInfo.username, environment: nil).first
                        {
                            user.token = token
                            if !(DBUserServices.updateUserDetails(forUserModel: user)) {
                                print("Failed to update token.")
                            }
                        }
                    }
                }
                continueBlock(true)
            }
            else {
                continueBlock(false)
            }
        }
    }
    
   
    func loginOnlineWithUserInfo(_ username:String, password:String) {
        let loginURL = appInfo.httpType + appInfo.baseURL + Constants.APIServices.loginServiceAPI
        
        Alamofire.URLSession.shared.reset {
            self.fetchData(.post, serviceURL: loginURL, params: [Constants.ApiRequestFields.Key_Username: username as AnyObject, Constants.ApiRequestFields.Key_Password: password as AnyObject]) { (jsonRes, statusCode, isSucceeded) in
                
                if jsonRes != nil, let json = jsonRes as? NSDictionary {
                    print("Login Response: \(json)")
                    if isSucceeded, let token = json[Constants.ApiRequestFields.Key_Token] as? String {
                        self.appInfo.userAuthToken = token
                        self.appInfo.username = username

                        if let userModel = DBUserServices.getUsersForUsername(username, environment: self.appInfo.environment).first {
                            let user = DBUserServices.saveLoggedInUserDetails(username,
                                                                              withFullName: json[Constants.ApiRequestFields.Key_FullName] as? String,
                                                                              withRole: json[Constants.ApiRequestFields.Key_RoleName] as? String,
                                                                              token: token, userObj: userModel)
                            if Bool(truncating: user.isAcceptedTnC ?? NSNumber(value: false)) == false {
                                self.requestToAcceptTnC(user: user)
                            } else {
                                self.sendPushTokenForCurrentUser()
                                self.downloadManifest(username)
                            }
                        } else {
                            let user = DBUserServices.saveLoggedInUserDetails(username,
                                                                              withFullName: json[Constants.ApiRequestFields.Key_FullName] as? String,
                                                                              withRole: json[Constants.ApiRequestFields.Key_RoleName] as? String,
                                                                              token: token, userObj: nil)
                            self.requestToAcceptTnC(user: user)
                        }
                        
                        if let role = json[Constants.ApiRequestFields.Key_RoleName] {
                            AppInfo.sharedInstance.userRole = role as! String
                        }
                    }
                    else  {
                        self.delegate.loginFailureWithError(jsonRes as? NSDictionary, reqStatusCode: statusCode)
                    }
                }
                else {
                    self.delegate.loginFailureWithError(nil, reqStatusCode: 0)
                }
            }
        }
    }
    
    func requestToAcceptTnC(user:User)  {
        self.delegate.verifyEULAAcceptedForUser(user.userName!, continueBlock: {
            self.sendPushTokenForCurrentUser()
            self.downloadManifest(user.userName!)
            user.isAcceptedTnC = NSNumber(value: true)
            if !(DBUserServices.updateUserDetails(forUserModel: user)) {
                print("Failed to update token.")
            }
        })
    }
    
    // If Network is not available, then login
    func loginOfflineWithUserInfo(_ username:String, password:String, continueBlock:(_ isSuccess:OfflineLoginStatus)->()) {
        if DBUserServices.lastLoginDateOver15Date(offlineLogin: username, lastLoginIntervalForOfflineLogin: Constants.OfflineLoginAllowedDays) {
            continueBlock(OfflineLoginStatus.LastLoginTimeout)
        }
        else {
            do {
                let keychainAccounts = try KeychainPasswordItem.passwordItems(forService: Constants.keyChainServiceName, accessGroup: Constants.keyChainAccessGroup)
                
                // Check keychain userId and password to match password
                if keychainAccounts.count > 0 {
                    var isUserFound = false
                    
                    for kcItem in keychainAccounts {
                        if kcItem.account == username {
                            
                            isUserFound = true
                            let kcPassword = KeychainPasswordItem.readPassword(kcItem)
                            
                            if try kcPassword() == password {
                                AppInfo.sharedInstance.username = username
                                AppInfo.sharedInstance.password = password
                                
                                self.delegate.locationDownloaded = true
                                self.delegate.templateDownloaded = true
                                continueBlock(OfflineLoginStatus.LoginSuccess)
                            }
                            else {
                                continueBlock(OfflineLoginStatus.PasswordNotMatched)
                            }
                        }
                    }
                    if !isUserFound {
                        continueBlock(OfflineLoginStatus.UserNotFound)
                    }
                }
                else {
                    continueBlock(OfflineLoginStatus.LastLoginTimeout)
                }
            }catch {
                continueBlock(OfflineLoginStatus.LastLoginTimeout)
            }
        }
    }
    
    
    func sendPushTokenForCurrentUser() {
        // this funtion is for making call for registering device for push notification.
    }
    
    
    func downloadManifest(_ userName: String) {
        let manifestURL = self.appInfo.httpType + self.appInfo.baseURL + Constants.APIServices.manifestServiceAPI + self.appInfo.username + JobTemplateQS
        self.fetchData(.get, serviceURL: manifestURL, params: nil) { (jsonRes, statusCode, isSucceeded) in
            
            if(isSucceeded) {
                //Do the mapping to get the manifest object
                let manifestMo = ManifestMapping(dictionary: jsonRes as! NSDictionary)
                /*****  UNCOMMENT THIS PART OF CODE BEFORE PRODUCTION RELEASE  *****/
                // If the current environment is production, then check the version number, if we need to upgrade or not.
                if self.appInfo.environment == Constants.Environments.kProduction {
                    if manifestMo.Version != self.appInfo.appVersion {
                        // If this is true, then user will be forced to update the app if the version number is not same. Otherwise, you can bypass this process.
                        self.delegate.versionUpdateRequired(manifestModel: manifestMo)
                        return
                    }
                }
                else if let os = manifestMo.MinOSVersion, let curOS = UIDevice.current.systemVersion.components(separatedBy: ".").first {
                    if let curOSInt = Int(curOS), let reqOS = Int(os) {
                        if curOSInt < reqOS {
                            print("Current OS: \(curOSInt) => \(reqOS)")
                            self.delegate.showOlderOSWarning {
                                // Continue rest of the login process
                                self.continueLoginProcess(manifestMapperModel: manifestMo)
                            }
                            return
                        }
                    }
                }
                // Continue rest of the login process
                self.continueLoginProcess(manifestMapperModel: manifestMo)
            }
            else {
                self.delegate.loginFailureWithError(jsonRes as? NSDictionary, reqStatusCode: statusCode)
            }
        }
    }
    
    func continueLoginProcess(manifestMapperModel: ManifestMapping) {
        let user = DBUserServices.getUserForUsername(self.appInfo.username, environment: appInfo.environment)
        if user!.roleName == Constants.Anonymous_User && manifestMapperModel.ApprovedTemplates.count == 0 {
            self.delegate.noTemplateAssignedError()
            return
        }
        
        let manifest = DBUserServices.saveManifestData(manifestMapperModel, user: user)
        let tempArray = NSMutableArray()
        for temp in manifestMapperModel.ApprovedTemplates {
            tempArray.add(temp)
        }
        
        //Save templates into Sqlite database if that templates is note available and there is no modification after last update. Clear the previous templates if that is no longer assined to that user.
        DBTemplateServices.sharedInstance.getDownloadableJobListAfterDBsync(tempArray, manifest: manifest, completionHandler: { (needToDlTempList, needToDlLocList) in
            
            print("--------------------------------------------------------------")
            print("Number Of templates Need to Download: ", needToDlTempList.count)
            print("Number of Project Locations Need to Download: ", needToDlLocList.count)
            print("--------------------------------------------------------------")
            Analytics.logEvent("Template_And_Location_Download_Needed", parameters: ["Template": needToDlTempList.count, "Location": needToDlLocList.count])
            //Crashlytics.sharedInstance().crash()
            
            if needToDlTempList.count == 0 && needToDlLocList.count == 0 {
                self.delegate.locationDownloaded = true
                self.delegate.templateDownloaded = true

                // Login process has been completed. Call delegate funcation to go back to main login view conroller to open main menu page.
                self.delegate.loginSuccess(isOfflineLogin: false)
            } else {
                self.delegate.startDownloadingTemplates(needToDlTempList, needToDlLocList)
            }
        })
    }
    
    
    func syncExistingInstances() {
        DBJobInstanceServices.syncUnlinkedInstances()

        //Delete backup datas after backup interval time. Defualt time 30 days
        guard let manifest = self.manifest else {
            return
        }

        let instService = JobServices()// JobInstanceServices()
        if let backupInterval = manifest.backupInterval {
            instService.deleteOldInstances(interval: Int(truncating: backupInterval))
            instService.deleteAPILogs(interval: Int(truncating: backupInterval))
        }
        else {
            instService.deleteOldInstances(interval: Constants.LocalBackupDataIntTime)
            instService.deleteAPILogs(interval: Constants.LocalBackupDataIntTime)
        }
        // Remove all zipped files those are missed to delete in last FTP data send process.
        Utility.deleteAllZippedFiles()
    }
}

