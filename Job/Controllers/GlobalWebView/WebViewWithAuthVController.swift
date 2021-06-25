//
//  WebViewWithAuthVController.swift
//  Job V2.0
//
//  Created by Saleh Sultan on 5/8/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import WebKit
import JGProgressHUD
import SafariServices

enum AuthWebPageType {
    case SupportedDevices
    case SupportedOS
    case WhatsNew
}

class WebViewWithAuthVController: RootViewController, WKNavigationDelegate, WKUIDelegate {
    
    var loadingView: JGProgressHUD!
    var aWebView: WKWebView!
    var nWebView: WKWebView!
    var pageTitle = ""
    var pageType : AuthWebPageType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = pageTitle
        
        self.aWebView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 35), configuration: WKWebViewConfiguration.init())
        self.aWebView.navigationDelegate = self
        self.aWebView.uiDelegate = self
        self.view.addSubview(aWebView)
        self.setNavRightBarItem()
        
        if pageType == .SupportedDevices {
            let request = NSURLRequest(url: NSURL(string: Constants.Clearthread.ApprovedDeviceListURL)! as URL)
            self.aWebView.load(request as URLRequest)
        }
        else if pageType == .WhatsNew {
            let request = NSURLRequest(url: NSURL(string: Constants.Clearthread.WhatsNewURL)! as URL)
            self.aWebView.load(request as URLRequest)
        }
        else {
            let request = NSURLRequest(url: NSURL(string: Constants.Clearthread.ApprovedDeviceOSURL)! as URL)
            self.aWebView.load(request as URLRequest)
        }
        
        //Appsee.installJavascriptInterface(aWebView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - WKWebView delegate methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        let url = webView.url?.absoluteString
        if pageType == .SupportedDevices && url != Constants.Clearthread.ApprovedDeviceListURL {
            nWebView.removeFromSuperview()
            
            
            if UI_USER_INTERFACE_IDIOM() == .phone || UI_USER_INTERFACE_IDIOM() == .pad {
                if #available(iOS 9.0, *) {
                    let safari = SFSafariViewController.init(url: webView.url!)
                    
                    self.present(safari, animated: true, completion: {
                        // It can be any overlay. May be your logo image here inside an imageView.
                        let overlay = UIView(frame: CGRect(x: 0, y: 0, width: webView.frame.size.width, height: 65))
                        overlay.backgroundColor = UIColor.black
                        
                        let imageV = UIImageView(frame: overlay.frame)
                        imageV.image = UIImage(named: "navbar_new.png")
                        overlay.addSubview(imageV)
                        
                        let viewTitle = UILabel(frame: CGRect(x: (webView.frame.size.width/2) - 60, y: 25, width: 120, height: 30))
                        viewTitle.text = StringConstants.PageTitles.VIDEO_TUTORIAL_PG_TLT
                        viewTitle.textAlignment = .center
                        viewTitle.font = UIFont(name: "SegoeUI", size: 20)
                        viewTitle.textColor = .white
                        viewTitle.backgroundColor = UIColor.clear
                        overlay.addSubview(viewTitle)
                        
                        let homeBtn = UIButton()
                        homeBtn.setTitleColor(UIColor.white, for: .normal)
                        homeBtn.frame = CGRect(x: 10, y: 25, width: 28, height: 28)
                        homeBtn.backgroundColor =  UIColor.clear
                        
                        homeBtn.setBackgroundImage(UIImage(named: "ArrowLeftIcon"), for: .normal)
                        homeBtn.addTarget(self, action: #selector(self.HomeBtnAction), for: UIControl.Event.touchUpInside)
                        
                        overlay.addSubview(homeBtn)
                        safari.view.addSubview(overlay)
                    })
                } else {
                    self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage:StringConstants.StatusMessages.Redirect_To_Browser_Msg, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_OPN_TUTORIAL, animated: true, isMessage: true, continueBlock: {
                        UIApplication.shared.openURL(webView.url!)
                    })
                }
            }
            else {
                self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage:StringConstants.StatusMessages.Redirect_To_Browser_Msg, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_OPN_TUTORIAL, animated: true, isMessage: true, continueBlock: {
                    UIApplication.shared.open(webView.url!)
                })
            }
        }
        else {
            self.loadingView = JGProgressHUD(style: .extraLight)
            self.loadingView.textLabel.text = StringConstants.StatusMessages.LOADING
            self.loadingView.show(in: self.view, animated: true)
        }
    }
    
    
    @objc func HomeBtnAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARKS :- WKWebView delegate functions
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        #if DEBUG
        let creds = URLCredential(user:AppInfo.sharedInstance.username, password:"", persistence: URLCredential.Persistence.forSession)
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, creds)
        #elseif STAGE
        let password = String(describing: (AppInfo.sharedInstance.environment == Constants.Environments.kProduction || AppInfo.sharedInstance.environment == Constants.Environments.kProdUAT) ? (AppInfo.sharedInstance.password ?? "") : "")
        let username = AppInfo.sharedInstance.username ?? "ssultan"
        let creds = URLCredential(user:username, password:password, persistence: URLCredential.Persistence.forSession)
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, creds)
        #else
        
        if let userId = AppInfo.sharedInstance.username, let password = AppInfo.sharedInstance.password {
            let creds = URLCredential(user:userId, password:password, persistence: URLCredential.Persistence.forSession)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, creds)
        }
        #endif
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingView.dismiss(animated: true)
        webView.evaluateJavaScript("document.getElementsByClassName('davaco-top')[0].style.display='none'", completionHandler: nil)    // Hide the top view.
        webView.evaluateJavaScript("document.getElementsByClassName('davaco-footer')[0].style.display='none'", completionHandler: nil)  // Hide the Bottom view.
        
        webView.evaluateJavaScript("document.getElementsByClassName('header-section-container')[0].style.display = 'none'", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementsByClassName('page-title-section')[0].style.display = 'none'", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementsByClassName('footer-top-section')[0].style.display='none'", completionHandler: nil)
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.loadingView.dismiss(animated: true)
        Utility.showCustomMsg(self.view, label: StringConstants.StatusMessages.Connection_Error_Msg_Title, detailslbl: StringConstants.StatusMessages.Connection_Error_Msg, isSuccessImg: false, duration: 3)
        {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        nWebView = WKWebView(frame: webView.frame, configuration: configuration)
        nWebView.navigationDelegate = self
        nWebView.uiDelegate = self
        self.view.addSubview(nWebView)
        return nWebView
    }
}
