//
//  ManifestMapping.swift
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



class ManifestMapping : EVObject {
    
    @objc var AppUrl: String = ""
    @objc var AetExpirationDate: Date = Date()
    @objc var BackupInterval: Int = 0
    @objc var HelpDeskEmail: String = ""
    @objc var HelpDeskNumber: String = ""
    @objc var IsUpdateRequired: Bool = false
    @objc var ReportInterval: Int = 0
    @objc var UserName: String = ""
    @objc var Version: String = ""
    @objc var MinOSVersion: String!
    @objc var MinWorkDistance = 1.0
    var ApprovedTemplates = [TemplateMapping]()
    
    
    override func initValidation(_ dict: NSDictionary) {
        if let templates = dict["ApprovedTemplates"] as? [NSDictionary] {
            for item in templates {
                let template = TemplateMapping(dictionary: item)
                self.ApprovedTemplates.append(template)
            }
        }
    }
}
