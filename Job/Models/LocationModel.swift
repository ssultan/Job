//
//  LocationModel.swift
//  Job V2
//
//  Created by Saleh Sultan on 10/31/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class LocationModel: NSObject {
    @objc dynamic var address: String?
    @objc dynamic var city: String?
    @objc dynamic var locationDesc: String?
    @objc dynamic var locationId: String?
    @objc dynamic var locationName: String?
    @objc dynamic var state: String?
    @objc dynamic var storeId: String?
    @objc dynamic var zipCode: String?
    @objc dynamic var storeNumber: String?
    @objc dynamic var latitude: String?
    @objc dynamic var longitude: String?
    @objc dynamic var dbRawLocObj: AnyObject?
    
    init(location: Location) {
        self.address = location.address
        self.city = location.city
        self.locationDesc = location.locationDesc
        self.locationId = location.locationId
        self.locationName = location.locationName
        self.state = location.state
        self.storeId = location.storeId
        self.zipCode = location.zipCode
        self.storeNumber = location.storeNumber
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.dbRawLocObj = location
    }
}
