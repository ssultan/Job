//
//  BarcodeManualView.swift
//  Job V2
//
//  Created by Saleh Sultan on 2/7/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import QuartzCore

enum PopupWithTxbType {
    case BarcodeScanner
    case EmailHelp
}

let Insert_Barcode_Number = "INSERT BARCODE NUMBER"
let Enter_Phone_Number = "ENTER PHONE NUMBER"
let PopupTitle_Email_HelpDesk = "EMAIL MOBILE SUPPORT?"
let DoNot_ADD_PHONE = "DO NOT ADD PHONE NUMBER"
let EmailIcon = "EmailIcon"
let BarcodeIcon = "BarcodeSmIcon"
let NO_CODE = "No Code"

class BarcodeManualView: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var popUpView: UIView!
//    @IBOutlet weak var barCodetxb: UITextField!
    @IBOutlet weak var checkBoxNoBC: UIButton!
    @IBOutlet weak var userEntryBox: UITextField!
//    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var checkBoxLabel: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
//    @IBOutlet weak var acceptBtWidthConst: NSLayoutConstraint!
    @IBOutlet weak var closeBt: UIButton!
    @IBOutlet weak var acceptBt: UIButton!
    @IBOutlet weak var bottomConsDis: NSLayoutConstraint!
    @IBOutlet weak var titleImg: UIImageView!
    
    var onAcceptBlockFunc:(_ mBarCode:String,_ isChecked: Bool)->() = {_,_  in }
    var isChecked:Bool = false
    var currentPopupType: PopupWithTxbType!
    var keyBoardHeight:CGFloat = 0
    var isViewUp = false
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = UIScreen.main.bounds
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 10
        self.popUpView.clipsToBounds = true
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.userEntryBox.layer.cornerRadius = 6.0
        self.userEntryBox.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShowNotification(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        if currentPopupType == PopupWithTxbType.BarcodeScanner {
            userEntryBox.keyboardType = UIKeyboardType.alphabet
            titleImg.image = UIImage(named: BarcodeIcon)
        } else {
            userEntryBox.keyboardType = UIKeyboardType.phonePad
            titleImg.image = UIImage(named: EmailIcon)
        }
        self.userEntryBox.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    
    @objc func keyboardDidShowNotification(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyBoardHeight = keyboardRectangle.height + 130
            
            if !isViewUp {
                isViewUp = true
                self.animateUpIfKeyboardCovering();
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let screenheight = self.view.frame.size.height + 70
        if screenheight > self.popUpView.frame.size.height {
            //let difference = screenheight - self.popUpView.frame.size.height
            //bottomConsDis.constant = difference/2
        }
    }
    
    open func showInView(parentView aView: UIView!,
                         withTxbString txbStr:String,
                         //showCheckBox isShowingCKB: Bool,
                         popupType type: PopupWithTxbType,
                         continueBlock:@escaping (_ mBarCode:String, _ isChecked:Bool)->())
    {
        aView.addSubview(self.view)
        onAcceptBlockFunc = continueBlock
        userEntryBox.text = txbStr
        currentPopupType = type
        
        //Initially the checkbox would be unchecked. then based on below conditions we will deceide if we want to make the check box button checked or unchecked.
        isChecked = false
        checkBoxNoBC.setBackgroundImage(UIImage(named: "ChkBoxBlck"), for: .normal)
        
        // if the barcode text we received from the parent class is 'No Code', that means we we selected the checkbox before. Initially it would be empty string. that way we know that the previous manually typed values
        if txbStr == NO_CODE {
            isChecked = true
            checkBoxNoBC.setBackgroundImage(UIImage(named: "ChkBoxBlckSelected"), for: .normal)
        } else if txbStr == "" {
            userEntryBox.becomeFirstResponder()
        }
        
        if currentPopupType == PopupWithTxbType.BarcodeScanner {
            checkBoxLabel.text = NO_CODE
            titleLbl.text = StringConstants.ButtonTitles.TLT_BARCODE_NUMBER
            acceptBt.setTitle(StringConstants.ButtonTitles.BTN_PHOTO, for: .normal)
            userEntryBox.placeholder = Insert_Barcode_Number
            userEntryBox.keyboardType = UIKeyboardType.alphabet
            titleImg.image = UIImage(named: BarcodeIcon)
            
            // if the barcode text we received from the parent class is 'No Code', that means we we selected the checkbox before. Initially it would be empty string. that way we know that the previous manually typed values
            if txbStr == NO_CODE {
                isChecked = true
                checkBoxNoBC.setBackgroundImage(UIImage(named: "ChkBoxBlckSelected"), for: .normal)
            }
        } else {
            userEntryBox.placeholder = Enter_Phone_Number
            checkBoxLabel.text = DoNot_ADD_PHONE
            titleLbl.text = PopupTitle_Email_HelpDesk
            acceptBt.setTitle(StringConstants.ButtonTitles.BTN_EMAIL, for: .normal)
            userEntryBox.keyboardType = UIKeyboardType.phonePad
            titleImg.image = UIImage(named: EmailIcon)
        }
        self.showAnimate()
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
    
    
    //MARK: - Button Action
    @IBAction open func closePopup(_ sender: AnyObject) {
        self.removeAnimate()
        userEntryBox.resignFirstResponder()
    }
    
    @IBAction open func acceptBtPressed(_ sender: AnyObject) {
        self.removeAnimate()
        userEntryBox.resignFirstResponder()
        onAcceptBlockFunc(userEntryBox.text ?? "", isChecked)
    }
    
    @IBAction open func checkBtnAction() {
        isChecked = !isChecked
        if isChecked {
            userEntryBox.text = currentPopupType == .EmailHelp ? "" : NO_CODE
            userEntryBox.resignFirstResponder()
            checkBoxNoBC.setBackgroundImage(UIImage(named: "ChkBoxBlckSelected"), for: .normal)
        }
        else {
            userEntryBox.text = ""
            userEntryBox.becomeFirstResponder()
            checkBoxNoBC.setBackgroundImage(UIImage(named: "ChkBoxBlck"), for: .normal)
        }
    }

    
    //MARK: - Textbox delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if isChecked {
            return false
        }
        return true
    }
    
    func animateUpIfKeyboardCovering() {
        
        let maxHeight = popUpView.frame.size.height + popUpView.frame.origin.y + 44
        let keyboarPosition = self.view.frame.size.height - keyBoardHeight
        if keyboarPosition < maxHeight {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConsDis.constant = -(maxHeight - keyboarPosition)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if currentPopupType == .EmailHelp {
            var outputTxt = "\(textField.text ?? "")\(string)"
            if string == "" {
                outputTxt = String(outputTxt.dropLast())
            }
            
            outputTxt = outputTxt.replacingOccurrences(of: " ", with: "")
            if outputTxt != "" && outputTxt.isValidString(regEx: "^[0-9()-]+$") == false {
                return false
            }
            
            if let swRange = textField.text?.range(from: range) {
                let newString = textField.text?.replacingCharacters(in: swRange, with: string)
                let components = newString?.components(separatedBy: CharacterSet.decimalDigits.inverted)
                
                let decimalString = NSString(string: (components?.joined())!)
                let length = decimalString.length
                let hasLeadingOne = length > 0 && decimalString.character(at: 0) == 49
                
                if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                    let newLength = NSString(string: textField.text!).length + (string as NSString).length - range.length as Int
                    if (newLength > 10) { textField.layer.borderWidth = 0; return false; } else { return true }
                }
                var index = 0 as Int
                let formattedString = NSMutableString()
                
                
                // adding 1 before number.
                if hasLeadingOne {
                    if newString!.count > 1 && NSString(string: newString!).substring(to: 2) == "+1" {
                        formattedString.append("+1 ")
                    } else {
                        formattedString.append("1 ")
                    }
                    index += 1
                }
                if (length - index) > 3 {
                    let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                    formattedString.appendFormat("(%@) ", areaCode)
                    index += 3
                }
                if length - index > 3 {
                    let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                    formattedString.appendFormat("%@-", prefix)
                    index += 3
                }
                
                let remainder = decimalString.substring(from: index)
                formattedString.append(remainder)
                outputTxt = formattedString as String != "1 " ? formattedString as String : "1"
                textField.text =  outputTxt != "+1 " ? outputTxt as String : "+1"
            }
            return false
        }
        else {
            return true
        }
    }
}
