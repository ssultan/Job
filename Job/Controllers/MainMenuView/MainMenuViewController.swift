//
//  MainMenuViewController.swift
//  Job V2.0
//
//  Created by Saleh Sultan on 9/18/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import Alamofire
import JGProgressHUD

protocol MainMenuViewProtocal {
//    func updateSelectedArrayItem(forIndex index: Int, isComplete: Bool, withInstance instance: selJobInstance)
}

class MainMenuViewController: RootViewController {

    @IBOutlet weak var menuTableView: UITableView!

    let menuArray:NSArray = [StringConstants.MenuTitles.START_NEW_JOB, StringConstants.MenuTitles.INCOMPLETE_JOBS, StringConstants.MenuTitles.TRANSMIT_REPORT]
    
    var instCompletedCount: Int = 0
    var instInCompletedCount: Int = 0
    
    var transmitReportCounter = "0/0"
    var isOfflineLogin:Bool = false
    var isLoadingFirstTime = true
    
    @IBOutlet weak var btmVContainer: UIView!
    @IBOutlet weak var tbBtmConst05: NSLayoutConstraint!
    @IBOutlet weak var tbBtmConst06: NSLayoutConstraint!
    @IBOutlet weak var whatsNewBtn: UIButton!
    @IBOutlet weak var whatsNewBtnIcon: UIImageView!
    
    // Define the progress bar
    var loadingView = JGProgressHUD(style: .extraLight)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = StringConstants.PageTitles.MAIN_MENU_PAGE_TLT
        menuTableView.tableFooterView = UIView()
        self.navigationItem.hidesBackButton = true
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone {
            menuTableView.isScrollEnabled = true
        }
        
        if let user = UserModel.getUser(forUserName: AppInfo.sharedInstance.username!) {
            if user.roleName == Constants.Anonymous_User {
                self.whatsNewBtn.isHidden = true
                self.whatsNewBtnIcon.isHidden = true
            }
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(gotoTransmitRepoView), name: NSNotification.Name(rawValue: Constants.NotificationsName.OPEN_TRANS_REPO_NOACTION), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(gotoSentReportPage(notification:)), name: NSNotification.Name(rawValue: Constants.NotificationsName.OPEN_SENT_REPORTS), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.view.isUserInteractionEnabled = true
        self.setNavRightBarItem()
        self.manageSlideMenu()
        
        instCompletedCount = JobServices.loadJobInstanceCounter(isCompleted: true)
        instInCompletedCount = JobServices.loadJobInstanceCounter(isCompleted: false)
        self.transmitReportCounter = JobServices.getTransmitReportCounter()
        self.menuTableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIApplication.shared.statusBarFrame.width > 320 {
            tbBtmConst05.isActive = true
            tbBtmConst06.isActive = false
        } else {
            tbBtmConst05.isActive = false
            tbBtmConst06.isActive = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        if isOfflineLogin && isLoadingFirstTime {
            isLoadingFirstTime = false
//            self.showOfflineLoginPopup()
        }
    }
    
    // MARK: - Notifications
    @objc func gotoTransmitRepoView() {
        let reportView = self.storyboard?.instantiateViewController(withIdentifier: "TransmitReportVC") as! TransmitReportViewController
        self.navigationController?.pushViewController(reportView, animated: true)
    }
    
    
    @objc func gotoSentReportPage(notification:NSNotification) {
        let reportView = self.storyboard?.instantiateViewController(withIdentifier: "TransmitReportVC") as! TransmitReportViewController
        self.navigationController?.pushViewController(reportView, animated: true)

        if let userInfo = notification.userInfo {
            if let isCompleteNSend = userInfo["isCompleteNSend"] as? Bool {
                if let instance = AppInfo.sharedInstance.selJobInstance {
                    DispatchQueue.global().async {
                        BackgroundServices.sharedInstance.sendCompletedInstance(instance: instance, isUpdatingJob: !isCompleteNSend) // Reverse of Complete is Update.
                    }
                }
            }
        }
    }

//    @objc func showOfflineLoginPopup() {
//        // Do not show this message
//        //self.showErrorMsg(StringConstants.StatusMessages.Offline_Login_Message, title: "You are logged in as Offline!")
//    }

    @IBAction func whatsNewBtnAction() {
        //Appsee.addScreenAction( StringConstants.AppseePageTitles.WHATs_NEW_PAGE)
        AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.WHATs_NEW_PAGE
        let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewWithAuthVC") as? WebViewWithAuthVController
        globalVC?.pageTitle = StringConstants.MenuTitles.WHATS_NEW
        globalVC?.pageType = .WhatsNew
        self.navigationController?.pushViewController(globalVC!, animated: true)
    }
    
    @IBAction func tutorialBtnAction() {
        AppInfo.sharedInstance.pageAboutToLoad = "ClearThread Tutorial Page"
        let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalWebVC") as? GlobalWebViewController
        globalVC!.webURL = AppInfo.sharedInstance.userRole == Constants.Anonymous_User ? Constants.Clearthread.AnonymousDocuments : Constants.Clearthread.Documentation
        globalVC?.pageType = .documentation
        globalVC?.viewTitle = StringConstants.PageTitles.VIDEO_TUTORIAL_PG_TLT
        self.navigationController?.pushViewController(globalVC!, animated: true)
    }
    
    @IBAction func helpDeskBtnAction() {
        let helpView = self.storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpViewController
        self.navigationController?.pushViewController(helpView, animated: true)
    }
    
    @IBAction func logoutBtnAction() {
        self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Caution,
                                          withMessage:StringConstants.StatusMessages.LogoutPopupMsg,
                                          withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_LOGOUT,
                                          animated: true, isMessage: true, btnDispTypeParallel: true, continueBlock: {
                                            
                                            AppInfo.sharedInstance.userAuthToken = ""
                                            BackgroundServices.sharedInstance.stopTimer() //Stop timer
                                            _ = self.navigationController?.popToRootViewController(animated: true)
        })
    }
}

extension MainMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: -
    // MARK: - UITableView Delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //variable type is inferred
        let cell:MainMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainMenuTVCell", for: indexPath) as! MainMenuTableViewCell
        
        cell.backgroundColor = UIColor.clear
        cell.cellTitlelbl.text = menuArray.object(at: (indexPath as NSIndexPath).row) as? String
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.cellImgV.image = UIImage(named: "StartSurveyIcon")
            cell.cellDetailsCtlbl?.text = ""
            break
        case 1:
            cell.cellImgV.image = UIImage(named: "IncomSurveyIcon")
            cell.cellDetailsCtlbl?.text = "\(instInCompletedCount)"
            break
        case 2:
            cell.cellImgV.image = UIImage(named: "TransReopIcon")
            cell.cellDetailsCtlbl?.text = self.transmitReportCounter
            break
        default:
            cell.cellDetailsCtlbl?.text = ""
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.START_JOB_CLICKED)
            let startJob = self.storyboard?.instantiateViewController(withIdentifier: "StartJobVC") as! StartJobViewController
            self.navigationController?.pushViewController(startJob, animated: true)
            break
            
        case 1:
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.INCOMPLETE_CLICKED)
            AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.INCOMPLETED_JOB_PAGE
            let incompleteJob = self.storyboard?.instantiateViewController(withIdentifier: "CompIncompVC") as! CompIncompViewController
            self.navigationController?.pushViewController(incompleteJob, animated: true)
            break
            
        case 2:
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.TEANSMIT_REPO_CLICKED)
            let reportView = self.storyboard?.instantiateViewController(withIdentifier: "TransmitReportVC") as! TransmitReportViewController
            self.navigationController?.pushViewController(reportView, animated: true)
            break
            
        case 3:
            
            break
            
        default:
            //Appsee.addScreenAction(StringConstants.AppseeScreenAction.LOGOUT_CLICKED)
            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Message,
                                              withMessage:StringConstants.StatusMessages.LogoutPopupMsg,
                                              withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_LOGOUT,
                                              animated: true, isMessage: true, continueBlock: {
                
                AppInfo.sharedInstance.userAuthToken = ""
                BackgroundServices.sharedInstance.stopTimer() //Stop timer
                _ = self.navigationController?.popToRootViewController(animated: true)
            })
            break
        }
//        self.view.isUserInteractionEnabled = false
    }
}
