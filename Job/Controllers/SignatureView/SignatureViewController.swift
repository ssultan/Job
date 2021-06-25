//
//  SignatureViewController.swift
//  Job V2
//
//  Created by Saleh Sultan on 11/1/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import EPSignature

let MAX_SIGNATURE_COMMENT_LIMIT = 500
class SignatureViewController: RootViewController, UITextFieldDelegate, UITextViewDelegate {

    var signatureImg: UIImage!
    var signName: String = ""
    var signTitle: String = ""
    var signComment: String = ""
    var signatureModel: DocumentModel!
    var isKeyboardShowing: Bool = false
    var isSignUpdated: Bool = false
    var keyToolbar: UIToolbar!
    var keyBoardHeight:CGFloat = 0
    var viewMoved: CGFloat = 0.0
    var currentKeyView: UIView!
    
    @IBOutlet weak var signatureImgV: UIImageView!
    @IBOutlet weak var commentsTxtVie: UITextView!
    @IBOutlet weak var nameTxtFi: UITextField!
    @IBOutlet weak var titleTxtFi: UITextField!
    @IBOutlet weak var maxLimitlbl: UILabel!
    @IBOutlet weak var commentPlaceHolderlbl: UILabel!
    @IBOutlet weak var signLandscapeHeight: NSLayoutConstraint!
    @IBOutlet weak var signPortraitHeight: NSLayoutConstraint!
    @IBOutlet weak var commentBoxHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.SIGN_PAGE_TLT
        self.setNavRightBarItem()
        
        self.signatureImgV.image = signatureImg
        self.signatureImgV.layer.cornerRadius = 5.0
        self.signatureImgV.clipsToBounds = true
        
        self.commentsTxtVie.layer.cornerRadius = 5.0
        self.commentsTxtVie.clipsToBounds = true
        
        nameTxtFi.text = signName.replacingOccurrences(of: ".jpeg", with: "")
        titleTxtFi.text = signTitle
        commentsTxtVie.text = signComment
        maxLimitlbl.text = "LIMIT: \(MAX_SIGNATURE_COMMENT_LIMIT - commentsTxtVie.text.count) CHARACTERS"
        commentPlaceHolderlbl.isHidden = commentsTxtVie.text.count == 0 ? false : true
        
        //setting toolbar as inputAccessoryView
        self.setupToolBar()
        self.nameTxtFi.inputAccessoryView = self.keyToolbar
        self.titleTxtFi.inputAccessoryView = self.keyToolbar
        self.commentsTxtVie.inputAccessoryView = self.keyToolbar
        
        self.nameTxtFi.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.nameTxtFi.placeholder = "NAME"
        self.titleTxtFi.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.titleTxtFi.placeholder = "TITLE"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.supportLandscape = false
                appDelegate.shouldRotate = false
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShowNotification(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideAllKeyboards(recognizer: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShowNotification(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyBoardHeight = keyboardRectangle.height
            self.animateUpIfKeyboardCovering(txtView: currentKeyView);
        }
    }

    func animateUpIfKeyboardCovering(txtView: UIView?) {

        guard let txtField = txtView else {
            return
        }
        let viewHeight = txtField.isKind(of: UITextView.self) ? txtField.frame.size.height/3 : txtField.frame.size.height
        let maxHeight = viewHeight + txtField.frame.origin.y
        let keyboarPosition = self.view.frame.size.height - keyBoardHeight

        if keyboarPosition < maxHeight && !isKeyboardShowing {
            isKeyboardShowing = true
            UIView.animate(withDuration: 0.4, animations: {
                self.viewMoved = -(maxHeight - keyboarPosition)
                self.view.frame.origin.y = self.viewMoved
                self.view.layoutIfNeeded()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIDevice.current.orientation.isLandscape {
            signPortraitHeight.isActive = false
            signLandscapeHeight.isActive = true
        } else {
            signPortraitHeight.isActive = true
            signLandscapeHeight.isActive = false
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            commentBoxHeight.constant = -40
        } else {
            commentBoxHeight.constant = 0
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        keyboardWillHide()
    }
    
    func setupToolBar() {
        self.keyToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: StringConstants.ButtonTitles.BTN_DONE, style: .done, target: self, action: #selector(doneBtnAction))
        
        //array of BarButtonItems
        var arr = [UIBarButtonItem]()
        arr.append(flexSpace)
        arr.append(doneBtn)
        
        self.keyToolbar.setItems(arr, animated: false)
        self.keyToolbar.sizeToFit()
    }
    
    //MARK: - Button action event
    @objc func doneBtnAction() {
        self.titleTxtFi.resignFirstResponder()
        self.nameTxtFi.resignFirstResponder()
        self.commentsTxtVie.resignFirstResponder()
    }
    
    @objc func keyboardWillHide() {
        if isKeyboardShowing == true {
            isKeyboardShowing = false
            UIView.animate(withDuration: 0.4, delay: 0, options: .allowAnimatedContent, animations: {
                let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
                    (self.navigationController?.navigationBar.frame.height ?? 0.0)
                self.view.frame.origin.y += -(self.viewMoved - topBarHeight)
            }, completion: nil)
        }
    }
    
    //MARK:- Button Event Action
    @IBAction func clearBtnAction() {
        self.signatureImgV.image = nil
        self.nameTxtFi.text = ""
        self.titleTxtFi.text = ""
        self.commentsTxtVie.text = ""
    }
    
    @IBAction func saveBtnAction() {
        if (nameTxtFi.text != "" && nameTxtFi.text != nil), let signImg = self.signatureImgV.image {
            signatureModel = JobServices.saveUpdateSignature(image: signImg, documentObj: getDocumentObject(), isUpdatingSign: self.isSignUpdated)
            _ = self.navigationController?.popViewController(animated: true)
        }
        else if (self.signatureImgV.image != nil && nameTxtFi.text == ""){
            Utility.showCustomMsg(self.view, label: StringConstants.ButtonTitles.TLT_Warning, detailslbl: StringConstants.StatusMessages.Signature_Name_Required_Msg, isSuccessImg: false, duration:2,  completion: { })
        }
        else if self.signatureImgV.image == nil, let signMo = signatureModel {
            if signMo.deleteDocument() {
                AppInfo.sharedInstance.selJobInstance.removeDocumentFromInst(documentId: signatureModel.documentId!)
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    fileprivate func getDocumentObject() -> DocumentModel {
        let instance = JobServices.createInstanceObjectIfNotAvilable()
        let photoName = "\(nameTxtFi.text!).jpeg"
        
        let curDocument = DocumentModel()
        curDocument.attribute = titleTxtFi.text ?? ""
        curDocument.attributeId = String(PhotoAttributesTypes.Signature.getAttributeId())
        curDocument.photoAttrType = PhotoAttributesTypes.Signature.rawValue
        curDocument.mimeType = Constants.ImageMimeType
        curDocument.type =  Constants.DocSignatureType
        curDocument.name = photoName
        curDocument.originalName = photoName
        curDocument.comment = commentsTxtVie.text ?? ""
        curDocument.createdDate = NSDate()
        curDocument.instanceId = instance.instId
        curDocument.isSent = NSNumber(value: false)
        curDocument.isNeedToSend = NSNumber(value: true)
        curDocument.isPhotoDeleted = NSNumber(value: false)
        return curDocument
    }
    
    @IBAction func signImgViewPressed(recognizer: UITapGestureRecognizer) {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.SIGNATURE_FRAME_CLICKED)
        lastOrientation = UIApplication.shared.statusBarOrientation
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.supportLandscape = true
            appDelegate.shouldRotate = false
        }
        
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
        signatureVC.title = StringConstants.PageTitles.SIGN_PAGE_TLT
        signatureVC.showsSaveSignatureOption = false
        signatureVC.showsDate = false
        signatureVC.tintColor = UIColor.white
        let nav = UINavigationController(rootViewController: signatureVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func hideAllKeyboards(recognizer: UITapGestureRecognizer?) {
        nameTxtFi.resignFirstResponder()
        titleTxtFi.resignFirstResponder()
        commentsTxtVie.resignFirstResponder()
    }
    
    // MARK: - TextView Delegate functions
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if text != "", let existingTxt = textView.text {
            let outputTxt = "\(existingTxt)\(text)"
            if outputTxt.count > MAX_SIGNATURE_COMMENT_LIMIT {
                return false
            }
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text.count == 1 && textView.text == "\n" {
            textView.text = ""
        }
        
        currentKeyView = textView
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isKeyboardShowing { animateUpIfKeyboardCovering(txtView: textView) }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 1 && textView.text == "\n" {
            textView.text = ""
        }
        
        maxLimitlbl.text = "LIMIT: \(MAX_SIGNATURE_COMMENT_LIMIT - textView.text.count) CHARACTERS"
        commentPlaceHolderlbl.isHidden = commentsTxtVie.text.count == 0 ? false : true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentKeyView = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isKeyboardShowing { animateUpIfKeyboardCovering(txtView: textField) }
    }
}

extension SignatureViewController : EPSignatureDelegate {
    
    //Mark: - EPSignatureDelegat functions
    func epSignature(_: EPSignatureViewController, didCancel error : NSError) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.shouldRotate = true
        }
        
        if lastOrientation == UIInterfaceOrientation.portrait {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    func epSignature(_: EPSignatureViewController, didSign signatureImage : UIImage, boundingRect: CGRect) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.shouldRotate = true
        }
        
        self.signatureImgV.image = signatureImage
        self.signatureImg = signatureImage
        self.isSignUpdated = true
        
        if lastOrientation == UIInterfaceOrientation.portrait {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
}
