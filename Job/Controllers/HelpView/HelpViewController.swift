//
//  HelpViewController.swift
//  Job V2.0
//
//  Created by Saleh Sultan on 05/19/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import MessageUI

class HelpViewController: RootViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var helpTB: UITableView!
    var helpArray = [StringConstants.MenuTitles.CALL_HELP_DESK, StringConstants.MenuTitles.EMAIL_HELP_DESK, StringConstants.MenuTitles.DOCUMENTATION, StringConstants.MenuTitles.SUPPORTED_DEVICES, StringConstants.MenuTitles.WHATS_NEW]
    let appInfo = AppInfo.sharedInstance
    var isFromMenu = false
    var popupView : PopupWTxbInputView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = nil
        self.title = StringConstants.PageTitles.HELP_PG_TLT
        
        self.helpTB.tableFooterView = UIView()
        if isFromMenu {
            self.setNavRightBarItem()
        }
        
        if self.popupView == nil {
            self.popupView = self.storyboard?.instantiateViewController(withIdentifier: "PopupWTxbInputV") as? PopupWTxbInputView
        }
        
        if let user = UserModel.getUser(forUserName: AppInfo.sharedInstance.username!) {
            if user.roleName == Constants.Anonymous_User {
                self.helpArray.removeLast()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableView Delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTBCell", for: indexPath) as! SlideMenuTbVCell
        cell.menuTitle.text = helpArray[(indexPath as NSIndexPath).row]
        
        if indexPath.row == 0 {
            cell.menuIcon.image = UIImage(named: "HelpCallIcon")
        } else if indexPath.row == 1 {
            cell.menuIcon.image = UIImage(named: "EmailIcon")
        } else if indexPath.row == 2 {
            cell.menuIcon.image = UIImage(named: "FolderIcon")
        } else if indexPath.row == 3 {
            cell.menuIcon.image = UIImage(named: "HelpSupDeviceIcon")
        } else if indexPath.row == 4 {
            cell.menuIcon.image = UIImage(named: "whatsNewIcon")
        }
        
        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        imgView.frame = cell.frame
        cell.backgroundView = imgView

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.CALL_CLICKED)
            if let users = DBUserServices.getUserModelForUsername(self.appInfo.username) {
                if let helpDeskNumber = users.first?.helpDeskNumber {
                    let callNo = "tel://\(helpDeskNumber)"
                    if UIApplication.shared.canOpenURL(URL(string: callNo)!) {
                        if let callURL = URL(string: callNo) {
                            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_CLEARTHREAD, withMessage:StringConstants.StatusMessages.CallHelpDesk, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_CALL, animated: true, isMessage: false, continueBlock: {

                                UIApplication.shared.open(callURL, options: [:], completionHandler: nil)
                            })
                        }
                    }
                    else {
                        self.popViewController.showInView(self.view, withTitle: StringConstants.StatusMessages.Device_DoesNot_Support_Call_Msg_Title, withMessage:StringConstants.StatusMessages.Device_DoesNot_Support_Call_Msg, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil, animated: true, isMessage: false)
                    }
                }
                else {
                    self.popViewController.showInView(self.view, withTitle: StringConstants.StatusMessages.Device_DoesNot_Support_Call_Msg_Title, withMessage:StringConstants.StatusMessages.Helpdesk_No_Not_Avaiable, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil, animated: true, isMessage: false)
                }
            }
            break
            
            
        case 1:
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.EMAIL_CLICKED)
            if MFMailComposeViewController.canSendMail() {
                let userModel = UserModel()
                self.popupView.showInView(parentView: self.view,
                                                withTxbString: userModel.userPhone ?? "",
                                                popupType: PopupWithTxbType.EmailHelp)
                { (phoneNo, isChecked) in
                    if phoneNo != (userModel.userPhone ?? "") && phoneNo != "" {
                        userModel.savePhoneNumber(phoneNo: phoneNo)
                    }
                    self.present(self.configuredMailComposeViewController(userPhone: isChecked ? nil : phoneNo), animated: true, completion: nil)
                }
            } else {
                self.popViewController.showInView(self.view, withTitle: StringConstants.StatusMessages.Device_DoesNot_Support_Email_Title, withMessage:StringConstants.StatusMessages.Device_DoesNot_Support_Email, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil, animated: true, isMessage: false)
            }
            break
            
            
        case 2:
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.DOCUMENTATION_CLICKED)
            AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.DOCUMENTATION_PAGE
            let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalWebVC") as? GlobalWebViewController
            globalVC!.webURL = AppInfo.sharedInstance.userRole == Constants.Anonymous_User ? Constants.Clearthread.AnonymousDocuments : Constants.Clearthread.Documentation
            globalVC?.pageType = .documentation
            globalVC?.viewTitle = StringConstants.PageTitles.VIDEO_TUTORIAL_PG_TLT
            self.navigationController?.pushViewController(globalVC!, animated: true)
            break
            
        case 3:
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.SUPPORTED_DEVICE_CLICKED)
            AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.APPROVED_DEVICE_PAGE
            let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewWithAuthVC") as? WebViewWithAuthVController
            globalVC?.pageTitle = StringConstants.PageTitles.SUPPORTED_DEVICE_PG_TLT
            globalVC?.pageType = .SupportedDevices
            self.navigationController?.pushViewController(globalVC!, animated: true)
            break
            
        case 4:
            //Appsee.addScreenAction( StringConstants.AppseePageTitles.WHATs_NEW_PAGE)
            AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.WHATs_NEW_PAGE
            let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewWithAuthVC") as? WebViewWithAuthVController
            globalVC?.pageTitle = StringConstants.MenuTitles.WHATS_NEW
            globalVC?.pageType = .WhatsNew
            self.navigationController?.pushViewController(globalVC!, animated: true)
            break
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configuredMailComposeViewController(userPhone: String?) -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.navigationBar.tintColor = .red
        if let user = DBUserServices.getUserModelForUsername(self.appInfo.username)?.first {
            if let helpEmail = user.helpDeskEmail {
                if helpEmail != "" {
                    mailComposerVC.setToRecipients([helpEmail])
                } else {
                    mailComposerVC.setToRecipients(["mobile.support@clearthread.com"])
                }
            } else {
                mailComposerVC.setToRecipients(["mobile.support@clearthread.com"])
            }

            let userPhoneNo = (userPhone != nil && userPhone != "") ? "Phone Number: \(userPhone!)\n" : ""
            mailComposerVC.setMessageBody("\n\n\n(Please Do Not Remove)\nUser Id: \(user.userName ?? "")\n\(userPhoneNo)Device Id: \(appInfo.deviceId)\nApp Version: \(appInfo.appVersion)\niOS Version: \(appInfo.osVersion)\nDevice Model: \(appInfo.deviceModel)\n", isHTML: false)
        }
        
        mailComposerVC.setSubject(StringConstants.StatusMessages.EMAIL_SUBJECT + " - \(appInfo.username ?? "")")
        return mailComposerVC
    }
    
    //MARK: - Email Delegate function
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
