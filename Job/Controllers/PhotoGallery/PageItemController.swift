//
//  PageItemController.swift
//  Paging_Swift
//
//  Created by olxios on 26/10/14.
//  Copyright (c) 2014 swiftiostutorials.com. All rights reserved.
//

import UIKit

class PageItemController: UIViewController, UIGestureRecognizerDelegate {
    
    var isBlackBG = false
    @IBOutlet weak var imgWbView: UIWebView!
    
    // MARK: - Variables
    var itemIndex: Int = 0
    var instanceId: String = ""
    var imageName: String = "" {
        
        didSet {
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imgWbView.backgroundColor = .black
        imgWbView.loadHTMLString("", baseURL: nil)
        
        if let dir = Utility.getPhotoParentDir(imgName: imageName, folderName: instanceId) {
            let path = dir.appendingPathComponent(imageName)
            let fullHTML = "<!DOCTYPE html>" +
                "<html lang=\"en\">" +
                "<head>" +
                "<meta charset=\"UTF-8\">" +
                "<style type=\"text/css\">" +
                "html{margin:0;padding:0;}" +
                "body {" +
                "margin: 0;" +
                "padding: 0;" +
                "color: #363636;" +
                "font-size: 90%;" +
                "line-height: 1.6;" +
                "background: black;" +
                "}" +
                "img{" +
                "position: absolute;" +
                "top: 0;" +
                "bottom: 0;" +
                "left: 0;" +
                "right: 0;" +
                "margin: auto;" +
                "max-width: 100%;" +
                "max-height: 100%;" +
                "}" +
                "</style>" +
                "</head>" +
                "<body id=\"page\">" +
            "<img style='height:100%; width: 100%; object-fit: contain' src='\(path)'/> </body></html>"
            
            imgWbView.loadHTMLString(fullHTML, baseURL: nil)
        }
        
        let touchGesture = UITapGestureRecognizer(target: self, action: #selector(showHideBottomToolBar))
        touchGesture.delegate = self
        imgWbView.addGestureRecognizer(touchGesture)
    }
    
    @objc func showHideBottomToolBar() {
        isBlackBG = !isBlackBG
        if isBlackBG {
            imgWbView.backgroundColor = .black
        } else {
            imgWbView.backgroundColor = .white
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:Constants.NotificationsName.IMAGE_WEBVIEW_TOUCHED_NOTIFY), object: nil)
    }
    
    // To recognize both touch event.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PageItemController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        return true
    }
}
