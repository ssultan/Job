//
//  PopUpViewControllerSwift.swift
//  
//
//  Created by Saleh Sultan on 12/13/2016.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
//import Appsee
import QuartzCore

@objc open class PopUpViewControllerSwift : UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var acceptBtWidthConst: NSLayoutConstraint!
    @IBOutlet weak var closeBt: UIButton!
    @IBOutlet weak var acceptBt: UIButton!
    @IBOutlet weak var bottomConsDis: NSLayoutConstraint!
    @IBOutlet weak var webMsgView: UIWebView!
    

    @IBOutlet weak var popUpView2nd: UIView!
    @IBOutlet weak var messageLabel2nd: UILabel!
    @IBOutlet weak var titleLbl2nd: UILabel!
    @IBOutlet weak var closeBt2nd: UIButton!
    @IBOutlet weak var acceptBt2nd: UIButton!
    @IBOutlet weak var bottomConsDis2nd: NSLayoutConstraint!

    var removeAnim:Bool = true

    
    var onAcceptBlockFunc:()->() = {}
    var onCancelBlockFunc:()->() = {}
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 10
        self.popUpView.clipsToBounds = true
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        self.popUpView2nd.layer.cornerRadius = 10
        self.popUpView2nd.clipsToBounds = true
        self.popUpView2nd.layer.shadowOpacity = 0.8
        self.popUpView2nd.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        self.webMsgView.backgroundColor = UIColor.clear
        self.webMsgView.isOpaque = false
        //Appsee.installJavascriptInterface(webMsgView!)
        
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.frame = UIScreen.main.bounds
        
        let screenheight = self.view.frame.size.height + 70
        if screenheight > self.popUpView.frame.size.height {
            let difference = screenheight - self.popUpView.frame.size.height
            bottomConsDis.constant = difference/2 - 10 //+ 25
            bottomConsDis2nd.constant = difference/2 + 35
        }
    }
    

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 10
        self.popUpView.clipsToBounds = true
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    @objc open func showInView(_ aView: UIView!,
                               withTitle title : String!,
                               withMessage message: String!,
                               withCloseBtTxt closeTxt:String!,
                               withAcceptBt acceptTxt:String!,
                               animated: Bool,
                               isMessage: Bool,
                               removeAnimation:Bool = true,
                               btnDispTypeParallel:Bool = false,
                               continueBlock:@escaping ()->() = {},
                               cancelBlock:@escaping ()->() = {})
    {
        aView.addSubview(self.view)
        onAcceptBlockFunc = continueBlock
        onCancelBlockFunc = cancelBlock
        removeAnim = removeAnimation
        
        if btnDispTypeParallel {
            popUpView2nd.isHidden = false
            popUpView.isHidden = true
            titleLbl2nd.text = title
            closeBt2nd.setTitle(closeTxt, for: .normal)
            
            if acceptTxt != nil {
                acceptBt2nd.setTitle(acceptTxt, for: .normal)
                if isMessage {
                    acceptBt2nd.setBackgroundImage(UIImage(named: "GrayBtnSelected"), for: .highlighted);
                    acceptBt2nd.setBackgroundImage(UIImage(named: "GrayButton"), for: .normal);
                }
            }
            messageLabel2nd!.text = message
            self.showAnimate(animated: animated)
            return
        }
        
        popUpView2nd.isHidden = true
        popUpView.isHidden = false
        
        titleLbl.text = title
        closeBt.setTitle(closeTxt, for: UIControl.State())
        
        if acceptTxt != nil {
            acceptBt.setTitle(acceptTxt, for: UIControl.State())
            acceptBtWidthConst.constant = 56
        } else {
            acceptBtWidthConst.constant = 0
        }
        
        if isMessage {
            titleLbl.textColor = Utility.UIColorFromRGB(Constants.LOGO_YELLOW_COLOR)
        }
        messageLabel.isHidden = false
        webMsgView.isHidden = true
        messageLabel!.text = message
        self.showAnimate(animated: animated)
    }
    
    
    open func showMsgInWebView(_ aView: UIView!, withTitle title : String!, withMessage message: String!, withHtmlFileName fileName:String!, withCloseBtTxt closeTxt:String!, withAcceptBt acceptTxt:String!, animated: Bool, isMessage: Bool, continueBlock:@escaping ()->() = {}, cancelBlock:@escaping ()->() = {})
    {
        aView.addSubview(self.view)
        
        titleLbl.text = title
        onAcceptBlockFunc = continueBlock
        onCancelBlockFunc = cancelBlock
        closeBt.setTitle(closeTxt, for: UIControl.State())
        
        if acceptTxt != nil {

            acceptBt.setTitle(acceptTxt, for: UIControl.State())
//            acceptBt.setTitleColor(UIColor.white, for: UIControl.State())
//            closeBt.setTitleColor(UIColor.white, for: UIControl.State())
            acceptBtWidthConst.constant = 56
        } else {
            acceptBtWidthConst.constant = 0
        }
        
//        if isMessage {
//            titleLbl.textColor = Utility.UIColorFromRGB(Constants.LOGO_YELLOW_COLOR)
//        }
        messageLabel.isHidden = true
        webMsgView.isHidden = false
        
    
        if let webMsg = message {
            messageLabel.text = webMsg
            let htmlStr = "<!DOCTYPE html>" +
                "<html lang=\"en\">" +
                "<head>" +
                "<meta charset=\"UTF-8\">" +
                "<style type=\"text/css\">" +
                "html{margin:0;padding:0;}" +
                "body { margin: 20px; padding: 0px; color: black; font: 17px Arial;" +
                "line-height: 1.6; background-color: transparent;}" +
                "a {color:rgb(1,145,254);}" +
                "</style></head>" +
                "<body id=\"page\">" +
                "\(webMsg) </body></html>"
            self.webMsgView.loadHTMLString(htmlStr, baseURL: Bundle.main.bundleURL)
        }
        else if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            self.webMsgView.loadRequest(URLRequest(url: url))
        }
        
        self.showAnimate(animated: animated)
    }
    
    
    
    func showAnimate(animated: Bool)
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: animated ? 0.25 : 0.0, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        messageLabel.isHidden = true
        webMsgView.isHidden = true
        
        if removeAnim {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
            });
        } else{
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            self.view.removeFromSuperview()
        }
    }
    
    @IBAction open func closePopup(_ sender: AnyObject) {
        self.removeAnimate()
        onCancelBlockFunc()
    }
    
    @IBAction open func acceptBtPressed(_ sender: AnyObject) {
        self.removeAnimate()
        onAcceptBlockFunc()
    }
}
