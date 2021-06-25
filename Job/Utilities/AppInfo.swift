//
//  AppInfo.swift
//  Job V2
//
//  Created by Saleh Sultan on 8/4/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
//import Appsee
import DeviceKit
import Firebase
import FirebaseAnalytics
import SlideMenuControllerSwift

let DEV = "Dev"
let UAT = "UAT"
let DEBUG = "Debug"
let STAGING = "Staging"
let RELEASE = "Release"
let SERVER_URL = "ServerURL"
let RESET_DOMAIN = "ResetDomain"
let HTTP_TYPE = "HttpType"

class AppInfo: NSObject {
    
    var appVersion  = ""
    var osVersion   = ""
    var environment:String = ""
    var deviceModel = ""
    var baseURL     = ""
    var httpType    = ""
    var resetDomain = ""
    var deviceId   = ""
    var deviceType = ""
    var userAuthToken = ""
    var curAppseeSessionId = ""
    var username:String!
    var password:String!
//    var manifest: ManifestMapping!
    var menus = [StringConstants.MenuTitles.HELP, StringConstants.MenuTitles.LOGOUT]
    @objc var selJobInstance : JobInstanceModel!
    var selectedTemplate: TemplateModel!
    var pageAboutToLoad: String!
    @objc static let sharedInstance = AppInfo()
    var userRole: String = ""
    var bgTimeStart: Date!
    
    
    override init() {
        
        super.init()
        #if DEBUG
            self.setupEnvironment(enviroment: DEV)
        #elseif STAGE
            self.setupEnvironment(enviroment: STAGING)
        #else
            self.setupEnvironment(enviroment: RELEASE)
        #endif
        ///********* NOTE: Environment 'Production' is used V1.5 app services. 'Release' is for new V2 services.
    }
    
    func findMyIP() -> String? {
        let url = URL(string: "https://api.ipify.org")
        do {
            if let url = url {
                let ipAddress = try String(contentsOf: url)
                print("My public IP address is: " + ipAddress)
                return ipAddress
            }
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func setupEnvironment(enviroment: String) {
        self.osVersion = "iOS " + UIDevice.current.systemVersion as String
        self.deviceModel = Device.current.description
        self.deviceId = (UIDevice.current.identifierForVendor?.uuidString)!
        
        //Check device type
        if UIDevice.current.userInterfaceIdiom == .phone { self.deviceType = "iPhone" }
        else { self.deviceType = "iPad" }
        
        // We will no longer use the build number as version number.
        //let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        self.appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String //+ "." + build

        // Store user device info in Appsee
        let deviceDetails = ["Version": self.appVersion,
                             "IP_Address" : self.findMyIP() ?? "No-Network",
                             "Device_Name" : UIDevice.current.name]
        Analytics.setUserProperty(self.deviceId, forName: "DeviceId")
        Analytics.logEvent("Device_Info", parameters: deviceDetails)
        
        if let path = Bundle.main.path(forResource: "Environments", ofType: "plist") {
            if let envDic = NSDictionary(contentsOfFile: path) {
                var detailDic = NSDictionary()
                
                if enviroment == Constants.Environments.kDevelopment {
                    detailDic = envDic.object(forKey: DEBUG) as! NSDictionary
                    self.environment = Constants.Environments.kDevelopment
                }
                else if enviroment == Constants.Environments.kStaging {
                    detailDic = envDic.object(forKey: STAGING) as! NSDictionary
                    self.environment = Constants.Environments.kStaging
                }
                else if enviroment == Constants.Environments.kProdUAT {
                    detailDic = envDic.object(forKey: UAT) as! NSDictionary
                    self.environment = Constants.Environments.kProdUAT
                }
                else {
                    detailDic = envDic.object(forKey: RELEASE) as! NSDictionary
                    self.environment = Constants.Environments.kProduction
                }
                
                
                
                if let url = detailDic.object(forKey: SERVER_URL) {
                    self.baseURL = url as! String
                }
                if let reseturl = detailDic.object(forKey: RESET_DOMAIN) {
                    self.resetDomain = reseturl as! String
                }
                
                if let conType = detailDic.object(forKey: HTTP_TYPE) {
                    self.httpType = conType as! String
                }
            }
        }
    }
    
    // This function will make sure that the Appsee sesssion has a userId. If userId not available then device Id
    func logAppseeUserId() {
        
        if let userName = self.username {
            //Appsee.setUserID(userName)
            Analytics.setUserID(userName)
            Crashlytics.crashlytics().setUserID(userName)
        } else {
            // Logged as last logged in username
            do {
                if let lastLoggedInAct = try KeychainPasswordItem.passwordItems(forService: Constants.keyChainServiceName, accessGroup: Constants.keyChainAccessGroup).first {
                    
                    //Appsee.setUserID(lastLoggedInAct.account)
                    Analytics.setUserID(lastLoggedInAct.account)
                    Crashlytics.crashlytics().setUserID(lastLoggedInAct.account)
                }
                else {
                    // if No user available then store device Id
                    //Appsee.setUserID(self..deviceId)
                    Analytics.setUserID(self.deviceId)
                    Crashlytics.crashlytics().setUserID(self.deviceId)
                }
            }catch {
                // if No user available then store device Id
                //Appsee.setUserID(self.deviceId)
                Analytics.setUserID(self.deviceId)
                Crashlytics.crashlytics().setUserID(self.deviceId)
            }
        }
    }
    
    func bioAuthentication(difference: Int, slideMenuController: SlideMenuController) {
        let biometricAuth = BiometricAuthentication()
        biometricAuth.resetAuthentication()
        
        guard let mainVCNav = slideMenuController.mainViewController as? UINavigationController else {
            return
        }
        
        if let username = self.username, let topView = mainVCNav.topViewController {
            if topView is LoginViewController {
                return
            }
            let authType = biometricAuth.checkBiometricType(username: username)
            if authType == BiometricType.none || authType == BiometricType.passCodeID {
                if (difference >= SessionTimeoutWObio) {
                    self.userAuthToken = ""
                    BackgroundServices.sharedInstance.stopTimer()
                    mainVCNav.popToRootViewController(animated: true)
                }
                return
            }
            
            if (difference < SessionTimeout) {
                return
            }
            
            if let appAuthKey = try! KeychainPasswordItem.passwordItems(forService: Constants.keyChainTouchIdDetectionServiceName, accessGroup: Constants.keyChainAccessGroup).first,
                let user = try! KeychainPasswordItem.passwordItems(forService: Constants.keyChainServiceName, accessGroup: Constants.keyChainAccessGroup).first {
                
                let policy = try! appAuthKey.readPassword()
                biometricAuth.authenticateUser(oldDomainStateId: policy, username: user.account, bioType: authType, isRegister: false) { (message, isCancelled, authFailed, fallbackPass) in
                    if message != nil {
                        DispatchQueue.main.async {
                            self.userAuthToken = ""
                            BackgroundServices.sharedInstance.stopTimer()
                            mainVCNav.popToRootViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}
