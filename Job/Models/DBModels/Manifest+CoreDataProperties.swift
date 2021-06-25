//
//  Manifest+CoreDataProperties.swift
//  Job
//
//  Created by Saleh Sultan on 10/30/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension Manifest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Manifest> {
        return NSFetchRequest<Manifest>(entityName: "Manifest")
    }

    @NSManaged public var aetExpirationDate: Date?
    @NSManaged public var appUrl: String?
    @NSManaged public var backupInterval: NSNumber?
    @NSManaged public var helpDeskEmail: String?
    @NSManaged public var helpDeskNumber: String?
    @NSManaged public var isUpdateRequired: NSNumber?
    @NSManaged public var reportInterval: NSNumber?
    @NSManaged public var version: String?
    @NSManaged public var minOSVersion: String?
    @NSManaged public var minWorkDistance: Float
    @NSManaged public var jobInstance: NSSet?
    @NSManaged public var projects: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for jobInstance
extension Manifest {

    @objc(addJobInstanceObject:)
    @NSManaged public func addToJobInstance(_ value: JobInstance)

    @objc(removeJobInstanceObject:)
    @NSManaged public func removeFromJobInstance(_ value: JobInstance)

    @objc(addJobInstance:)
    @NSManaged public func addToJobInstance(_ values: NSSet)

    @objc(removeJobInstance:)
    @NSManaged public func removeFromJobInstance(_ values: NSSet)

}

// MARK: Generated accessors for projects
extension Manifest {

    @objc(addProjectsObject:)
    @NSManaged public func addToProjects(_ value: Project)

    @objc(removeProjectsObject:)
    @NSManaged public func removeFromProjects(_ value: Project)

    @objc(addProjects:)
    @NSManaged public func addToProjects(_ values: NSSet)

    @objc(removeProjects:)
    @NSManaged public func removeFromProjects(_ values: NSSet)

}
