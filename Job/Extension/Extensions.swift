//
//  Extensions.swift
//  Job V2
//
//  Created by Saleh Sultan on 1/18/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

extension UINavigationController {
    
    func pushViewController(viewController:UIViewController?, direction: NavPushDirection) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        
        switch direction {
        case .Top:
            transition.subtype = CATransitionSubtype.fromBottom
            break
            
        case .Bottom:
            transition.subtype = CATransitionSubtype.fromTop
            break
            
        case .Right:
            transition.subtype = CATransitionSubtype.fromLeft
            break
            
        case .Left:
            transition.subtype = CATransitionSubtype.fromRight
            break
        }
        
        self.view.layer.add(transition, forKey: nil)
        
        if let vc = viewController {
            self.pushViewController(vc, animated: false)
        }
    }
    
    //'callPopupVC' variable is used to check if we want to run the popViewController function or not. By default it's true. For 'back' arrow button action, 'callPoupVC' bool will be false. because back button itself has popup functionality. so we just need to add the animation part only.
    func popViewController(animated: Bool, direction: NavPushDirection, callPopupVC: Bool = true) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        
        switch direction {
        case .Top:
            transition.subtype = CATransitionSubtype.fromBottom
            break
            
        case .Bottom:
            transition.subtype = CATransitionSubtype.fromTop
            break
            
        case .Right:
            transition.subtype = CATransitionSubtype.fromLeft
            break
            
        case .Left:
            transition.subtype = CATransitionSubtype.fromRight
            break
        }
        
        self.view.layer.add(transition, forKey: nil)
        
        
        if callPopupVC {
            self.popViewController(animated: true)
        }
    }
}



extension UIButton {
    func setHitEdgeInsets(hitEdgeInsets: UIEdgeInsets) {
        let value = NSValue(uiEdgeInsets: hitEdgeInsets)
        objc_setAssociatedObject(self, "HitTestEdgeInsets", value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
}

extension UILabel {
    func setHitEdgeInsets(hitEdgeInsets: UIEdgeInsets) {
        let value = NSValue(uiEdgeInsets: hitEdgeInsets)
        objc_setAssociatedObject(self, "HitTestEdgeInsets", value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

extension NSDate {
    public func convertToString(format:String?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format == nil ? Constants.SERVER_EXP_DATE_FORMATE : format
        return dateFormatter.string(from: self as Date)
    }
}

extension Date {
    public func convertToString(format:String?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format == nil ? Constants.SERVER_EXP_DATE_FORMATE : format
        return dateFormatter.string(from: self)
    }
}

extension FileManager {
    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
}
