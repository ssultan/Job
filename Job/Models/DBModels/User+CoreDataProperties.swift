//
//  User+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 5/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var buildEnvironment: String?
    @NSManaged public var isAcceptedTnC: NSNumber?
    @NSManaged public var loginTime: NSDate?
    @NSManaged public var token: String?
    @NSManaged public var userId: String?
    @NSManaged public var userName: String?
    @NSManaged public var userPhone: String?
    @NSManaged public var fullName: String?
    @NSManaged public var roleName: String?
    @NSManaged public var manifest: Manifest?

}
