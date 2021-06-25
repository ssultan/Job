//
//  AppDelegate.swift
//  Job
//
//  Created by Saleh Sultan on 5/7/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
//import Appsee
//import Fabric
import Firebase
import Alamofire
import FirebaseCrashlytics
import UserNotifications
import SlideMenuControllerSwift

var SessionTimeout = 60
var SessionTimeoutWObio = 180

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { //, AppseeDelegate {
    
    var window: UIWindow?   
    var slideMenuController: SlideMenuController!
    
    //MARK: - Application Life-cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.add3rdParyApiKeys()
        self.addServicesPermission()
        UserLocation.sharedInstance.startTrackingUserLocation()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let slideMenu = storyBoard.instantiateViewController(withIdentifier: "SlideMenuTV") as! SlideMenuTableView
        let loginViewNav = storyBoard.instantiateViewController(withIdentifier: "RootNavController") as! UINavigationController
        slideMenu.loginView = loginViewNav
        
        slideMenuController = SlideMenuController(mainViewController: loginViewNav, rightMenuViewController: slideMenu)
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppInfo.sharedInstance.bgTimeStart = Date()
        UserLocation.sharedInstance.stopLocationUpdate()
        Analytics.setScreenName("ApplicationEnterBackground", screenClass: nil)
        
        if (AppInfo.sharedInstance.userAuthToken == "") {
            return
        }
        if BackgroundServices.sharedInstance.lock.try() == true {
            var bgTask:UIBackgroundTaskIdentifier = application.beginBackgroundTask(withName: "UploadInstance") {}
            var successfullyProcessed:Bool = false
            DispatchQueue.global().async { // 'Utility'
                
                BackgroundServices.sharedInstance.sendAllInstance(completion: { (isFinished) in
                    successfullyProcessed = isFinished
                    // Need to unlock the NSLock operation on main thread
                    DispatchQueue.main.sync {
                        BackgroundServices.sharedInstance.lock.unlock()
                        if successfullyProcessed && UIApplication.shared.applicationState == .background {
                            self.postLocalNotification()
                        }
                        application.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
                        bgTask = UIBackgroundTaskIdentifier.invalid
                    }
                    BackgroundServices.sharedInstance.isFirstThread = true
                })
            }
        }
        else {
            print("AppDelegate: Locked. Some process is running in BG thread.")
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let compRes = Date().timeIntervalSince(AppInfo.sharedInstance.bgTimeStart ?? Date())
        AppInfo.sharedInstance.bioAuthentication(difference: Int(compRes)/60, slideMenuController: self.slideMenuController!)
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        AppInfo.sharedInstance.logAppseeUserId()
        UserLocation.sharedInstance.startLocationUpdate()
        Analytics.setScreenName("AppBecameActive", screenClass: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        AppInfo.sharedInstance.logAppseeUserId()
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.APP_WILL_TERMINATE)
    }
    
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        print("---------------Protected date is NOT Available")
    }
    
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        print("---------------Protected Data Became Available.")
    }
    
    var shouldRotate = false
    var supportLandscape = false
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if shouldRotate {
            return .allButUpsideDown
        }
        else if supportLandscape == false {
            return .portrait
        }
        else {
            return .landscapeRight
        }
    }
    
    
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("********************* MEMORY WARNING ***********************")
        Crashlytics.crashlytics().setCustomValue("Application received memory warning", forKey: "Warning")
        //Appsee.addEvent("Application received memory warning", withProperties: ["MemoryInUse": "\(Helper.getMegabytesUsed() ?? 0.0)",Constants.ApiRequestFields.Key_Username: AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId])
        Analytics.logEvent("Application_received_memory_warning", parameters: ["MemoryInUse": "\(Helper.getMegabytesUsed() ?? 0.0)",
            Constants.ApiRequestFields.Key_Username: AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId])
        
        // If the BG thread is running then, change the flag. because the flag will be check on the send process
        if BackgroundServices.sharedInstance.lock.try() == false { // failed because BG thread is running....
            BackgroundServices.sharedInstance.isRecMemWarning = true
        } else {
            BackgroundServices.sharedInstance.lock.unlock()
        }
    }
    
    
    // MARK: -
    func add3rdParyApiKeys() {
        setGlobalAppearence();
        
        FirebaseApp.configure()
        
        #if DEBUG || STAGE
        //Appsee.start(Constants.Keys.AppSeeKey)
        //Appsee.setDelegate(self)
        
//        Fabric.with([Crashlytics.self])
//        Fabric.sharedSDK().debug = false
        
        ///bin/sh
        //"${PODS_ROOT}/Fabric/run" b5f7b3415e6727fd78152e715f7a7e7f4d4a1020 3fc466a346661da83cd01f7f4c0df09220bfa2ab3cf0e8f54cbbdeb93c06b34a

        #else
        //Appsee.start(Constants.Keys.AppSeeKey)
        //Appsee.setDelegate(self)
        
        //FirebaseApp.configure()
//        Fabric.with([Crashlytics.self])
        
        #endif
    }
    
    func addServicesPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
    }
    
    func setGlobalAppearence() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "navbar_new.png"), for: .default)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Segoe UI", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white];
        
        UIToolbar.appearance().tintColor = UIColor.white
        UIToolbar.appearance().setBackgroundImage(UIImage(named: "navbar_new.png"), forToolbarPosition: .any, barMetrics: .default)
    }
    
    fileprivate func postLocalNotification() {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "UploadSuccess"
        content.badge = 1
        content.title = NSString.localizedUserNotificationString(forKey: StringConstants.StatusMessages.BG_Upload_Process_Success_Message_Title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: StringConstants.StatusMessages.BG_Upload_Process_Success_Message, arguments: nil)
        
        // Configure the trigger after 5 second of current time
        var dateInfo = NSCalendar.current.dateComponents([.hour, .minute, .second], from: NSDate() as Date)
        dateInfo.second = dateInfo.second! + 5
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "JobStatusBG", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    
    //MARK: - AppSee Delegate methods
//    func appseeScreenDetected(_ screenName: String!) -> String! {
//        
//        if let name = screenName {
//            if let scNameFound = name.components(separatedBy: ".").last {
//                let screenName = Helper.getAppSeeScreenNameForClassName(screenName: scNameFound)
//                Analytics.setScreenName(screenName, screenClass: nil)
//                return screenName
//            }
//        }
//        
//        return screenName
//    }
//    
//    func appseeSessionStarted(_ sessionId: String!, videoRecorded isVideoRecorded: Bool) {
//        if let sessId = sessionId {
//            AppInfo.sharedInstance.curAppseeSessionId = sessId
//            Crashlytics.sharedInstance().setObjectValue("https://dashboard.//Appsee.com/home/task-management#/Videos/Index/\(sessId)#ios/all/month/all", forKey: "AppseeSessionId")
//        }
//        if let crashlyticsAppseeId = //Appsee.generate3rdPartyID("Crashlytics", persistent: false) {
//            Crashlytics.sharedInstance().setObjectValue("https://dashboard.//Appsee.com/3rdparty/crashlytics/\(crashlyticsAppseeId)", forKey: "AppseeSessionUrl")
//        }
//    }

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
    return UIBackgroundTaskIdentifier(rawValue: input)
}
