//
//  UIViewControllerExtension.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/19/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setNavLeftBarItem() {
        self.removeNavigationBarItem()
        self.addLeftBarButtonWithImage(UIImage(named: "menu-icon")!)
        self.slideMenuController()?.addLeftGestures()
    }
    
    func setNavRightBarItem() {
        self.removeNavigationBarItem()
        self.addRightBarButtonWithImage(UIImage(named: "menu-icon")!)
        self.slideMenuController()?.addRightGestures()
    }
    
    func removeNavigationBarItem() {
        //We are not using left menu icon.
//        self.navigationItem.leftBarButtonItem = nil
//        self.slideMenuController()?.removeLeftGestures()
        
        self.navigationItem.rightBarButtonItem = nil
        self.slideMenuController()?.removeRightGestures()
    }
}
