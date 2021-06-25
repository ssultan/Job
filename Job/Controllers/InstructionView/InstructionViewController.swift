//
//  InstructionViewController.swift
//  Job V2
//
//  Created by Saleh Sultan on 3/2/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import QuartzCore

public enum InstructionType {
    case Text
    case PDF
    case Image
}

@objc open class InstructionViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var instrWebView: UIWebView!
    
    var onCloseBlockFunc:()->() = {}
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 10
        self.popUpView.clipsToBounds = true
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.frame.size = UIScreen.main.bounds.size
    }


    open func showInView(_ aView: UIView!, withInstruction message: String!, withInstructTitle title:String, withInstructionType insType:InstructionType = .Text, animated: Bool, closeBlock:@escaping ()->() = {})
    {
        aView.addSubview(self.view)
        onCloseBlockFunc = closeBlock
        let bodyMsg = message.replacingOccurrences(of: "\n", with: "<br/>")
        self.titlelbl.text = title
        var htmlBody = ""
        
        switch insType {
        case .PDF:
            break
            
        case .Image:
            //htmlBody = "<img src='\()'/>"
            break
            
        default:
            htmlBody = "<div>\(bodyMsg)</div>"
            break
        }
        
        let fullHTML = "<!DOCTYPE html>" +
            "<html lang=\"en\">" +
            "<head>" +
                "<meta charset=\"UTF-8\">" +
                "<style type=\"text/css\">" +
                    "html{margin:20px;padding:20px;}" +
                    "body {" +
                        "margin: 0px;" +
                        "padding: 0px;" +
                        "color: black;" +
                        "font-size: 55px;" +
                        "line-height: 1.6;" +
                        "text-align:justify;" +
                        "font-family:'System';" +
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
                "\(htmlBody)" +
            "</body></html>"
        
        
        self.instrWebView.loadHTMLString(fullHTML, baseURL: nil)
        if animated{
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
    @IBAction open func closePopup(_ sender: AnyObject) {
        self.removeAnimate()
        self.onCloseBlockFunc()
    }
}
