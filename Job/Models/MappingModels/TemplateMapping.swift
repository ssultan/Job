//
//  TemplateMapping.swift
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
import EVReflection

class TemplateMapping: EVObject {
    @objc var AllowIncomplete:String = ""
    @objc var ApprovalRequired: Bool = false
    @objc var BaseId: Int = 0
    @objc var Children: String = ""
    @objc var CreatedBy: Int = 0
    @objc var CreatedByName: String = ""
    @objc var CreatedOn: Date = Date()
    @objc var Creator: Int = 0
    @objc var CustomerId: Int = 0
    @objc var CustomerName: String = ""
    @objc var ExpiresOn: String = ""
    @objc var Id: Int = 0
    @objc var InstanceCount: Int = 0
    @objc var IsActive: Bool = false
    @objc var IsPublic: String = "";
    @objc var Language: NSDictionary = NSDictionary()
    @objc var SendConfirmation: Int = 0
    @objc var LastUpdatedBy: Int = 0
    @objc var LastUpdatedByName: String = ""
    @objc var LastUpdatedOn: NSDate = NSDate()
    @objc var LobId: Int = 0
    @objc var LobName: String = "";
    @objc var LongDescription: String = "";
    @objc var Name: String = "";
    @objc var ProgramId: Int = 0
    @objc var ProgramName: String = ""
    @objc var ProjectNumber: String = ""
    @objc var ProjectId: String = ""
    @objc var ProjectLastUpdatedOn: NSDate = NSDate()
    @objc var ProjectManager: String = ""
    @objc var ProjectManagerNumber: String = ""
    @objc var ProjectName:String = ""
    @objc var ProjectDescription: String = ""
    @objc var Projects = ""
    @objc var QaRequired = 0
    @objc var ShortDescription: String = ""
    @objc var SignatureRequired: Bool = false
    @objc var Status: Int = 0
    @objc var StatusName: String = ""
    @objc var TenantId: Int = 0
    @objc var TenantName:String = ""
    @objc var ToolTip:String = ""
    @objc var `Type`: Int = 0
    @objc var TypeName:String = ""
    @objc var isInsertRequired:Bool = true
    
    //New fields
    @objc var ProjectTemplateId:String = ""
    @objc var ApprovalCount:Int = 0
    @objc var TotalInstanceCount:Int = 0
    @objc var ExceptionInstanceCount:Int = 0
    @objc var DiscrepancyDefinitionCount:Int = 0
    @objc var IsShared: Bool = false

    
    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return []
    }
}
