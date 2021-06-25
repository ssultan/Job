//
//  EmergSendProcVController.swift
//  Job V2.0
//
//  Created by Saleh Sultan on 5/16/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import Zip
//import Appsee

enum SelectedOption:Int {
    case DatabaseOnly = 0
    case DocumentsOnly = 1
    case DatabaseAndDocuments = 2
}


class EmergSendProcVController: RootViewController {

    var archivePath:URL!
    var uploadData: NSData!
    var uploadFile: BRRequestUpload!
    var bgTask:UIBackgroundTaskIdentifier!
    var selSendOption: SelectedOption = SelectedOption.DatabaseAndDocuments
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var processStatus: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var successCheckBox: UIImageView!
    @IBOutlet weak var zippedImg: UIImageView!
    @IBOutlet weak var spinnerActivity: UIActivityIndicatorView!
    @IBOutlet weak var sTBView: UITableView!
    @IBOutlet weak var txtTopSpacing: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = false
        self.title = StringConstants.PageTitles.FTP_PAGE_TLT
        successCheckBox.isHidden = true
        
        self.sTBView.tableFooterView = UIView()
        
        progressBar.layer.cornerRadius = 5.0
        progressBar.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let index = IndexPath(row: 2, section: 0)
        self.sTBView.selectRow(at: index, animated: true, scrollPosition: .middle)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.view.frame.size.width == 320 {
            txtTopSpacing.constant = 0
        } else {
            txtTopSpacing.constant = 20
        }
    }
    

    @IBAction func cancelBtnAction() {
        
        if spinnerActivity.isAnimating {
            uploadFile.cancel()
            sendBtn.isEnabled = false
            progressBar.isHidden = true
            processStatus.isHidden = true
            spinnerActivity.stopAnimating()
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    fileprivate func getAllFilePathsToZip() -> [URL] {
        var pathsToZip = [URL]()
        if let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let files = try! FileManager.default.contentsOfDirectory(at: docDirectory, includingPropertiesForKeys: nil, options: [])
            if selSendOption == .DatabaseOnly {
                for file in files {
                    if file.absoluteString.lowercased().contains(".sqlite") {
                        pathsToZip.append(file)
                    }
                }
            }
            else if selSendOption == .DocumentsOnly {
                for file in files {
                    if file.hasDirectoryPath || file.absoluteString.lowercased().contains(".jpeg") {
                        pathsToZip.append(file)
                    }
                }
            }
            else {
                for file in files {
                    pathsToZip.append(file)
                }
            }
        }
        return pathsToZip
    }
    
    fileprivate func zipFiles(forArchivePath archiveFileName: String) -> URL? {
        let pathsToZip = getAllFilePathsToZip()
        self.archivePath = nil
        let semaphore = DispatchSemaphore(value: 0)

        do {
            archivePath = try Zip.quickZipFiles(pathsToZip, fileName: archiveFileName, progress: { (progress) in
                DispatchQueue.main.async {
                    self.progressBar.progress = Float(progress)
                }
                if progress == 1.0 {
                    semaphore.signal()
                }
            })
        } catch {
            semaphore.signal()
        }
        if semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
            print("Failed to zip files")
        }
        return self.archivePath
    }
    
    fileprivate func startZippedFileUpload(forArchivePath zipArchivedPath: URL, forNameName archiveFileName: String) {
        self.progressBar.progress = 0.0
        self.processStatus.text = StringConstants.StatusMessages.UPLOADING_FILE_MSG
        self.uploadData = NSData(contentsOf: zipArchivedPath)
        self.uploadFile = BRRequestUpload(delegate: self)
        self.uploadFile.path = "/Job/iOS/\(archiveFileName)"
        self.uploadFile.hostname = Constants.Clearthread.FTP_HOSTNAME
        self.uploadFile.username = Constants.FTP_UserName
        self.uploadFile.password = Constants.FTP_Password
        self.uploadFile.start()
    }
    
    @IBAction func sendBtnAction() {
        
        bgTask = UIApplication.shared.beginBackgroundTask(withName: "UploadFTPDATA") {}
        spinnerActivity.startAnimating()
        sendBtn.isEnabled = false
        processStatus.isHidden = false
        processStatus.textColor = .white
        progressBar.isHidden = false
        successCheckBox.isHidden = true
        sTBView.isHidden = true
        sendBtn.isHidden = true
        cancelBtn.isHidden = true
        zippedImg.isHidden = false
        self.progressBar.progress = 0.0
        self.processStatus.text = StringConstants.StatusMessages.ZIPPING_FILES_MSG

        let userId = Utility.getLastLoggedInUserName() ?? AppInfo.sharedInstance.deviceId
        let archiveFileName = "\(userId)_\(arc4random_uniform(999999))_V\(AppInfo.sharedInstance.appVersion).zip"
        
        DispatchQueue.global(qos: .default).async {
            if let zipArchivedPath = self.zipFiles(forArchivePath: archiveFileName) {
                DispatchQueue.main.async {
                    self.startZippedFileUpload(forArchivePath: zipArchivedPath, forNameName: archiveFileName)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.sendBtn.isHidden = false
                    self.cancelBtn.isHidden = false
                    self.zippedImg.isHidden = true
                    
                    self.spinnerActivity.stopAnimating()
                    self.sendBtn.isEnabled = true
                    self.progressBar.isHidden = true
                    self.processStatus.isHidden = true
                    self.showErrorMsg(StringConstants.StatusMessages.UNABLE_TO_ZIP_FILE_MSG)
                    
                    // End the background task when done
                    UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.bgTask.rawValue))
                    self.bgTask = UIBackgroundTaskIdentifier.invalid
                }
            }
        }
    }
    
    
    func removeZipFile() {
        do {
            try FileManager.default.removeItem(at: archivePath)
        } catch {
            // Add an Appsee event for that.
            print("Failed to remove zipped file from doc folder.")
        }
    }
}


extension EmergSendProcVController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath) as! EmergSendProcTVCell
        
        switch indexPath.row {
        case 0:
            cell.cellTitle.text = StringConstants.StatusMessages.EMERGENCY_SEND_DATABASE_ONLY
            cell.cellImgView.image = UIImage(named: "DatabaseIcon")
        case 1:
            cell.cellTitle.text = StringConstants.StatusMessages.EMERGENCY_SEND_IMG_ONLY
            cell.cellImgView.image = UIImage(named: "FvPhotoIcon")
        case 2:
            cell.cellTitle.text = StringConstants.StatusMessages.EMERGENCY_SEND_DATABASE_N_IMG
            cell.cellImgView.image = UIImage(named: "FolderIcon")
        default:
            cell.cellTitle.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.view.frame.size.width == 320 {
            return 60
        }
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selSendOption = self.setSelectedItem(val: indexPath.row)
    }
    
    @objc func checkboxBtnSelAction(button: UIButton) {
        selSendOption = self.setSelectedItem(val: button.tag - 100)
        sTBView.reloadData()
    }
    
    func setSelectedItem(val: Int) -> SelectedOption {
        switch val {
        case 0:
            return .DatabaseOnly
        case 1:
            return .DocumentsOnly
        default:
            return .DatabaseAndDocuments
        }
    }
}


extension EmergSendProcVController: BRRequestDelegate {
    func shouldOverwriteFile(with request: BRRequest!) -> Bool {
        return false
    }
    
    func requestData(toSend request: BRRequestUpload!) -> Data! {
        if let temp = uploadData {
            uploadData = nil;
            return temp as Data
        }
        return nil
    }
    
    func requestDataSendSize(_ request: BRRequestUpload!) -> Int {
        guard let data = uploadData else {
            return 0
        }
        return data.length
    }
    
    func percentCompleted(_ request: BRRequest!) {
        progressBar.progress = request.percentCompleted
    }
    
    func requestDataAvailable(request: BRRequestDownload!) {
    }
    
    func requestFailed(_ request: BRRequest!) {
        print("Failed to up FTP Data")
        //Appsee.addEvent("Failed to send FTP Data", withProperties: [Constants.ApiRequestFields.Key_Username: AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId])
        
        self.removeZipFile()
        uploadFile = nil
        spinnerActivity.stopAnimating()
        doneBtn.isHidden = true
        
        zippedImg.isHidden = true
        progressBar.isHidden = true
        spinnerActivity.isHidden = true
        processStatus.text = StringConstants.StatusMessages.UNABLE_TO_UPLOAD_ZIP_FILE_MSG
        processStatus.textColor = .red
        
        successCheckBox.isHidden = false
        successCheckBox.image = UIImage(named: "RedCrossIcon")
        
        sendBtn.isEnabled = true
        sendBtn.isHidden = false
        cancelBtn.isHidden = false
        cancelBtn.setTitle("DONE", for: .normal)
        sendBtn.setTitle("TRY AGAIN", for: .normal)
        sendBtn.setBackgroundImage(UIImage(named: "BlueBtn"), for: .normal)
        sendBtn.setBackgroundImage(UIImage(named: "BlueBtnSelected"), for: .highlighted)
        
        // End the background task when done
        UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
        bgTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func requestCompleted(_ request: BRRequest!) {
        uploadFile = nil
        self.removeZipFile()
        if request.streamInfo.cancelRequestFlag {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            spinnerActivity.stopAnimating()
            doneBtn.isHidden = false
            zippedImg.isHidden = true
            //sendBtn.isEnabled = true
            //cancelBtn.setTitle(StringConstants.ButtonTitles.BTN_DONE, for: .normal)
            
            progressBar.isHidden = true
            successCheckBox.isHidden = false
            successCheckBox.image = UIImage(named: "BlueCheckMark")
            processStatus.text = StringConstants.StatusMessages.ZIP_FILE_UPLOAD_SUCCESS_MSG
            processStatus.textColor = UIColor.white
        }
        
        // End the background task when done
        UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
        bgTask = UIBackgroundTaskIdentifier.invalid
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
    return UIBackgroundTaskIdentifier(rawValue: input)
}
