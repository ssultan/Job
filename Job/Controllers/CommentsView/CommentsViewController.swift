//
//  CommentsViewController.swift
//  Job
//
//  Created by Saleh Sultan on 6/10/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class CommentCardCell: UITableViewCell {
    
    @IBOutlet weak var commentTitle: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        imgView.frame = self.frame
        self.backgroundView = imgView
        
        let selImgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        selImgView.frame = self.frame
        self.selectedBackgroundView = selImgView
        self.selectionStyle = .blue
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


class CommentsViewController: RootViewController, UITextViewDelegate {
    
    var keyToolbar: UIToolbar!
    var answerModel: AnswerModel!
    var commentsList = [CommentModel]()
    var comMaxCharLength: Int = 0
    
    @IBOutlet weak var commentTxtView: UITextView!
    @IBOutlet weak var maxLimitlbl: UILabel!
    @IBOutlet weak var commentPlaceHolder: UILabel!
    @IBOutlet weak var commentsTbList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.Comment_PAGE_TLT
        self.view.backgroundColor = .clear
        
        self.commentTxtView.layer.cornerRadius = 5.0
        self.commentTxtView.becomeFirstResponder()
        
        self.setupToolBar()
        self.commentTxtView.inputAccessoryView = self.keyToolbar
        self.navigationItem.hidesBackButton = true
        
        self.comMaxCharLength = answerModel == nil ? Constants.MAX_INST_COMMENT_CHAR_ALLOWED : Constants.MAX_ANS_COMMENT_CHAR_ALLOWED
        self.maxLimitlbl.text = "LIMIT: \(comMaxCharLength - self.commentTxtView.text.count) CHARACTERS"
        self.commentPlaceHolder.isHidden = self.commentTxtView.text.count == 0 ? false : true
        self.commentsList = (answerModel == nil ? AppInfo.sharedInstance.selJobInstance.comments : answerModel.comments)
        self.sortCommentList()
        
        self.commentsTbList.tableFooterView = UIView()
        self.commentsTbList.estimatedRowHeight = 150.0;
        self.commentsTbList.rowHeight = UITableView.automaticDimension;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Is view is moving to it's parent view which is a question page, then animate to top direction
        if isMovingFromParent {
            self.navigationController?.popViewController(animated: true, direction: .Top, callPopupVC: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupToolBar() {
        //init toolbar
        self.keyToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: StringConstants.ButtonTitles.BTN_DONE, style: .done, target: self, action: #selector(doneBtnInToolbarAction))
        
        //array of BarButtonItems
        var arr = [UIBarButtonItem]()
        arr.append(flexSpace)
        arr.append(doneBtn)
        
        self.keyToolbar.setItems(arr, animated: false)
        self.keyToolbar.sizeToFit()
    }
    
    
    //MARK: - Button action event
    @objc func doneBtnInToolbarAction() {
        self.view.endEditing(true)
    }
    
    
    @IBAction func doneNCloseBtnAction() {
        self.navigationController?.popViewController(animated: true, direction: .Top)
    }
    
    @IBAction func saveBtnAction() {
        if let commentTxt = self.commentTxtView.text {
            if commentTxt.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) != "" {
                if let commentObj = getCommentObject(commentTxt: commentTxt) {
                    self.commentTxtView.text = ""
                    self.textViewDidChange(self.commentTxtView)
                    self.commentsList.append(commentObj)
                    self.sortCommentList()
                    if answerModel == nil {
                        AppInfo.sharedInstance.selJobInstance.comments.append(commentObj)
                    } else {
                        self.answerModel.comments.append(commentObj)
                    }
                    self.commentsTbList.reloadData()
                }
            }
        }
    }
    
    func sortCommentList() {
        self.commentsList.sort(by: { (($0.createdDate?.compare(($1.createdDate as Date?)!)) == .orderedDescending) })
    }
    
    func getCommentObject(commentTxt: String) -> CommentModel?{
        let comment = CommentModel()
        comment.commentId = UUID().uuidString
        comment.commentText = commentTxt
        comment.createdBy = AppInfo.sharedInstance.username!
        comment.createdDate = NSDate()
        guard let commentObj = JobServices.saveComment(commentObj: comment, ansModel: self.answerModel) else { return nil }
        return commentObj
    }
    
    // MARK: - TextView Delegate functions
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if text != "", let existingTxt = textView.text {
            let outputTxt = "\(existingTxt)\(text)"
            if outputTxt.count > comMaxCharLength {
                return false
            }
        }
        
        return true
    }
    
    @objc func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text.count == 1 && textView.text == "\n" {
            textView.text = ""
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 1 && textView.text == "\n" {
            textView.text = ""
        }
        
        self.maxLimitlbl.text = "LIMIT: \(comMaxCharLength - textView.text.count) CHARACTERS"
        self.commentPlaceHolder.isHidden = self.commentTxtView.text.count == 0 ? false : true
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCardCell", for: indexPath) as! CommentCardCell
        cell.commentTitle.text = "\(commentsList[indexPath.row].createdBy!) - \(commentsList[indexPath.row].createdDate!.convertToString(format: "MM/dd/yyyy hh:mm a"))"
        cell.comment.text = commentsList[indexPath.row].commentText ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
