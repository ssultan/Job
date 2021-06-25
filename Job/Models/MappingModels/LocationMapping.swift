//
//  LocationMapping.swift
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

class LocationMapping: EVObject {
    @objc var Address:String = ""
    @objc var City:String = ""
    @objc var CreatedBy = ""
    @objc var CreatedByName:String = ""
    @objc var CreatedOn:Date = Date()
    @objc var CustomerId = 0
    @objc var Description:String = ""
    @objc var Id:String = ""
    @objc var IsActive:Bool = false
    @objc var IsBillable:Bool = false
    @objc var LastUpdatedOn:Date = Date()
    @objc var LocationProjectMappings = 0
    @objc var Name:String = ""
    @objc var Number:String = ""
    @objc var OracleAccountId = 0
    @objc var OracleId = 0
    @objc var OracleLocationMappings = 0
    @objc var OracleProjectId = 0
    @objc var ProjectId:String = ""
    @objc var ProjectName:String = ""
    @objc var ProjectNumber:String = ""
    @objc var State:String = ""
    @objc var Zip:String = ""
    @objc var GeoLocation:String!
    @objc var FloorPlanCount: Int = 0
    @objc var InstanceCount: Int = 0
    @objc var VirtualTourCount: Int = 0
    @objc var HasData:String = ""
    @objc var AddressUid: Int = 0
    @objc var Account: String = ""
    @objc var AccountId: Int = 0
    @objc var Country: String = ""
    @objc var JobInstanceCount: Int = 0
}
