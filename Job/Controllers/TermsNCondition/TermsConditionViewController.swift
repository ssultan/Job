//
//  TermsConditionViewController.swift
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

class TermsConditionViewController: RootViewController, UIWebViewDelegate {

    @IBOutlet weak var tcWebView: UIWebView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btmConstToBottomV: NSLayoutConstraint!
    
    var isAcceptedTermsnCon: Bool = false
    var delegate:LoginOberverDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.TMS_N_CONDS_PG_TLT
        self.navigationItem.leftBarButtonItem = nil
        
        if let url = Bundle.main.url( forResource: "TermsnConditionsen", withExtension: "html") {
            tcWebView.loadRequest(URLRequest(url: url as URL))
        }
        
        if isAcceptedTermsnCon {
            bottomView.isHidden = true
            self.btmConstToBottomV.constant = -(bottomView.frame.height)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: - Button Action Methods
    @IBAction func acceptBtAction(_ sender: AnyObject) {
        _ = [self.dismiss(animated: true, completion: {
            self.delegate.eulaPanelViewControllerAcceptedEULA()
        })]
    }
    
    @IBAction func declineBtAction(_ sender: AnyObject) {
        _ = [self.dismiss(animated: true, completion: {
           self.delegate.eulaPanelViewControllerDeclinedEULA()
        })]
    }
    
//MARK: - WebView Delegate functions
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
}
