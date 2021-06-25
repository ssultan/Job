//
//  DBUserServices.swift
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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}



class DBUserServices: NSObject {
    class func saveLoggedInUserDetails(_ userName: String, withFullName name: String?, withRole role:String?, token: String, userObj:User?) -> User {
        
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        if let user = userObj {
            user.token = token
            if let fullName = name {
                user.fullName = fullName
            }
            if let roleName = role {
                user.roleName = roleName
            }
            user.loginTime = Date() as NSDate?
            do {
                try managedObjectContext.save()
            } catch {
                print("Failed to update token.")
            }
            return user
        }
        
        let user = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.UserEntity, into: managedObjectContext) as! User
        user.userName = userName
        user.token = token
        if let fullName = name {
            user.fullName = fullName
        }
        if let roleName = role {
            user.roleName = roleName
        }
        user.loginTime = Date() as NSDate?
        user.isAcceptedTnC = NSNumber(value: false)
        user.buildEnvironment = AppInfo.sharedInstance.environment
//        user.userId = String(arc4random_uniform(30000)) // Since we are going to replace it with server UserId, instead of generating one from client side.
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to insert new user.")
        }
        return user
    }
    
    class func updateUserDetails(forUserModel userMo: User) -> Bool{
        
        let moc = CoreDataManager.sharedInstance.managedObjectContext
        if let user = CoreDataBusiness.fetchData(moc ,entityName:Constants.EntityNames.UserEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "userName = %@", userMo.userName ?? "")).first as? User
        {
            user.token = userMo.token
            user.buildEnvironment = userMo.buildEnvironment
            user.isAcceptedTnC = userMo.isAcceptedTnC
            
            do {
                try moc.save()
                return true
                
            } catch {
                print("Failed ot save manifest.")
            }
        }
        return false
    }
    
    
    class func saveManifestData(_ manifestModel: ManifestMapping, user: User?) -> Manifest {
        
        let moc = CoreDataManager.sharedInstance.managedObjectContext
        if let manifestArr = CoreDataBusiness.fetchData(moc ,entityName:Constants.EntityNames.ManifestEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "user.userName = %@", manifestModel.UserName)) as? [Manifest]
        {
            if let manifest = manifestArr.first {
                manifest.aetExpirationDate = manifestModel.AetExpirationDate
                manifest.appUrl = manifestModel.AppUrl
                manifest.backupInterval = manifestModel.BackupInterval as NSNumber?
                manifest.helpDeskEmail = manifestModel.HelpDeskEmail
                manifest.helpDeskNumber = manifestModel.HelpDeskNumber
                manifest.isUpdateRequired = manifestModel.IsUpdateRequired as NSNumber?
                manifest.reportInterval = manifestModel.ReportInterval as NSNumber?
                manifest.version = manifestModel.Version
                manifest.user = user
                
                do {
                    try moc.save()
                } catch {
                    print("Failed ot save manifest.")
                }
                return manifest
            }
        }
        
        let manifest = NSEntityDescription.insertNewObject(forEntityName: Constants.EntityNames.ManifestEntity, into: moc) as! Manifest
        manifest.aetExpirationDate = manifestModel.AetExpirationDate
        manifest.appUrl = manifestModel.AppUrl
        manifest.backupInterval = manifestModel.BackupInterval as NSNumber?
        manifest.helpDeskNumber = manifestModel.HelpDeskNumber
        manifest.helpDeskEmail = manifestModel.HelpDeskEmail
        manifest.isUpdateRequired = manifestModel.IsUpdateRequired as NSNumber?
        manifest.reportInterval = manifestModel.ReportInterval as NSNumber?
        manifest.version = manifestModel.Version
        manifest.minOSVersion = manifestModel.MinOSVersion
        manifest.minWorkDistance = Float(manifestModel.MinWorkDistance)
        manifest.user = user
        
        do {
            try moc.save()
        } catch {
            print("Failed to insert manifest: \(error)")
        }
        return manifest
    }
    
    class func getManifest(forUsername username:String) -> Manifest? {
        let moc = CoreDataManager.sharedInstance.managedObjectContext
        if let manifest = CoreDataBusiness.fetchData(moc, entityName: Constants.EntityNames.ManifestEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "user.userName = %@", username)).first as? Manifest
        {
            return manifest
        }
        return nil
    }
    
    class func getUserModelForUsername(_ username: String) -> [UserModel]? {
        let moc = CoreDataManager.sharedInstance.managedObjectContext
        if let users = CoreDataBusiness.fetchData(moc, entityName: Constants.EntityNames.UserEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "userName = %@", username)) as? [User]
        {
            var userList = [UserModel]()
            for user in users {
                userList.append(UserModel.init(user: user))
            }
            return userList
        }
        return nil
    }
    
    class func getUsersForUsername(_ username: String, environment: String?) -> [User] {
        let moc = CoreDataManager.sharedInstance.managedObjectContext
        if let users = CoreDataBusiness.fetchData(moc, entityName: Constants.EntityNames.UserEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "userName = %@", username)) as? [User]
        {
//            if let user = users.first {
//                if let savedEnv = user.buildEnvironment, let currentEnv = environment {
//                    if savedEnv != currentEnv {
                        // Delete user if the environment is not same
//                        if !CoreDataBusiness.deleteData(moc, entityName: Constants.EntityNames.UserEntity, fetchByPredicate: NSPredicate(format: "userName = %@", username)) {
//                            print("Failed to delete user for a different environement.")
//                        } else {
//                            users.removeLast()
//                        }
//                    }
//                }
//            }
            return users
        }
        return [User]()
    }
    
    class func getUserForUsername(_ username: String, environment: String?) -> User? {
        if let user = DBUserServices.getUsersForUsername(username, environment: environment).first {
            return user
        }
        return nil
    }
    
    class func lastLoginDateOver15Date(offlineLogin username:String, lastLoginIntervalForOfflineLogin:Int) -> Bool {
        if let users = CoreDataBusiness.fetchData(CoreDataManager.sharedInstance.managedObjectContext, entityName: Constants.EntityNames.UserEntity, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: NSPredicate(format: "userName = %@", username)) as? [User]
        {
            if let user = users.first {
                if let inter = user.loginTime?.timeIntervalSinceNow {
                    let interval = Double(inter) * -1
                    print("\(interval) => Days: \(interval/(60 * 60 * 24))")
                    
                    if (Int(interval/(60 * 60 * 24)) >= lastLoginIntervalForOfflineLogin) {
                        return true
                    }
                }
                return false
            }
        }
        return true
    }
    
    class func saveUserPhoneNumber(phoneNumber: String?, user:User) {
        let managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
        
        if let phone = phoneNumber {
            user.userPhone = phone
            
            do {
                try managedObjectContext.save()
            } catch {
                print("Failed to insert new user.")
            }
        }
    }
}
