//
//  GlobalWebViewController.swift
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
import JGProgressHUD
import AVKit
import AVFoundation
import MediaPlayer
import GoogleMaps
//import Appsee

enum WebPageType {
    case forgotPassword
    case documentation
    case googleStreetView
}

class GlobalWebViewController: RootViewController, UIWebViewDelegate, AVPlayerViewControllerDelegate {

    @IBOutlet weak var glWebView: UIWebView!
    var webURL:String! = nil
    var viewTitle:String! = nil
    var loadingView: JGProgressHUD = JGProgressHUD(style: .extraLight)
    var player = AVPlayer()
    var pageType:WebPageType!
    var panoView: GMSPanoramaView!
    var latitude: Double = 0.00
    var longitude: Double = 0.00
    var sViewRadius: Int = 1
    var sViewRadMultiplier:Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewTitle
        self.navigationItem.leftBarButtonItem = nil
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if pageType == .googleStreetView {
            self.loadingView.textLabel.text = StringConstants.StatusMessages.PLEASE_WAIT_MSG
            self.loadingView.show(in: self.view, animated: true)
            self.loadGoogleStreetView(forRadius: sViewRadius * sViewRadMultiplier)
            sViewRadius+=1
        }
        else {
            let request = URLRequest(url: URL(string: webURL)!)
            glWebView.loadRequest(request)
        }
        
        //Appsee.installJavascriptInterface(glWebView)
        UIToolbar.appearance().tintColor = UIColor.black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIToolbar.appearance().tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadGoogleStreetView(forRadius radius: Int, willReturn isReturn: Bool = false, forSource source: GMSPanoramaSource = GMSPanoramaSource.outside) {
        
        GMSPanoramaService().requestPanoramaNearCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: UInt(radius), source:source, callback: { (panorama, error) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    if panorama != nil {
                        self.panoView = GMSPanoramaView(frame: .zero)
                        self.view = self.panoView
                        self.panoView.delegate = self
                        self.panoView.moveNearCoordinate(CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), radius: UInt(radius), source:GMSPanoramaSource.outside)
                    }
                })
            }
            else if isReturn {
                Utility.showCustomMsg(self.view, label: StringConstants.StatusMessages.StreetView_Not_Available_Msg_Title, detailslbl:StringConstants.StatusMessages.StreetView_Not_Available_Msg, isSuccessImg: false, duration: 2)
                {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
            else if !isReturn {
                if self.sViewRadius * self.sViewRadMultiplier <= 600 {
                    self.loadGoogleStreetView(forRadius: self.sViewRadius*self.sViewRadMultiplier)
                    self.sViewRadius+=1
                } else {
                    self.loadGoogleStreetView(forRadius: self.sViewRadius*self.sViewRadMultiplier, willReturn: true)
                }
            }
        })
    }
    
    
    //MARK: - WebView Delegate functions
    func webViewDidStartLoad(_ webView: UIWebView) {
        loadingView.textLabel.text = StringConstants.StatusMessages.LOADING
        self.loadingView.show(in: self.view, animated: true)
        webView.isHidden = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingView.dismiss(animated: true)
        
        if pageType == .forgotPassword {
            // Hide the menu. We don't need menu items
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('davaco-navbar-inner')[0].style.display='none'")
            webView.stringByEvaluatingJavaScript(from: "document.getElementById('consent_blackbar').style.display='none'")
            webView.stringByEvaluatingJavaScript(from: "document.body.style.marginTop = '15px'")
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('tab')[0].lastElementChild.click()")
            
            if let url = webView.request?.url?.absoluteString {
                webView.isHidden = false
                if url.contains("/Login.aspx?") {
                    webView.isHidden = true
                    Utility.showCustomMsg(self.view, label: StringConstants.ButtonTitles.BTN_SUCESS, detailslbl: StringConstants.StatusMessages.FORGOT_USERID_PASS_MSG, isSuccessImg: true, duration: 2) {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        else if pageType == .documentation {
            // Hide the menu. We don't need menu items
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('container')[0].style.display = 'none'")
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('davaco-footer')[0].style.display='none'")
            
            if let url = webView.request?.url?.absoluteString {
                // If the page is login page, then don't need to show the webView.
                if url.contains("/mobileLogin.aspx?") || url.contains("/Account/Login?") {
                    webView.isHidden = true
                }
                else if url.contains(webURL) {
                    webView.isHidden = false
                    return
                }
                else if url.contains(".pdf") {
                    webView.goBack()
                    let pdfView = self.storyboard?.instantiateViewController(withIdentifier: "PDFVC") as! PDFViewerController
                    pdfView.pdfURL = url
                    let navView = UINavigationController.init(rootViewController: pdfView)
                    self.present(navView, animated: true, completion: nil)
                }
                else {
                    webView.goBack()
                }
            }
            
            //Programmatically add username and password in the webview text field. Then we will run javascript function to click the login button and do the event. We will pull username and password from keychain as user already logged into the app, that's why we don't need to let the user login again.
            let password = String(describing: AppInfo.sharedInstance.environment == Constants.Environments.kProduction ? (AppInfo.sharedInstance.password ?? "") : "")
            let username = AppInfo.sharedInstance.username ?? ""
            
            if AppInfo.sharedInstance.userRole == Constants.Anonymous_User {
                webView.stringByEvaluatingJavaScript(
                from: "document.getElementById('UserName').value='\(username)';   document.getElementById('Password').value='\(password)';  document.getElementById('BtnLogin').click();")
            } else {
                webView.stringByEvaluatingJavaScript(
                from: "document.getElementById('ContentPlaceHolder1_txtUsername').value='\(username)';   document.getElementById('ContentPlaceHolder1_txtPassword').value='\(password)';  document.getElementById('ContentPlaceHolder1_btnLogin').click();")
            }
        }
            
        // THis is not working.
        else if pageType == .googleStreetView {
            webView.isHidden = false
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('ml-unsupported-link-dialog-container')[0].style.display='none'")
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('gm-iv-address-description')[0].style.display='none'")
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        loadingView.dismiss(animated: true)
        
        if let url = webView.request?.url?.absoluteString {
            if pageType == .documentation && url.contains(".mp4") {
                player = AVPlayer(url: URL(string: (webView.request?.url?.absoluteString)!)!)
                let playerController = AVPlayerViewController()
                
                playerController.player = player
                playerController.view.frame = self.view.bounds
                
                self.present(playerController, animated: true, completion: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(GlobalWebViewController.finishedVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                
                player.play()
                webView.goBack()
                return
            }
        }
        
        Utility.showCustomMsg(self.view, label: StringConstants.StatusMessages.Connection_Error_Msg_Title, detailslbl: StringConstants.StatusMessages.Connection_Error_Msg, isSuccessImg: false, duration: 3) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    //Video has been finished. Now hide the controller.
    @objc func finishedVideo() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return true
    }
}

extension GlobalWebViewController: GMSPanoramaViewDelegate {
    
    func panoramaView(_ view: GMSPanoramaView, willMoveToPanoramaID panoramaID: String) {
        print("Panorama Id: \(panoramaID)")
    }
    
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama?) {}
    
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama, nearCoordinate coordinate: CLLocationCoordinate2D) {
        print ("Moved to coordinate: \(coordinate)")
    }
    
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
        print("Error to move to the co-ordinate")
        if sViewRadius * sViewRadMultiplier <= 600 {
            self.loadGoogleStreetView(forRadius: sViewRadius*sViewRadMultiplier)
            sViewRadius+=1
        } else {
            self.loadGoogleStreetView(forRadius: sViewRadius*sViewRadMultiplier, willReturn: true)
        }
    }
    
    func panoramaViewDidStartRendering(_ panoramaView: GMSPanoramaView) {
        print("Started loading street view.")
    }
    
    func panoramaViewDidFinishRendering(_ panoramaView: GMSPanoramaView) {
        loadingView.dismiss(animated: true)
    }
}
