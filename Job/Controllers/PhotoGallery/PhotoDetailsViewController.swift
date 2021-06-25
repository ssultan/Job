//
//  PhotoDetailsViewController.swift
//  Job V2
//
//  Created by Saleh Sultan on 12/19/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var commentTxtV: UITextView!
    @IBOutlet weak var bgPhotoView: UIImageView!
    @IBOutlet weak var imgNameField: UITextField!
    @IBOutlet weak var tagTxtField: UITextField!
    @IBOutlet weak var attCollectionView: UICollectionView!
    @IBOutlet weak var commentPlaceHolder: UILabel!
    
    var imageTypeList = PhotoAttributesTypes.allValues
    @objc var document: DocumentModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = StringConstants.PageTitles.PHOTO_DETAILS_PAGE_TLT
        bgPhotoView.image = Utility.getImageFromDocumentDirectory(docName: document.originalName!, folderName: document.instanceId ?? "")
        
        
        // Make the comment view text view border curve and set the text. If the text is empty, then change then color to gray and put a text polder text 'Comment'. Once user start typing text, system will change the color to black and will remove custom place holder text 'Comment'. If removed all text then automatically it will show the text 'Comment'
        commentTxtV.layer.cornerRadius = 5.0
        commentTxtV.clipsToBounds = true
        let comment = document.comment ?? ""
        if comment != "" {
            commentTxtV.text = comment
            commentTxtV.textColor = .black
            commentPlaceHolder.isHidden = true
        } else {
            commentPlaceHolder.isHidden = false
        }
        
        imgNameField.text = document.name
        tagTxtField.text = document.docTags
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 144, height: 30)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = self.view.frame.size.width == 320 ? 0 : 20;
        flowLayout.minimumLineSpacing = self.view.frame.size.width == 320 ? 5 : 30 ;
        attCollectionView.collectionViewLayout = flowLayout
        
        self.imgNameField.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.imgNameField.placeholder = "PHOTO NAME"
        self.tagTxtField.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.tagTxtField.placeholder = "TAGS"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeKeyboards(){
        imgNameField.resignFirstResponder()
        commentTxtV.resignFirstResponder()
        tagTxtField.resignFirstResponder()
    }
    

    @IBAction func doneBtnAction() {
        closeKeyboards()
        document.name = imgNameField.text ?? ""
        document.comment = commentTxtV.text ?? ""
        document.docTags = tagTxtField.text ?? ""
        document.isNeedToSend = NSNumber(value: true)
        JobServices.updateDocument(document: document)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnAction() {
        self.dismiss(animated: true, completion: nil)
    }
}


extension PhotoDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageTypeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if document.attribute! != PhotoAttributesTypes.FieldVisit.rawValue {
            document.attribute = imageTypeList[indexPath.row].rawValue
            document.attributeId = imageTypeList[indexPath.row].getAttributeId()
        }// From next version we will use 'photoAttrType'
        
        let attrIdx = document.name!.findPhotoAttrIdx()
        let photoComps = document.name!.components(separatedBy: "_")
        if attrIdx != -1 && photoComps.count > attrIdx {
            let currAttShortForm = photoComps[attrIdx]
            self.updateDocumentNameForAttribute(oldAttr: currAttShortForm, newAttr: imageTypeList[indexPath.row])
            collectionView.reloadData()
        }
    }
    
    fileprivate func getToggleImage(forRow row: Int) -> UIImage? {
        if let docName = document.name {
            let attrIdx = docName.findPhotoAttrIdx()
            let photoComps = document.name!.components(separatedBy: "_")
            
            if attrIdx != -1 && photoComps.count > attrIdx {
                let curAttShot = photoComps[attrIdx]
                let currAttShortForm = curAttShot.getAttributeNameByShotForm()
                
                if currAttShortForm == imageTypeList[row] {
                    return UIImage(named: "ToggleChecked")
                } else {
                    return UIImage(named: "ToggleUnchecked")
                }
            }
        }
        return UIImage(named: "ToggleUnchecked")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgTypeItemCell", for: indexPath) as! ImgTypeColViewCell
        cell.typeName.text = imageTypeList[indexPath.row].rawValue
        cell.checkMarkImgV.image = getToggleImage(forRow: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func updateDocumentNameForAttribute(oldAttr: String, newAttr: PhotoAttributesTypes) {
        let shortForm = newAttr.attributeShortForm()
        
        let newDocName = document.name?.replacingOccurrences(of: oldAttr, with: shortForm)
        document.name = newDocName
        imgNameField.text = newDocName
    }
}

extension PhotoDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            textField.text = textField.text?.components(separatedBy: ".")[0]
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            if let nameTxt = textField.text {
                if (nameTxt == "") {
                    textField.text = document.name
                } else {
                    textField.text = "\(nameTxt).jpeg"
                }
            }
            //commentTxtV.becomeFirstResponder()
        }
    }
}


extension PhotoDetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            if text == "\n" {
                textView.text = ""
            }
        }
        
        if textView.text == "" {
            commentPlaceHolder.isHidden = false
        } else {
            commentPlaceHolder.isHidden = true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            //tagTxtField.becomeFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            commentPlaceHolder.isHidden = false
        } else {
            commentPlaceHolder.isHidden = true
        }
    }
}
