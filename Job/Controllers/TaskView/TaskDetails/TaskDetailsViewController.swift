//
//  TaskDetailsViewController.swift
//  Job
//
//  Created by Saleh Sultan on 7/3/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0


@objc protocol TaskDetailsDelegate {
    func triggerCompletedDate()
}
var DATE_FORMAT = "MMMM dd, yyyy hh:mm a"
var LOWEST_ACCURACY_ALLOWED = 20
class TaskDetailsViewController: ParentTaskView, TaskDetailsDelegate {
    
    //MARK: - Veriables
    @IBOutlet weak var startDateTxb: UITextField!
    @IBOutlet weak var completeDatetxb: UITextField!
    @IBOutlet weak var percentTxb: UITextField!
    @IBOutlet weak var ckBoxStart: UIButton!
    @IBOutlet weak var ckBoxComplete: UIButton!
    @IBOutlet weak var sliderView: StepSlider!
    @IBOutlet weak var sliderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ckBoxNA: UIButton!
    @IBOutlet weak var nalbl: UILabel!
    
    var isStarted = false
    var isFinished = false
    var accuracy: Int = 100
    var MaxValue = 100
    var slideMaxIdx:UInt = 5
    var isSliderLoadFirst = true
    var triggerForTakePhoto = false
    var popViewController : PopUpViewControllerSwift!
    var isAnswerChanged = false
    var isNASelected = false
    
    //MARK: - View life Cycles
    override func initFun (jobVisitInfo: JobVisitModel, delegate: TaskViewDelegate) {
        super.initFun(jobVisitInfo: jobVisitInfo, delegate: delegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopUpVC") as? PopUpViewControllerSwift
        
        let taskAccuracy = Int(truncating: self.jobVisit.task!.accuracy)
        if taskAccuracy > 0 && taskAccuracy < 100 {
            self.accuracy = taskAccuracy < LOWEST_ACCURACY_ALLOWED ? LOWEST_ACCURACY_ALLOWED : taskAccuracy // Not allowing to go below 20% accuracy
        }
        self.slideMaxIdx = UInt(MaxValue/accuracy + 1)
        self.setupSlider()
        
        self.updateFields()
        self.viewSetup()
        if let answer = self.jobVisit.answer {
            if answer.value ?? "" == "na"  || answer.value ?? "" == "N/A" {
                ckBoxNA.setBackgroundImage(UIImage(named: "CheckBoxSelected"), for: .normal)
                isNASelected = true
                
                self.isStarted = false
                self.isFinished = false
                self.updateJobStart()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let task = jobVisit.task, let answer = jobVisit.answer {
            let origAnsChanged = answer.isAnsChanged
            let origAnsVal = answer.value!
            let origAnsStDate = answer.startDate
            let origAnsEdDate = answer.endDate
            
            var taskCompleted = false
            answer.startDate = getDateFromTxb(txb: startDateTxb)
            answer.endDate = getDateFromTxb(txb: completeDatetxb)
            
            if isNASelected {
                answer.value = "na"
                taskCompleted = true
            }
            else {
                if let answerStr = percentTxb.text {
                    if Int(truncating: task.required ?? 0) == 1 && isFinished {
                        taskCompleted = true
                        if Int(truncating: task.photoRequired ?? 0) == 1 && answer.ansDocuments.count == 0 { taskCompleted = false }
                    }
                    else if isFinished {
                        if Bool(truncating: task.photoRequired ?? 0) && answer.ansDocuments.count == 0 { taskCompleted = false}
                        else { taskCompleted = true }
                    }
                    answer.value = answerStr.components(separatedBy: "%")[0]
                }
                else { answer.value = "0" }
            }
            
            answer.isAnswerCompleted = NSNumber(value: taskCompleted)
            answer.isAnsChanged = origAnsChanged ? true : self.checkIfAnswerChanged(updatedAns: answer, withVal: origAnsVal, withStartDate: origAnsStDate, withEndDate: origAnsEdDate) // if Already marked as changed, then no need to test it
            self.parentQDelegate.answerFromChild(answer: answer)
        }
        
        super.viewWillDisappear(animated)
    }
    
    fileprivate func checkIfAnswerChanged(updatedAns: AnswerModel, withVal value: String, withStartDate stDate:NSDate?, withEndDate edDate:NSDate?) -> Bool {
        if value != updatedAns.value {
            print("old value: \(String(describing: value)) Vs New Answer: \(String(describing: updatedAns.value))")
            return true
        } else if stDate?.convertToString(format: Constants.SERVER_EXP_DATE_FORMATE) != updatedAns.startDate?.convertToString(format: Constants.SERVER_EXP_DATE_FORMATE) {
            print("old value: \(String(describing: stDate)) Vs New Answer: \(String(describing: updatedAns.startDate))")
            return true
        } else if edDate?.convertToString(format: Constants.SERVER_EXP_DATE_FORMATE) != updatedAns.endDate?.convertToString(format: Constants.SERVER_EXP_DATE_FORMATE) {
            print("old value: \(String(describing: edDate)) Vs New Answer: \(String(describing: updatedAns.endDate))")
            return true
        }
        return false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if (self.accuracy == 100) {
            self.sliderViewHeight.constant = 0
            self.sliderView.isHidden = true
            self.percentTxb.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFinished && (self.jobVisit.task.photoRequired ?? 0).boolValue && self.jobVisit.answer.ansDocuments.count == 0 {
            isFinished = false
            updateCompleteJob()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isSliderLoadFirst = false
    }
    
    
    fileprivate func viewSetup() {
        self.startDateTxb.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.completeDatetxb.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.percentTxb.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.startDateTxb.placeholder = "Month DD, yyyy  hh:mm a"
        self.completeDatetxb.placeholder = "Month DD, yyyy  hh:mm a"
    }
    
    fileprivate func updateFields() {
        if let answer = self.jobVisit.answer, let task = self.jobVisit.task {
            if let startDate = answer.startDate {
                isStarted = true
                ckBoxStart.setBackgroundImage(UIImage(named: "CheckBoxSelected"), for: .normal)
                self.startDateTxb.text = Utility.stringFromDate(date: startDate as Date, format: DATE_FORMAT)
            }
            if let endDate = answer.endDate {
                isFinished = true
                ckBoxComplete.setBackgroundImage(UIImage(named: "CheckBoxSelected"), for: .normal)
                self.completeDatetxb.text = Utility.stringFromDate(date: endDate as Date, format: DATE_FORMAT)
            }
            
            if Bool(truncating: task.allowNA ?? 0) {
                ckBoxNA.isHidden = false
                nalbl.isHidden = false
            }
        }
    }
    
    fileprivate func setupSlider() {
        self.sliderView.maxCount = slideMaxIdx
        if let answer = self.jobVisit.answer {
            if var value = Int(answer.value ?? "0") {
                self.sliderView.index = UInt(value/accuracy)
                if UInt(value/accuracy) == 0 && value > 0 { value = 0 }
                self.percentTxb.text = "\(value)%"
            }
            else { self.sliderView.index = 0 }
        }
        
        var labels = [String]()
        for i in 0..<slideMaxIdx {
            labels.append(String(Int(i) * accuracy))
        }
        self.sliderView.labels = labels
    }
    
    fileprivate func getDateFromTxb(txb: UITextField) -> NSDate? {
        if let sDateStr = txb.text {
            if sDateStr != "" {
                return Utility.dateFromString(dateStr: sDateStr, format: DATE_FORMAT)
            }
        }
        return nil
    }
    
    @IBAction func sliderValueChanged(_ sender: StepSlider) {
        if isSliderLoadFirst { return }
        self.percentTxb.text = String(Int(sender.index) * accuracy) + "%"
        if !isStarted && sender.index > 0 { isStarted = true; updateJobStart() }

        if !isFinished && sender.index == slideMaxIdx-1 { isFinished = true; updateCompleteJob() }
        else if isFinished && sender.index < slideMaxIdx-1 { isFinished = false; updateCompleteJob() }
    }
    
    @IBAction func ckBoxSelected(_ sender: UIButton) {
        if isNASelected {
            self.ckBoxNASelected(ckBoxNA)
        }
        if sender.tag == 1 && !isFinished { isStarted = !isStarted; updateJobStart(); }
        else if sender.tag == 2 { isFinished = !isFinished; updateCompleteJob(); }
    }
    
    fileprivate func updateJobStart(stDate: Date = Date()) {
        ckBoxStart.setBackgroundImage(isStarted ? UIImage(named: "CheckBoxSelected"):UIImage(named: "CheckBoxUnSelected"), for: .normal)
        startDateTxb.text = isStarted ? Utility.stringFromDate(date: stDate, format: DATE_FORMAT) : ""
        if !isStarted {
            self.sliderView.index = 0;
            ckBoxComplete.setBackgroundImage(UIImage(named: "CheckBoxUnSelected"), for: .normal)
            completeDatetxb.text = ""
        }
    }
    
    fileprivate func rollbackSliderValue() {
        self.percentTxb.text = "\(Int(slideMaxIdx-2) * accuracy)%"
        self.sliderView.index = UInt(slideMaxIdx-2)
    }
    
    fileprivate func updateCompleteJob(edDate: Date = Date()) {
        if isFinished {
            if isReqPhotoNotTaken() { rollbackSliderValue(); return }
            if !isFutureCompleteDate(endDate: edDate) { isFinished = false; return }
            self.sliderView.setIndex(self.slideMaxIdx, animated: true)
        } else {
            rollbackSliderValue()
        }
        ckBoxComplete.setBackgroundImage(isFinished ? UIImage(named: "CheckBoxSelected"):UIImage(named: "CheckBoxUnSelected"), for: .normal)
        completeDatetxb.text = isFinished ? Utility.stringFromDate(date: edDate, format: DATE_FORMAT) : ""
    }
    
    fileprivate func isReqPhotoNotTaken() -> Bool{
        if (self.jobVisit.task.photoRequired ?? 0).boolValue && self.jobVisit.answer.ansDocuments.count == 0 {
            if !isStarted { isStarted = true; updateJobStart() }
            isFinished = false
            self.popViewController.showInView(self.navigationController?.view, withTitle: StringConstants.ButtonTitles.TLT_Attention, withMessage: StringConstants.StatusMessages.TASK_PHOTO_REQUIRED_MSG, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_TAKE_PHOTO, animated: true, isMessage: true, btnDispTypeParallel:true, continueBlock: {
                    self.triggerForTakePhoto = true
                    self.parentQDelegate.showTaskAnswerPhoto()
                })
            return true
        }
        return false
    }
    
    //MARK: - Task Details Page Delgate function
    func triggerCompletedDate() {
        if self.triggerForTakePhoto {
            self.triggerForTakePhoto = false
            self.isFinished = true
            self.updateCompleteJob()
        }
    }
    
    @IBAction func ckBoxNASelected(_ sender: UIButton) {
        isNASelected = !isNASelected
        ckBoxNA.setBackgroundImage(isNASelected ? UIImage(named: "CheckBoxSelected"):UIImage(named: "CheckBoxUnSelected"), for: .normal)
        if isNASelected {
            self.isStarted = false
            self.isFinished = false
            self.updateJobStart()
        } else {
            self.updateFields()
        }
    }
}

extension TaskDetailsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1 && self.isStarted { return false }
        else if textField.tag == 2 && self.isFinished { return false }
        
        let dateTimePicker = ActionSheetDatePicker(title: textField.tag == 1 ? "TASK START TIME" : "TASK END TIME",
                                                   datePickerMode: .dateAndTime, selectedDate: Date(),
        doneBlock: { (datePicker, selectedDate, index) in
            guard let selDate = selectedDate as? Date else { return }
            
            if textField.tag == 1 { self.isStarted = true; self.updateJobStart(stDate: selDate); }
            else if textField.tag == 2 && self.isFutureCompleteDate(endDate: selDate) {
                self.isFinished = true;
                self.updateCompleteJob(edDate: selDate)
            }
        }, cancel: { (datePicker) in },
           origin: textField)
        dateTimePicker?.show()
        return false
    }
    
    func isFutureCompleteDate(endDate: Date) -> Bool {
        if !isStarted { isStarted = true; updateJobStart() }
        let startDate = Utility.dateFromString(dateStr: startDateTxb.text!, format: DATE_FORMAT) as Date
        if startDate.compare(endDate) == .orderedDescending {
            self.popViewController.showInView(self.navigationController?.view, withTitle: StringConstants.ButtonTitles.TLT_Attention, withMessage: StringConstants.StatusMessages.END_DATE_EARLY_WARNING, withCloseBtTxt: "OK", withAcceptBt: nil, animated: true, isMessage: true)
            return false
        }
        return true
    }
}
