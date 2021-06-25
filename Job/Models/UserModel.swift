//
//  UserModel.swift
//  Job V2
//
//  Created by Saleh Sultan on 11/11/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import CoreLocation

class UserModel: NSObject {
    @objc dynamic var userId: String?
    @objc dynamic var userName: String?
    @objc dynamic var userPhone: String?
    @objc dynamic var loginTime: NSDate?
    @objc dynamic var token: String?
    @objc dynamic var aetExpirationDate: NSDate?
    @objc dynamic var appUrl: String?
    @objc dynamic var backupInterval: NSNumber?
    @objc dynamic var helpDeskEmail: String?
    @objc dynamic var helpDeskNumber: String?
    @objc dynamic var isUpdateRequired: NSNumber?
    @objc dynamic var reportInterval: NSNumber?
    @objc dynamic var version: String?
    @objc dynamic var buildEnvironment: String?
    @objc dynamic var isAcceptedTnC: NSNumber?
    @objc dynamic var dbRawManifestObj: AnyObject?
    @objc dynamic var dbRawUserObj: AnyObject?
    @objc dynamic var fullName: String?
    @objc dynamic var roleName: String?
    
    override init() {
        if let user = DBUserServices.getUsersForUsername(AppInfo.sharedInstance.username, environment: nil).first {
            self.userId = user.userId
            self.userName = user.userName
            self.userPhone = user.userPhone
            self.loginTime = user.loginTime
            self.fullName = user.fullName
            self.roleName = user.roleName
            self.token = user.token
            self.aetExpirationDate = user.manifest?.aetExpirationDate as NSDate?
            self.appUrl = user.manifest?.appUrl
            self.backupInterval = user.manifest?.backupInterval
            self.helpDeskEmail = user.manifest?.helpDeskEmail
            self.helpDeskNumber = user.manifest?.helpDeskNumber
            self.isUpdateRequired = user.manifest?.isUpdateRequired
            self.reportInterval = user.manifest?.reportInterval
            self.isAcceptedTnC = user.isAcceptedTnC
            self.version = user.manifest?.version
            self.dbRawUserObj = user
            self.dbRawManifestObj = user.manifest
        }
    }
    
    init(user: User) {
        self.userId = user.userId
        self.userName = user.userName
        self.loginTime = user.loginTime
        self.token = user.token
        self.fullName = user.fullName
        self.roleName = user.roleName
        self.isAcceptedTnC = user.isAcceptedTnC
        self.buildEnvironment = user.buildEnvironment
        self.aetExpirationDate = user.manifest?.aetExpirationDate as NSDate?
        self.appUrl = user.manifest?.appUrl
        self.backupInterval = user.manifest?.backupInterval
        self.helpDeskEmail = user.manifest?.helpDeskEmail
        self.helpDeskNumber = user.manifest?.helpDeskNumber
        self.isUpdateRequired = user.manifest?.isUpdateRequired
        self.reportInterval = user.manifest?.reportInterval
        self.version = user.manifest?.version
        self.dbRawUserObj = user
        self.dbRawManifestObj = user.manifest
    }
    
    init(manifest: Manifest) {
        self.userId = manifest.user?.userId
        self.userName = manifest.user?.userName
        self.loginTime = manifest.user?.loginTime
        self.token = manifest.user?.token
        self.fullName = manifest.user?.fullName
        self.roleName = manifest.user?.roleName
        self.isAcceptedTnC = manifest.user?.isAcceptedTnC
        self.aetExpirationDate = manifest.aetExpirationDate as NSDate?
        self.appUrl = manifest.appUrl
        self.backupInterval = manifest.backupInterval
        self.helpDeskEmail = manifest.helpDeskEmail
        self.helpDeskNumber = manifest.helpDeskNumber
        self.isUpdateRequired = manifest.isUpdateRequired
        self.reportInterval = manifest.reportInterval
        self.version = manifest.version
        self.dbRawManifestObj = manifest
        self.dbRawUserObj = manifest.user
    }
    
    func savePhoneNumber(phoneNo: String?) {
        if let user = self.dbRawUserObj as? User {
            DBUserServices.saveUserPhoneNumber(phoneNumber: phoneNo, user: user)
        }
    }
    
    func isUserNear(storeLocation location: LocationModel, continueBlock:(Bool, Float)->()){
        if let lat = location.latitude, let long = location.longitude, let manifest = self.dbRawManifestObj as? Manifest {
            if let latitude = Double(lat), let longitude = Double(long), let userLocation = UserLocation.sharedInstance.locManager.location {
                let coordinate = CLLocation(latitude: latitude, longitude: longitude)
                let distance = coordinate.distance(from: userLocation)
                if distance > Double(manifest.minWorkDistance*1609) {
                    continueBlock(false, manifest.minWorkDistance)
                    return
                }
            }
        }
        continueBlock(true, 0.0)
    }
    
    class func getUser(forUserName userName: String) -> UserModel? {
        if let user = DBUserServices.getUserModelForUsername(userName)?.first {
            return user
        }
        return nil
    }
}
