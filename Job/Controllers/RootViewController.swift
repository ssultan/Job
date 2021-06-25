//
//  RootViewController.swift
//  Job V2
//
//  Created by Saleh Sultan on 05/07/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
////import Appsee
import SlideMenuControllerSwift


class RootViewController: UIViewController {
    
    var popViewController : PopUpViewControllerSwift!
    var menuButton : UIBarButtonItem!
    var lastOrientation: UIInterfaceOrientation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopUpVC") as? PopUpViewControllerSwift
        
        let backBt = UIBarButtonItem()
        backBt.title = ""
        let yourBackImage = UIImage(named: Constants.BackArrowImgName)
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationItem.backBarButtonItem = backBt

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.supportLandscape = false
            appDelegate.shouldRotate = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NotificationsName.MENU_BTN_CLICKED_NOTIFY), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manageSlideMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(menuBtnClicked), name:NSNotification.Name(rawValue: Constants.NotificationsName.MENU_BTN_CLICKED_NOTIFY), object: nil)
    }
    
    @objc func menuBtnClicked() {
//        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.HAMBURGER_MENU_TAPPED)
    }
    
    func manageSlideMenu() {
        
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }
        if viewControllers.last is MainMenuViewController {
            AppInfo.sharedInstance.menus = [StringConstants.MenuTitles.WHATS_NEW, StringConstants.MenuTitles.TUTORIALS, StringConstants.MenuTitles.HELP, StringConstants.MenuTitles.LOGOUT]
        }
        else if viewControllers.last is HelpViewController {
            AppInfo.sharedInstance.menus = [StringConstants.MenuTitles.MAIN_MENU, StringConstants.MenuTitles.WHATS_NEW,  StringConstants.MenuTitles.TUTORIALS, StringConstants.MenuTitles.HELP, StringConstants.MenuTitles.LOGOUT]
        }
        else if viewControllers.last is TransmitReportViewController {
            AppInfo.sharedInstance.menus = [StringConstants.MenuTitles.MAIN_MENU, StringConstants.MenuTitles.TUTORIALS, StringConstants.MenuTitles.WHATS_NEW, StringConstants.MenuTitles.HELP,  StringConstants.MenuTitles.EMAIL, StringConstants.MenuTitles.LOGOUT]
        }
        else {
            AppInfo.sharedInstance.menus = [StringConstants.MenuTitles.MAIN_MENU, StringConstants.MenuTitles.WHATS_NEW, StringConstants.MenuTitles.TUTORIALS,  StringConstants.MenuTitles.HELP, StringConstants.MenuTitles.LOGOUT]
        }
        
        
        if let _ = AppInfo.sharedInstance.username, let user = UserModel.getUser(forUserName: AppInfo.sharedInstance.username!) {
            if user.roleName ?? "" == Constants.Anonymous_User {
                AppInfo.sharedInstance.menus.remove(at: AppInfo.sharedInstance.menus.firstIndex(of: StringConstants.MenuTitles.WHATS_NEW)!)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.RELOAD_TABLE_NOTIFY), object: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showErrorMsg(_ message: String, title: String = StringConstants.ButtonTitles.TLT_Warning, closeBtnTxt: String = StringConstants.ButtonTitles.BTN_Close, closingDialogBlock:@escaping ()->() = {}) {
        self.popViewController.showInView(self.navigationController?.view, withTitle: title,
                                          withMessage:message,
                                          withCloseBtTxt: closeBtnTxt,
                                          withAcceptBt: nil,
                                          animated: true,
                                          isMessage: false,
                                          cancelBlock: closingDialogBlock)
    }
    
    func showAcceptCancelMsg(message: String, acceptBtnTxt:String?, closeBtnTxt:String?, title:String, isMessage:Bool = false, btnDispTypeParallel:Bool = false, acceptBlock:@escaping ()->()) {
        self.popViewController.showInView(self.view, withTitle: title,
                                          withMessage:message,
                                          withCloseBtTxt: closeBtnTxt,
                                          withAcceptBt: acceptBtnTxt,
                                          animated: true,
                                          isMessage: isMessage,
                                          btnDispTypeParallel:btnDispTypeParallel,
                                          continueBlock: acceptBlock)
    }
}


extension RootViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
