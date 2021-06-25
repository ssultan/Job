//
//  PDFViewerController.swift
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
//import Appsee
import JGProgressHUD

class PDFViewerController: UIViewController {

    @IBOutlet weak var pdfview: UIWebView!
    
    var loadingView: JGProgressHUD!
    var pdfURL:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.DOCUMENATION_PG_TLT
        
        //Appsee.addEvent("Loaded URL: \(pdfURL!)")
        let request = URLRequest(url: URL(string: pdfURL)!)
        pdfview.loadRequest(request)
        
        let doneBt = UIBarButtonItem.init(title: StringConstants.ButtonTitles.BTN_DONE, style: .done, target: self, action: #selector(doneButtonAction))
        self.navigationItem.rightBarButtonItem = doneBt
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button event
    @objc func doneButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    

    //MARK: - WebView Delegate functions
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.loadingView = JGProgressHUD(style: .extraLight)
        self.loadingView.textLabel.text = StringConstants.StatusMessages.LOADING
        self.loadingView.show(in: self.view, animated: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadingView.dismiss(animated: true)
    }

}
