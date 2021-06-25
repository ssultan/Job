//
//  StringExt.swift
//  Job V2
//
//  Created by Saleh Sultan on 2/8/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import Foundation

extension String {
    
    func getDateStringFor() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = self
        
        let timeStump = formatter.string(from: Date())
        return timeStump
    }
    
    
    func isValidString(regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: self)
    }
    
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    func findPhotoAttrIdx() -> Int {
        var idx = 0
        for phCompName in self.components(separatedBy: "_") {
            for attr in PhotoAttributesTypes.allValues {
                if attr.attributeShortForm() == phCompName {
                    return idx
                }
            }
            idx += 1
        }
        return -1
    }
    
    func attributeType() -> PhotoAttributesTypes {
        switch self {
        case "Before" :
            return  .Before
        case "After"  :
            return  .After
        case "General"  :
            return  .General
        case "Left_Before"  :
            return .Left_Before
        case "Left_After"  :
            return  .Left_After
        case "Center_Before"  :
            return  .Center_Before
        case "Center_After"  :
            return  .Center_After
        case "Right_Before"  :
            return  .Right_Before
        case "Right_After"  :
            return  .Right_After
        case "Additional"  :
            return  .Additional
        case "FieldVisit"  :
            return  .FieldVisit
        case "Signature"   :
            return  .Signature
        default:
            return .General
        }
    }
    
    func getResolutionId() -> Int {
        switch self {
        case "DefaultPhoto":
            return 1
        case "Pano180Photo":
            return 2
        case "SphericalPhoto":
            return 3
        case "HDPhoto":
            return 4
        default:
            return 1
        }
    }
    
    func getAttributeId() -> String {
        switch self {
        case "Before" :
            return  "1"
        case "After"  :
            return  "2"
        case "General"  :
            return  "3"
        case "Left_Before"  :
            return  "4"
        case "Left_After"  :
            return  "5"
        case "Center_Before"  :
            return  "6"
        case "Center_After"  :
            return  "7"
        case "Right_Before"  :
            return  "8"
        case "Right_After"  :
            return  "9"
        case "Additional"  :
            return  "10"
        case "FieldVisit"  :
            return  "0"
        case "Signature":
            return  "0"
        default:
            return "3"
        }
    }
    
    func getTaskType() -> TaskType {
        switch self {
        case "ParentTask":
            return .ParentTask
        case "SubTask":
            return .SubTask

        default:
            return .ParentTask
        }
    }
    
    func getAttributeName() -> PhotoAttributesTypes {
        var photoAttrName : PhotoAttributesTypes!
        
        switch self {
        case PhotoAttributesTypes.Before.rawValue :
            photoAttrName = PhotoAttributesTypes.Before
            break
        case PhotoAttributesTypes.After.rawValue  :
            photoAttrName = PhotoAttributesTypes.After
            break
        case PhotoAttributesTypes.General.rawValue :
            photoAttrName = PhotoAttributesTypes.General
            break
        case PhotoAttributesTypes.Left_Before.rawValue :
            photoAttrName = PhotoAttributesTypes.Left_Before
            break
        case PhotoAttributesTypes.Left_After.rawValue :
            photoAttrName = PhotoAttributesTypes.Left_After
            break
        case PhotoAttributesTypes.Center_Before.rawValue :
            photoAttrName = PhotoAttributesTypes.Center_Before
            break
        case PhotoAttributesTypes.Center_After.rawValue :
            photoAttrName = PhotoAttributesTypes.Center_After
            break
        case PhotoAttributesTypes.Right_Before.rawValue :
            photoAttrName = PhotoAttributesTypes.Right_Before
            break
        case PhotoAttributesTypes.Right_After.rawValue :
            photoAttrName = PhotoAttributesTypes.Right_After
            break
        case PhotoAttributesTypes.Additional.rawValue :
            photoAttrName = PhotoAttributesTypes.Additional
            break
        case PhotoAttributesTypes.FieldVisit.rawValue :
            photoAttrName = PhotoAttributesTypes.FieldVisit
            break
        case PhotoAttributesTypes.Signature.rawValue :
            photoAttrName = PhotoAttributesTypes.Signature
            break
        default:
            photoAttrName = PhotoAttributesTypes.General
        }
        
        return photoAttrName
    }
    
    func getAttributeNameByShotForm() -> PhotoAttributesTypes {
        var photoAttrName : PhotoAttributesTypes!
        
        switch self {
        case "B" :
            photoAttrName = PhotoAttributesTypes.Before
            break
        case "A"  :
            photoAttrName = PhotoAttributesTypes.After
            break
        case "G" :
            photoAttrName = PhotoAttributesTypes.General
            break
        case "LB" :
            photoAttrName = PhotoAttributesTypes.Left_Before
            break
        case "LA" :
            photoAttrName = PhotoAttributesTypes.Left_After
            break
        case "CB" :
            photoAttrName = PhotoAttributesTypes.Center_Before
            break
        case "CA" :
            photoAttrName = PhotoAttributesTypes.Center_After
            break
        case "RB" :
            photoAttrName = PhotoAttributesTypes.Right_Before
            break
        case "RA" :
            photoAttrName = PhotoAttributesTypes.Right_After
            break
        case "AD" :
            photoAttrName = PhotoAttributesTypes.Additional
            break
        case "FV" :
            photoAttrName = PhotoAttributesTypes.FieldVisit
            break
        case "Signature" :
            photoAttrName = PhotoAttributesTypes.Signature
            break
        default:
            photoAttrName = PhotoAttributesTypes.General
        }
        
        return photoAttrName
    }
}
