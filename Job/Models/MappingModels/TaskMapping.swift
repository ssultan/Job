//
//  TaskMapping.swift
//  Job
//
//  Created by Saleh Sultan on 5/20/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit
import EVReflection

class TaskMapping: EVObject {
    @objc var Accuracy:Int = 25
    @objc var AllowNA:Bool = false
    @objc var BaseId: String = ""
    @objc var CreatedBy: String = ""
    @objc var CreatedOn:NSDate = NSDate()
    @objc var DataType:String = ""
    @objc var DataTypeId: String = ""
    @objc var DocumentType:String = ""
    @objc var DocumentTypeId: Int = 0
    @objc var Id: String = ""
    @objc var IsActive:Bool = true
    @objc var Language = NSDictionary()
    @objc var LastUpdatedBy:String = ""
    @objc var LastUpdatedOn: NSDate = NSDate()
    @objc var LongDescription:String = ""
    @objc var Name:String = ""
    @objc var Ordinal: String = ""
    @objc var PhotoRequired:Bool = false
    @objc var QNo: String = ""
    @objc var Required:Bool = false
    @objc var ShortDescription:String = ""
    @objc var TenantId: String = ""
    @objc var ToolTip:String = ""
    @objc var Unit:String = ""
    @objc var UnitCategory:String = ""
    @objc var UnitCategoryId: String = ""
    @objc var UnitId: String = ""
    @objc var Weight: Int = 0
    
    // Just for reference to avoide warning at debugger section. We are not using them in any part of our source code
    @objc var Children = [TaskMapping]()
    @objc var Choice: NSDictionary = NSDictionary()
    
    override func initValidation(_ dict: NSDictionary) {
        if let childrens = dict["Children"] as? [NSDictionary] {
            for item in childrens {
                let child = TaskMapping(dictionary: item)
                self.Children.append(child)
            }
        }
    }
    
    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return []
    }
}
