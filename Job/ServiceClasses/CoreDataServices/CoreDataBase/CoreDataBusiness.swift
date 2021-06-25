//
//  CoreDataBusiness.swift
//  Job V2
//
//  Created by Saleh Sultan on 8/25/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import CoreData
//import FirebasePerformance

class CoreDataBusiness: NSObject {
    
    class func fetchData(_ managedObjContext:NSManagedObjectContext, entityName: String, shortDescriptor sortBy:String?, IsAscending sortingOrder: Bool?, fetchByPredicate predicate:NSPredicate?, fetchLimit limit:Int = 0) -> [NSManagedObject] {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        //If predicate is added
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        if sortBy != nil {
            let sortDescriptor = NSSortDescriptor(key: sortBy, ascending: sortingOrder!)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        if limit > 0 {
            fetchRequest.fetchLimit = limit
        }
        
        do {
//            return try managedObjContext.fetch(fetchRequest) as! [NSManagedObject]
            
//            let trace = Performance.startTrace(name: "MonitorManagedObjectFetch")
            let obj = try managedObjContext.fetch(fetchRequest)
            guard let manageObjList = obj as? [NSManagedObject] else {
                return [NSManagedObject]()
            }
//            trace?.stop()
            return manageObjList
        } catch {
            return [NSManagedObject]()
        }
    }
    
    class func countFetchData(_ managedObjContext:NSManagedObjectContext, entityName: String, fetchByPredicate predicate:NSPredicate?) -> Int {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        //If predicate is added
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        do {
            return try managedObjContext.count(for: fetchRequest)
        } catch {
            return 0
        }
    }
    
    class func updateData(_ managedObjContext: NSManagedObjectContext, entityName: String, fetchByPredicate predicate:NSPredicate?, propertiesToUpdate:[AnyHashable: Any]) -> Bool {
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: managedObjContext)
        
        // Initialize Batch Update Request
        let batchUpdateRequest = NSBatchUpdateRequest(entity: entityDescription!)
        
        // Configure Batch Update Request
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        batchUpdateRequest.propertiesToUpdate = propertiesToUpdate 
        
        do {
            // Execute Batch Request
            let batchUpdateResult = try managedObjContext.execute(batchUpdateRequest) as! NSBatchUpdateResult
            
            // Extract Object IDs
            if let objectIDs = batchUpdateResult.result as? [NSManagedObjectID] {
                for objectID in objectIDs {
                    // Turn Managed Objects into Faults
                    let managedObject = managedObjContext.object(with: objectID)
                    managedObjContext.refresh(managedObject, mergeChanges: false)
                }
            }
            
            return true
            
        } catch {
            let updateError = error as NSError
            print("Error: \(updateError), \(updateError.userInfo)")
            return false
        }
    }
    
    class func deleteData(_ managedObjContext: NSManagedObjectContext, entityName: String, fetchByPredicate predicate:NSPredicate?) -> Bool {
        
        // Batch deletion process is not working
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        //If predicate is added
        if let predicFound = predicate {
            fetchRequest.predicate = predicFound
        }
        
        /*
        // This portion of code doesn't work. Will comeback later.
        if #available(iOS 9.0, *) {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try managedObjContext.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIDArray = result?.result as? [NSManagedObjectID] else {
                    return false
                }

                objectIDArray.forEach { objectId in
                    let mObj = managedObjContext.object(with: objectId)
                    managedObjContext.refresh(mObj, mergeChanges: true)
                }

//                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey : objectIDArray], into: [managedObjContext])
                try managedObjContext.save()

                return true
            } catch {
                print("Failed to delete data: \(error)")
                return false
            }
        } */
        
        let mngObjArr = CoreDataBusiness.fetchData(managedObjContext ,entityName:entityName, shortDescriptor: nil, IsAscending: nil, fetchByPredicate: predicate)
        for manageObj in mngObjArr {
            managedObjContext.delete(manageObj)
        }
        do {
            try managedObjContext.save()
            return true
        } catch {
            print("Failed to delete data: \(error)")
            return false
        }
    }
    
    
    
    class func fetchEntity(_ entityName: String, inContext context: NSManagedObjectContext) -> [NSManagedObject] {
        return self.fetchEntity(entityName, predicate: nil, sortDescriptors: nil, inContext: context)
    }
    
    class func fetchEntity(_ entityName: String, predicate: NSPredicate?, inContext context: NSManagedObjectContext) -> [NSManagedObject] {
        return self.fetchEntity(entityName, predicate: predicate, sortDescriptors: nil, inContext: context)
    }
    
    class func fetchEntity(_ entityName: String, sortDescriptors: [NSSortDescriptor]?, inContext context: NSManagedObjectContext) -> [NSManagedObject] {
        return self.fetchEntity(entityName, predicate: nil, sortDescriptors: sortDescriptors, inContext: context)
    }
    
    class func fetchEntity(_ entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, inContext context: NSManagedObjectContext) -> [NSManagedObject] {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        let objects = try! context.fetch(request) as? [NSManagedObject] ?? [NSManagedObject]()
        return objects
    }
}
