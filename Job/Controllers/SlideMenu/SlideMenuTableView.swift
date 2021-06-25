//
//  SlideMenuTableView.swift
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
//import Appsee

enum LeftMenu {
    case help
    case login
    case mainMenu
    case email
    case tutorial
    case navigate
    case debugger
    case whatsNew
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class SlideMenuTbVCell: UITableViewCell {
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        let selImgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        selImgView.frame = self.frame
        self.selectedBackgroundView = selImgView
        self.selectionStyle = .blue
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class SlideMenuTableView: UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var usernamelbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var loginView: UINavigationController!
    var mainMenuView: UINavigationController!
    var helpView: UINavigationController!
    var debuggerView: UINavigationController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        self.tableView.estimatedRowHeight = 80.0;
        self.tableView.rowHeight = UITableView.automaticDimension;
        
        let login = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.loginView = UINavigationController(rootViewController: login)
        
        let mainMenu = self.storyboard?.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuViewController
        self.mainMenuView = UINavigationController(rootViewController: mainMenu)

        let help = self.storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpViewController
        help.isFromMenu = true
        self.helpView = UINavigationController(rootViewController: help)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name:NSNotification.Name(rawValue: Constants.NotificationsName.RELOAD_TABLE_NOTIFY), object: nil)
    }
    
    
    @objc func reloadTableView() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let username = AppInfo.sharedInstance.username {
            self.usernamelbl.text = username
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .mainMenu:
            if let middleView = self.slideMenuController()!.mainViewController {
                let navController = middleView as! UINavigationController
                for viewController in navController.viewControllers {
                    
                    if viewController is MainMenuViewController {
                        _ = navController.popToViewController(viewController, animated: true)
                        self.slideMenuController()?.closeRight()
                        break
                    }
                }
            }
            break
            
        case .help:
            if let middleView = self.slideMenuController()!.mainViewController {
                let navController = middleView as! UINavigationController
                
                for viewController in navController.viewControllers {
                    if viewController is MainMenuViewController {
                        _ = navController.popToViewController(viewController, animated: false)
                        break
                    }
                }
                
                let help = self.storyboard?.instantiateViewController(withIdentifier: "HelpVC") as! HelpViewController
                help.isFromMenu = true
                navController.pushViewController(help, animated: false)
                self.slideMenuController()?.closeRight()
            }
            break
            
        case .email:
            NotificationCenter.default.post(name: Notification.Name(Constants.NotificationsName.SendEmailNotifier), object: nil)
            self.slideMenuController()?.closeRight()
            break
            
        case .login:
            AppInfo.sharedInstance.userAuthToken = ""
            BackgroundServices.sharedInstance.stopTimer()
            self.navigationController?.popToRootViewController(animated: true)
            break
            
        default:
            break
        }
    }
}

extension SlideMenuTableView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = AppInfo.sharedInstance.menus[indexPath.row]
        //Appsee.addScreenAction("HM Btn '\(menuItem)' Clicked")
        tableView.deselectRow(at: indexPath, animated: true)
        
        var menu: LeftMenu = .login
        if menuItem == StringConstants.MenuTitles.LOGOUT {
            menu = .login
        } else if menuItem == StringConstants.MenuTitles.HELP {
            menu = .help
        } else if menuItem == StringConstants.MenuTitles.MAIN_MENU {
            menu = .mainMenu
        } else if menuItem == StringConstants.MenuTitles.EMAIL {
            menu = .email
        } else if menuItem == StringConstants.MenuTitles.DEBUGGER {
            menu = .debugger
        } else if menuItem == StringConstants.MenuTitles.TUTORIALS {
            menu = .tutorial
        } else if menuItem == StringConstants.MenuTitles.WHATS_NEW {
            menu = .whatsNew
        }
        var vcAvailable = false
        if let middleView = self.slideMenuController()!.mainViewController {
            let navController = middleView as! UINavigationController
            

            if menu == .tutorial {
                AppInfo.sharedInstance.pageAboutToLoad = "ClearThread Documentation Page"
                let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalWebVC") as? GlobalWebViewController
                globalVC!.webURL = AppInfo.sharedInstance.userRole == Constants.Anonymous_User ? Constants.Clearthread.AnonymousDocuments : Constants.Clearthread.Documentation
                globalVC?.pageType = .documentation
                globalVC?.viewTitle = StringConstants.PageTitles.VIDEO_TUTORIAL_PG_TLT
                navController.pushViewController(globalVC!, animated: true)
                
                vcAvailable = true
            }
            else if menu == .whatsNew {
                //Appsee.addScreenAction( StringConstants.AppseePageTitles.WHATs_NEW_PAGE)
                AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.WHATs_NEW_PAGE
                let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewWithAuthVC") as? WebViewWithAuthVController
                globalVC?.pageTitle = StringConstants.MenuTitles.WHATS_NEW
                globalVC?.pageType = .WhatsNew
                navController.pushViewController(globalVC!, animated: true)
                vcAvailable = true
            }
            else {
                for viewControl in navController.viewControllers {
                    if menu == .login && viewControl is LoginViewController {
                        vcAvailable = true
                        BackgroundServices.sharedInstance.stopTimer()
                        navController.popToViewController(viewControl, animated: true)
                    }
                    else if menu == .mainMenu && viewControl is MainMenuViewController {
                        vcAvailable = true
                        navController.popToViewController(viewControl, animated: true)
                    }
                    else if menu == .help && viewControl is HelpViewController {
                        vcAvailable = true
                        navController.popToViewController(viewControl, animated: true)
                    }
//                    else if let fvModel = viewControl as? FieldVisitInfoViewController {
//                        if fvModel.comIncomDelegate != nil {
//                            fvModel.comIncomDelegate.updateSelectedArrayItem(forIndex: fvModel.selectedItem)
//                        }
//                    }
                }
            }
        }
        
        if !vcAvailable { self.changeViewController(menu) }
        else { self.slideMenuController()?.closeRight() }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}

extension SlideMenuTableView : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppInfo.sharedInstance.menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTBCell", for: indexPath) as! SlideMenuTbVCell
        cell.menuTitle.text = AppInfo.sharedInstance.menus[indexPath.row]
        
        let menu = cell.menuTitle.text;
        if menu == StringConstants.MenuTitles.LOGOUT {
            cell.menuIcon.image = UIImage(named: "LogoutIcon")
        } else if menu == StringConstants.MenuTitles.TUTORIALS {
            cell.menuIcon.image = UIImage(named: "TutorialIcon")
        } else if menu == StringConstants.MenuTitles.HELP {
            cell.menuIcon.image = UIImage(named: "HelpDeskIcon")
        } else if menu == StringConstants.MenuTitles.MAIN_MENU {
            cell.menuIcon.image = UIImage(named: "MainMenuIcon")
        } else if menu == StringConstants.MenuTitles.EMAIL {
            cell.menuIcon.image = UIImage(named: "EmailIcon")
        } else if menu == StringConstants.MenuTitles.WHATS_NEW {
            cell.menuIcon.image = UIImage(named: "whatsNewIcon")
        } else if menu == StringConstants.MenuTitles.DEBUGGER {
            cell.menuIcon.image = UIImage(named: "")
        }
        return cell
    }
}
