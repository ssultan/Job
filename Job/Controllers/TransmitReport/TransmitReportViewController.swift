//
//  TransmitReportViewController.swift
//  Job
//
//  Created by Saleh Sultan on 6/13/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit
////import Appsee
import JGProgressHUD
import MessageUI

class TransmitReportViewController: RootViewController, MFMailComposeViewControllerDelegate {
    
    var sendReportList = [JobInstanceModel]()
    var expandedSectionHeaderNumber: Int = -1
    var cellViewArray = NSMutableArray()
    @IBOutlet weak var reportTBView: UITableView!
    @IBOutlet weak var noTransRepolbl: UILabel!
    
    // Define the progress bar
    var loadingView = JGProgressHUD(style: .extraLight)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavRightBarItem()
        
        self.reportTBView.tableFooterView = UIView()
        self.reportTBView.sectionHeaderHeight = UITableView.automaticDimension
        self.reportTBView.estimatedSectionHeaderHeight = 200.0
        self.reportTBView.rowHeight = UITableView.automaticDimension
        self.reportTBView.estimatedRowHeight = 400.0
        self.title = StringConstants.PageTitles.TRANSMIT_REPORT_PG_TLT
        
        let sectionHeaderNib: UINib = UINib(nibName: "TransmitReportHeaderView", bundle: nil)
        self.reportTBView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "TransmitReportHeaderView")
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendEmail), name: NSNotification.Name(Constants.NotificationsName.SendEmailNotifier), object: nil)
        
        
        // Show loading indicator during loading the instance
        self.loadingView.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        self.loadingView.textLabel.text = StringConstants.StatusMessages.LOADING_ALL_JOBS
        self.loadingView.show(in: self.view, animated: true)
        
        
        // Update all
        DispatchQueue.global().async {
            //'utility' was before. changed it to userinitiated, we user is waiting for the result and show it in the display. and 'userinitiated' has higher priority than 'utility'.
            
            self.sendReportList = DBJobInstanceServices.loadAllInstancesReport().sorted(by: { $0.instanceSentTime?.compare($1.instanceSentTime! as Date) == .orderedDescending })
            
            DispatchQueue.main.async {
                if self.sendReportList.count == 0 {
                    self.noTransRepolbl.isHidden = false
                }
                else {
                    self.noTransRepolbl.isHidden = true
                }
                
                self.reportTBView.reloadData()
                self.loadingView.dismiss(animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NotificationsName.ReloadReportTableNotifier), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notification:)), name: NSNotification.Name(rawValue: Constants.NotificationsName.ReloadReportTableNotifier), object: nil)
    }
    
    @objc func reloadTableView(notification: Notification) {
        
        if let dictionary = notification.userInfo {
            
            DispatchQueue.main.async {
                var index = 0
                for instance in self.sendReportList {
                    if let instId = instance.instId, let notifyInstId = dictionary[KeyInstanceId] as? String, let status = dictionary[KeyStatus] as? String {
                        
                        if let instServerId = dictionary[KeyInstServerId] as? String {
                            instance.instServerId = instServerId
                        }
                        
                        if let instSentTime = dictionary[KeyInstanceSentTime] as? NSDate {
                            instance.succPhotoUploadTime = instSentTime
                        }
                        
                        if  instId == notifyInstId {
                            self.sendReportList.remove(at: index)
                            instance.status = status
                            self.sendReportList.insert(instance, at: index)
                            break
                        }
                    }
                    index += 1;
                }
                
                //                let rowToReload = NSIndexSet(index: index)
                //                self.reportTBView.reloadSections(rowToReload as IndexSet, with: .none)
                //                self.reportTBView.reloadRows(at: self.reportTBView.indexPathsForVisibleRows!, with: .none)
                self.reportTBView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @objc func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            if self.sendReportList.count > 0 {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                mailComposerVC.navigationBar.tintColor = .red
                mailComposerVC.setSubject(Constants.kFV_REPORT + ": \(AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId)")
                
                if let path = Helper.generateTransmitReportExcel(instArray: self.sendReportList) {
                    try! mailComposerVC.addAttachmentData(NSData(contentsOf: path) as Data, mimeType: "csv", fileName: "\(AppInfo.sharedInstance.username ?? "")_TransmitReport.csv")
                }
                
                self.present(mailComposerVC, animated: true, completion: nil)
            }
        }
        else {
            self.popViewController.showInView(self.view, withTitle: StringConstants.StatusMessages.Device_DoesNot_Support_Email_Title, withMessage:StringConstants.StatusMessages.Device_DoesNot_Support_Email, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil, animated: true, isMessage: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true) {
            if result == MFMailComposeResult.sent {
                self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Message, withMessage:StringConstants.StatusMessages.EMAIL_SENT_SUCCESS, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil, animated: true, isMessage: true)
            }
        }
    }
}

extension TransmitReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expandedSectionHeaderNumber == section {
            return 1
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sendReportList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportDetailsTBCell", for: indexPath) as! ReportDetailsTBCell
        
        let instance = sendReportList[indexPath.section]
        guard (instance.template != nil) else {
            return cell
        }
        
        // Calculate the total answered photos and total answers count.
        var totalAnsPhotos = 0
        var totalAnswers = 0
        for fvObj in instance.jobVisits {
            if let fv = fvObj as? JobVisitModel {
                if let answer = fv.answer {
                    totalAnsPhotos += answer.ansDocuments.count
                    if Bool(truncating: answer.isAnswerCompleted!) == true {
                        totalAnswers += 1
                    }
                }
                
                // For sub field visit like multichoice questions, each choice is considering as an FV therefore has separete answer object.
                for subFVModel in fv.subFVModels {
                    if let answer = subFVModel.answer {
                        totalAnsPhotos += answer.ansDocuments.count
                    }
                }
            }
        }
        
        // For incomplete survey, we dont' need to display the completed date.
        if let completedDate = instance.completedDate {
            cell.dateSubmittedlbl.text = Utility.stringFromDate(date: completedDate as Date, format: "MM/dd/yyyy hh:mm a")
        } else {
            cell.dateSubmittedlbl.text = ""
        }
        if let location = instance.location {
            cell.locationlbl.text = location.storeNumber ?? ""
        }
        if let project = instance.project {
            cell.customerNalbl.text = project.customerName ?? ""
            cell.programNalbl.text = project.programName ?? ""
        }
        cell.projectNumberlbl.text = instance.projectNumber ?? ""
        cell.fvclientIdlbl.text = instance.instServerId ?? ""
        cell.answerCountlbl.text = "\(totalAnswers)"
        cell.photoCountlbl.text = "\(totalAnsPhotos)"
        
        let fvDocumentCounter = instance.documents.filter({ $0.type != Constants.DocSignatureType }).count
        cell.fvPhotoCountlbl.text = "\(fvDocumentCounter)"
        
        cell.selectionStyle = .none
        return cell
    }
    
    fileprivate func unAssignedTempInstance(_ section: Int, _ secHCell: ReportTBHeaderCell) -> UIView? {
        if let templateName = sendReportList[section].templateName, let status = sendReportList[section].status {
            
            // Add store number if available.
            if let location = sendReportList[section].location {
                secHCell.titlelbl.text = "[\(location.storeNumber ?? "Unknown")] \(templateName)"
            } else {
                secHCell.titlelbl.text = "[\(sendReportList[section].storeNumber ?? "Unknown")] \(templateName)"
            }
            secHCell.titlelbl.textColor = .gray
            secHCell.statuslbl.text = status
            
            if status.lowercased().contains("error") || status == StringConstants.StatusMessages.TokenExpired {
                secHCell.statuslbl.textColor = .red
            }
            else {
                secHCell.statuslbl.textColor = .green
                if let uploadTime = sendReportList[section].succPhotoUploadTime {
                    secHCell.statuslbl.text = "\(status) on \(Utility.stringFromDate(date: uploadTime as Date, format: "MM/dd/yyyy hh:mm a"))"
                }
            }
        }
        return secHCell
    }
    
    fileprivate func assignedTempInstanceDetails(_ section: Int, _ secHCell: ReportTBHeaderCell) -> UIView? {
        // Add store number if available.
        if let location = sendReportList[section].location {
            secHCell.titlelbl.text = "[\(location.storeNumber ?? "Unknown")] \(sendReportList[section].templateName ?? "Unknown")"
        } else {
            secHCell.titlelbl.text = "[Unknown] \(sendReportList[section].templateName ?? "Unknown")"
        }
        
        if let status = sendReportList[section].status {
            
            secHCell.statuslbl.text = status
            
            if status.contains("Successfully Sent. Failed to send ") {
                secHCell.statuslbl.textColor = .yellow
            }
            else if status.contains(StringConstants.StatusMessages.SuccessfullyUpdated) || status.contains(StringConstants.StatusMessages.SuccessfullySent) {
                secHCell.statuslbl.textColor = .green
                
                if let uploadTime = sendReportList[section].succPhotoUploadTime {
                    secHCell.statuslbl.text = "\(status) on \(Utility.stringFromDate(date: uploadTime as Date, format: "MM/dd/yyyy hh:mm a"))"
                }
            }
            else if status == StringConstants.StatusMessages.InQueue {
                secHCell.statuslbl.textColor = .white
            }
            else if status.lowercased().contains("error") || status == StringConstants.StatusMessages.TokenExpired || status.lowercased().contains("please do not log off") {
                secHCell.statuslbl.textColor = .red
            }
            else {
                secHCell.uploadProgress.isHidden = false
                secHCell.statuslbl.textColor = Utility.UIColorFromRGB(Constants.LOGO_YELLOW_COLOR)
                
                if status.contains("Sending Photos") {
                    if let firstPart = status.components(separatedBy: " of ").first, let needToUpload = status.components(separatedBy: " of ").last {
                        guard let alreadyUploaded = firstPart.components(separatedBy: "Sending Photos ").last, let totalPhotos = Float(needToUpload) else {
                            return secHCell
                        }
                        
                        if totalPhotos > 0, let uploadedphotos = Float(alreadyUploaded) {
                            secHCell.uploadProgress.progress = uploadedphotos / totalPhotos
                        }
                    }
                }
            }
        }
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(TransmitReportViewController.tableViewHeaderDidSelected(gesture:)))
        secHCell.addGestureRecognizer(tapGuesture)
        return secHCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let secHCell = tableView.dequeueReusableCell(withIdentifier: "ReportTBHeaderCell") as! ReportTBHeaderCell
        secHCell.tag = section + 100
        secHCell.uploadProgress.isHidden = true
        
        var imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        
        var accessView = UIImageView(image: UIImage(named: "arrow-down"))
        if self.expandedSectionHeaderNumber == section {
            accessView = UIImageView(image: UIImage(named: "arrow-up"))
            imgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        }
        imgView.frame = secHCell.frame
        secHCell.backgroundView = imgView
        accessView.frame.size = CGSize(width: 25, height: 25)
        secHCell.accessoryView = accessView
        
        guard (sendReportList[section].template != nil && sendReportList[section].location != nil) else {
            return unAssignedTempInstance(section, secHCell)
        }
        return assignedTempInstanceDetails(section, secHCell)
    }
    
    
    // Tap Guesture Recongnizer
    @objc func tableViewHeaderDidSelected(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view {
            let section = cell.tag - 100;
            
            if (self.expandedSectionHeaderNumber == -1) {
                self.expandedSectionHeaderNumber = section
                tableViewExpandSection(section)
            } else {
                if (self.expandedSectionHeaderNumber == section) {
                    tableViewCollapeSection(section)
                } else {
                    //tableViewCollapeSection(self.expandedSectionHeaderNumber)
                    tableViewExpandSection(section)
                }
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int) {
        self.expandedSectionHeaderNumber = -1;
        //        var indexesPath = [IndexPath]()
        //
        //        let index = IndexPath(row: 0, section: section)
        //        indexesPath.append(index)
        //
        ////        self.reportTBView!.beginUpdates()
        //        self.reportTBView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.none)
        //        self.reportTBView!.endUpdates()
        self.reportTBView.reloadData()
    }
    
    func tableViewExpandSection(_ section: Int) {
        self.expandedSectionHeaderNumber = section
        //        var indexesPath = [IndexPath]()
        //        let index = IndexPath(row: 0, section: section)
        //        indexesPath.append(index)
        
        //        self.reportTBView!.beginUpdates()
        //        self.reportTBView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.none)
        //        self.reportTBView!.endUpdates()
        self.reportTBView.reloadData()
        
        let index = IndexPath(row: 0, section: section)
        self.reportTBView.selectRow(at: index, animated: true, scrollPosition: .none)
    }
}
