//
//  CompIncompViewController.swift
//  Job V2
//
//  Created by Saleh Sultan on 06/1/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//


// This viewController is responsible for showing all the survey instance, which is in complete state or implemente state.

import UIKit
import JGProgressHUD
import Speech


protocol CompIncompViewProtocal {
    func updateSelectedArrayItem(forIndex index: Int)
}


class CompIncompViewController: RootViewController {

    var isCheckedAll = false
    var isCompleteInstance: Bool = false      // Based on this flag, we will deceide that we are going to show Incomplete Survey or Complete Survey.
    var instanceArray =  [JobInstanceModel]() // This array will contain the list of instance that is not being completed yet or Completed
    var checkTrackerArray = [Bool]()
    var popupView : PopupWTxbInputView!
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var selAllBtn: UIButton!
    @IBOutlet weak var selAllMainBtn: UIButton!
    @IBOutlet weak var noFieldVistlbl: UILabel!
    @IBOutlet weak var instanceTBView: UITableView!
    @IBOutlet weak var sendImgIcon: UIImageView!
    
    var loadingView: JGProgressHUD = JGProgressHUD(style: .extraLight)
    var mainMenuDelegate: MainMenuViewProtocal!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavRightBarItem()
        
        self.instanceTBView.tableFooterView = UIView()
        self.instanceTBView.estimatedRowHeight = 70.0;
        self.instanceTBView.rowHeight = UITableView.automaticDimension;
        self.title = isCompleteInstance ? StringConstants.PageTitles.COMPLETE_JOB_PAGE_TLT : StringConstants.PageTitles.INCOMPLETE_JOB_PAGE_TLT

        self.loadingView.textLabel.text = StringConstants.StatusMessages.PLEASE_WAIT_MSG
        self.loadingView.show(in: self.view, animated: true)
        self.loadJobInstances()
        
        if self.popupView == nil {
            self.popupView = self.storyboard?.instantiateViewController(withIdentifier: "PopupWTxbInputV") as? PopupWTxbInputView
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadJobInstances(){
        JobServices.loadJobInstance(completion: { (instanceList) in
            self.loadingView.dismiss()
            instanceArray = instanceList
            self.instanceTBView.reloadData()
            
            if instanceArray.count == 0 {
                self.noInstancesAvailable()
            } else {
                checkTrackerArray = [Bool]( repeating: false, count: instanceArray.count )
            }
        })
    }
    
    fileprivate func noInstancesAvailable() {
        selAllBtn.isHidden = true
        selAllMainBtn.isHidden = true
        noFieldVistlbl.isHidden = false
        noFieldVistlbl.text = isCompleteInstance ? "You have no completed surveys" : "You have no incompleted surveys"
        sendBtn.isHidden = true
        sendImgIcon.isHidden = true
    }
    
    fileprivate func updateSendBtnTitle() {
        var isCheckedAnyInstance = false
        for item in checkTrackerArray {
            if item {
                isCheckedAnyInstance = true
                break
            }
        }
        
        if isCheckedAnyInstance {
            sendBtn.setTitle(StringConstants.ButtonTitles.BTN_SEND, for: .normal)
        } else {
            sendBtn.setTitle(StringConstants.ButtonTitles.BTN_SEND_ALL, for: .normal)
        }
    }
    
    func checkUncheckBtn(sender: UIButton, isChecked: Bool) {
        if isChecked {
            sender.setBackgroundImage(UIImage(named: "CheckBoxSelected"), for: .normal)
        } else {
            sender.setBackgroundImage(UIImage(named: "CheckBoxUnSelected"), for: .normal)
        }
        
        updateSendBtnTitle()
    }

    @IBAction func checkAllBtnAction() {
        //Appsee.addScreenAction(isCheckedAll ? StringConstants.AppseeScreenAction.SELECT_ALL_CHECKED : StringConstants.AppseeScreenAction.UNSELECT_ALL_CHECKED)
        isCheckedAll = !isCheckedAll
        checkUncheckBtn(sender: selAllBtn, isChecked: isCheckedAll)
        
        if isCheckedAll {
            checkTrackerArray = [Bool]( repeating: true, count: instanceArray.count )
        } else {
            checkTrackerArray = [Bool]( repeating: false, count: instanceArray.count )
        }
        instanceTBView.reloadData()
    }

    @IBAction func checkBtnAction(sender: AnyObject) {
        if let btnTag = sender.tag {
            let isSelected = checkTrackerArray[btnTag]
            checkTrackerArray[btnTag] = !isSelected
            checkUncheckBtn(sender: sender as! UIButton, isChecked: checkTrackerArray[btnTag])
        }
    }
    
    @IBAction func sendBtnAction() {
        let isAnyInstSelected = updateSelectedInstances()
        if !isAnyInstSelected {
            return
        }
        
        self.loadingView = JGProgressHUD(style: .extraLight)
        self.loadingView.textLabel.text = StringConstants.StatusMessages.Sending_Job_Status_Msg
        self.loadingView.show(in: self.view, animated: true)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            self.loadingView.dismiss(animated: true)
            
            // Uncheck all surveys. That's why I made 'isCheckedAll' boolean variable to true. This way system will consider that all the surveys are selected and system will uncheck all the checkbox
            self.isCheckedAll = true
            self.checkAllBtnAction()
            
            if self.instanceArray.count == 0 {
                self.noInstancesAvailable()
            }
//
//            DispatchQueue.main.async {
//                // For Completed instances only, take users to the Transmit report page.
//                if isAnyInstSelected {
//                    self.navigationController?.popViewController(animated: false)
//
//                    let objInfo:[String: Bool] = ["isCompleteNSend": false]
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.OPEN_SENT_REPORTS), object: nil, userInfo: objInfo)
//                }
//            }
        }
    }
    
    fileprivate func updateSelectedInstances() -> Bool {
        var isAnyInstSelected = false
        
        for i in 0..<instanceArray.count {
            let instance = instanceArray[i]
            
            if checkTrackerArray[i] {
                if instance.template == nil || instance.location == nil {
                    continue
                }
                
                isAnyInstSelected = true
                instance.isSentForProcessing = true
                instance.isSentOrUpdated = true
                instance.instanceSentTime = NSDate()
                instance.status = StringConstants.StatusMessages.InQueue
                
//                // If the instance is in completed section, then remove the instance from page.
//                if (isCompleteInstance) {
//                    instance.isCompleteNSend = NSNumber(value: true)
//                }
                JobServices.updateJobInstance(jobInstance: instance)
            }
        }
        return isAnyInstSelected
    }
    
    fileprivate func getNotSelectedInstances() -> [JobInstanceModel]{
        var tempInstArray = [JobInstanceModel]()
        
        for i in 0..<instanceArray.count {
            if !checkTrackerArray[i] {
                tempInstArray.append(instanceArray[i])
            }
        }
        return tempInstArray
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = instanceTBView.indexPathForSelectedRow else {return}
        instanceTBView.deselectRow(at: indexPath, animated: true)

        let instance = instanceArray[indexPath.row]
        AppInfo.sharedInstance.selJobInstance = instance
        //Appsee.addScreenAction("'\(instance.template.templateName ?? "XXX")', Loc #\(instance.location.storeNumber ?? "XXX") Selected")

        let jobInfo = segue.destination as! JobVisitInfoViewController
        jobInfo.instance = instance
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let indexPath = instanceTBView.indexPathForSelectedRow else {return false}
        let instance = instanceArray[indexPath.row]
        if instance.template == nil {
            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage:StringConstants.StatusMessages.Job_Not_Assigned_Msg, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil, animated: true, isMessage: false)
            return false
        } else if instance.location == nil {
            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage:"Store #\(instance.storeNumber ?? "") is inactive. Please contact to your project manager.", withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil, animated: true, isMessage: false)
            return false
        }
        return true
    }
}


extension CompIncompViewController: CompIncompViewProtocal {
    func updateSelectedArrayItem(forIndex index: Int) {
        self.instanceArray[index] = AppInfo.sharedInstance.selJobInstance
        
        DispatchQueue.main.async {
            self.instanceTBView.reloadData()
        }
        
        if self.mainMenuDelegate != nil {
            //self.mainMenuDelegate.updateSelectedArrayItem(forIndex: index, isComplete: isCompleteInstance, withInstance: self.instanceArray[index])
        }
    }
}

extension CompIncompViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instanceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComIncomTBCellIdentifier", for: indexPath) as! CompIncompTBViewCell
        cell.updateCell(instance: instanceArray[indexPath.row])
        cell.checkBoxBt.tag = indexPath.row
        cell.checkBoxBt.addTarget(self, action: #selector(checkBtnAction(sender:)), for: .touchUpInside)
        cell.checkBoxBt.setBackgroundImage(UIImage(named: checkTrackerArray[indexPath.row] ? "CheckBoxSelected" : "CheckBoxUnSelected"), for: .normal)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longGesture.minimumPressDuration = 5.0
        longGesture.allowableMovement = 100.0
        cell.addGestureRecognizer(longGesture)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        instanceTBView.deselectRow(at: indexPath, animated: true)
//
//        let instance = instanceArray[indexPath.row]
//        AppInfo.sharedInstance.selJobInstance = instance
//        //Appsee.addScreenAction("'\(instance.template.templateName ?? "XXX")', Loc #\(instance.location.storeNumber ?? "XXX") Selected")
//
//
//        let jobInfo = self.storyboard?.instantiateViewController(withIdentifier: "JobVisitInfoVC") as! JobVisitInfoViewController
//        jobInfo.instance = instance
//        self.navigationController?.pushViewController(jobInfo, animated: true)
//    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            self.popupView.showInView(parentView: self.view, withTxbString: "", popupType: PopupWithTxbType.DeleteIntance)
            { (deleteTxt, isChecked) in
                if (deleteTxt == StringConstants.ButtonTitles.BTN_DELETE){
                    let tapLocation = recognizer.location(in: self.instanceTBView)
                    if let tapIndexPath = self.instanceTBView.indexPathForRow(at: tapLocation) {
                        if let tappedCell = self.instanceTBView.cellForRow(at: tapIndexPath) as? CompIncompTBViewCell {
                            print("Delete instruction Received: ", tappedCell)
                            
                            let instance = self.instanceArray[tapIndexPath.row]
                            DBJobInstanceServices.markInstanceAsDeleted(forInstId: instance.instId!)
                            self.loadJobInstances()
                        }
                    }
                }
            }
        }
    }
}
