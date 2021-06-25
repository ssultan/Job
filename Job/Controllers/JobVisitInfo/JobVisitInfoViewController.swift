//
//  JobVisitInfoViewController.swift
//  Job
//
//  Created by Saleh Sultan on 5/31/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit
import EPSignature
import CoreLocation
import JGProgressHUD
import AudioToolbox

class JobVisitInfoViewController: RootViewController {

    @IBOutlet weak var jobVisitTB: UITableView!
    @IBOutlet weak var jobNamelbl: UILabel!
//    @IBOutlet weak var projectNolbl: UILabel!
    @IBOutlet weak var storeNolbl: UILabel!
    @IBOutlet weak var addresslbl: UILabel!
    
    @IBOutlet weak var updateJobBtn: UIButton!
    @IBOutlet weak var completeSendBtn: UIButton!
    @IBOutlet weak var updateJobHorBtn: UIButton!
    @IBOutlet weak var completeSendHorBtn: UIButton!
    @IBOutlet weak var saveQueImgIcon: UIImageView!
    @IBOutlet weak var saveSendImgIcon: UIImageView!
    @IBOutlet weak var saveQueImgHorIcon: UIImageView!
    @IBOutlet weak var saveSendImgHorIcon: UIImageView!
    
    var instance:JobInstanceModel!
    var totalNoOfTask = 0
    var totalNoOfTaskAnswered = 0
    var totalJobVisitPhotos = 0
    var totalJobVisitComments = 0
    var totalOFScopeItem = 0
    var isSignatureAvailable = false
    var locManager = CLLocationManager()
    var cellHeight: CGFloat = 70
    var isTableLoaded: Bool = false
    var isViewLayoutLoaded: Bool = false
    var jobVisitPageItems:[String] = [StringConstants.MenuTitles.START_JOB,
                                      StringConstants.MenuTitles.JOB_VISIT_PHOTOS,
                                      StringConstants.MenuTitles.JOB_VISIT_COMMENTS,
                                      //StringConstants.MenuTitles.OUT_OF_SCOPE,
                                      StringConstants.MenuTitles.SIGNATURE]
    
    @IBOutlet weak var bottomView: UIView!
    var loadingView = JGProgressHUD(style: .extraLight)
    
    // MARK: - Class Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.JOB_PAGE_TITLE
        
        locManager.delegate = self
        if locManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locManager.requestWhenInUseAuthorization()
        }

        if UIDevice.current.userInterfaceIdiom == .phone {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.supportLandscape = false
                appDelegate.shouldRotate = false
            }
        }

        guard let instModel = self.instance else { return }
        self.loadingView.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        self.loadingView.textLabel.text = StringConstants.StatusMessages.LOADING_JOB_DETAILS
        self.loadingView.show(in: self.view, animated: true)
        
        if self.instance.template.isShared {
            JobServices().getJobInstance(forInstance: instModel) { (updatedInst) in
                guard updatedInst.completedDate == nil else {
                    self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage: StringConstants.StatusMessages.JOB_COMPLETED, withCloseBtTxt: StringConstants.ButtonTitles.BTN_GO_BACK, withAcceptBt: nil, animated: true, isMessage: false, continueBlock: {
                    }) { _ = self.navigationController?.popViewController(animated: true) }
                    return
                }
                self.instance = updatedInst
                AppInfo.sharedInstance.selJobInstance = self.instance
                self.loadJbInfoData()
            }
        } else {
            DispatchQueue.global().async {
                self.instance = DBJobInstanceServices.loadJobInstIfExist(instModel: instModel)
                AppInfo.sharedInstance.selJobInstance = self.instance
                DispatchQueue.main.async {
                    self.loadJbInfoData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.slideMenuController()?.closeRight()
        self.setNavRightBarItem()
        self.loadJbInfoData()
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.supportLandscape = false
                appDelegate.shouldRotate = false
            }
        }

        if !isViewLayoutLoaded {
            self.resizeBottomViewToFit()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!isTableLoaded) {
            isTableLoaded = true
            if UIDevice.current.userInterfaceIdiom == .phone {
                if (jobVisitTB.frame.size.height - jobVisitTB.contentSize.height + 10 >  0 && cellHeight < 70) {
                    cellHeight = cellHeight + (jobVisitTB.frame.size.height - jobVisitTB.contentSize.height + 10)/5
                }
                jobVisitTB.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizeHeaderToFit()

        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            jobVisitTB.isScrollEnabled = true
        } else {
            jobVisitTB.isScrollEnabled = false
        }

        if !isTableLoaded && !isViewLayoutLoaded  {
            cellHeight = jobVisitTB.contentSize.height > jobVisitTB.frame.size.height ? 52 : 70
            jobVisitTB.reloadData()
            if self.instance.instId != nil { isViewLayoutLoaded = true;  resizeBottomViewToFit() }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    fileprivate func checkJobLocationFirstThenTakeDecision() {
        self.instance.user.isUserNear(storeLocation: self.instance.location) { (isNearStore, distanceAllowed) in
            if !isNearStore {
                self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Attention, withMessage: StringConstants.StatusMessages.STORE_LOC_WARNING, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_PROCEED, animated: true, isMessage: false, continueBlock:
                    {
                    self.openJobTasks()
                }, cancelBlock: {
                })
            } else {
                self.openJobTasks()
            }
        }
    }
    
    fileprivate func openJobTasks() {
        let taskView = self.storyboard?.instantiateViewController(withIdentifier: "TaskVC") as! TaskViewController
        taskView.currentTaskIdx = 0
        self.navigationController?.pushViewController(taskView, animated: true)
    }
    
    fileprivate func loadJbInfoData(){
        
        if self.instance.instId == nil {
            self.showBottomBtn(showVbtn: true, showHorBtn: true)
        }
        
        if let location = instance!.location, let template = instance!.template {
            jobNamelbl.text = String(format: "%@", template.templateName ?? "")
            storeNolbl.text = String(format:"Store # %@", location.storeNumber ?? "")
            addresslbl.text = String(format:"%@\n%@, %@ %@", location.address ?? "", location.city ?? "", location.state ?? "", location.zipCode ?? "")
        }
        
        self.totalNoOfTask = self.instance!.jobVisits.filtered(using: NSPredicate(format: "answer != nil AND task.isActive = 1")).count
        self.totalNoOfTaskAnswered = self.instance!.jobVisits.filtered(using: NSPredicate(format: "answer.isAnswerCompleted = 1 AND task.isActive = 1")).count
        self.totalJobVisitPhotos = self.instance!.documents.filter({ $0.type == Constants.DocImageType }).count
        self.isSignatureAvailable = self.instance!.documents.filter ({ $0.type == Constants.DocSignatureType }).count > 0 ? true : false
        self.totalJobVisitComments = instance!.comments.count
        self.jobVisitTB.reloadData()
        
        if (self.totalNoOfTask == 0) {
            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage: StringConstants.StatusMessages.NO_TASK_MSG, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_LOGOUT, animated: true, isMessage: false, continueBlock: {
                AppInfo.sharedInstance.userAuthToken = ""
                BackgroundServices.sharedInstance.stopTimer() //Stop timer
                _ = self.navigationController?.popToRootViewController(animated: true)
            }) { _ = self.navigationController?.popViewController(animated: true) }
        }
        self.loadingView.dismiss(animated: true)
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return false
    }
    
    // MARK: - Button Actions
    func backBtnAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func resizeBottomViewToFit() {
        if jobVisitTB.contentSize.height > jobVisitTB.frame.size.height {
            showBottomBtn(showVbtn: true, showHorBtn: false)
        } else {
            showBottomBtn(showVbtn: false, showHorBtn: true)
        }
    }
    
    fileprivate func showBottomBtn(showVbtn:Bool, showHorBtn: Bool) {
        completeSendBtn.isHidden = showVbtn
        updateJobBtn.isHidden = showVbtn
        saveQueImgIcon.isHidden = showVbtn
        saveSendImgIcon.isHidden = showVbtn
        
        completeSendHorBtn.isHidden = showHorBtn
        updateJobHorBtn.isHidden = showHorBtn
        saveQueImgHorIcon.isHidden = showHorBtn
        saveSendImgHorIcon.isHidden = showHorBtn
    }
    
    func resizeHeaderToFit() {
        autoreleasepool {
            let headerView = jobVisitTB.tableHeaderView!
            
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            
            // Causes Memory issue and does not let any popup to show
//            jobVisitTB.tableHeaderView = headerView
        }
    }
    
    @objc fileprivate func updateJob() {
        self.gotoTransmitReport(isCompleteJob: false)
    }
    
    @objc fileprivate func completeJob() {
        self.gotoTransmitReport(isCompleteJob: true)
    }
    
    fileprivate func loadSignaturePage() {
        self.lastOrientation = UIApplication.shared.statusBarOrientation
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.supportLandscape = true
            appDelegate.shouldRotate = false
        }
        
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: false, showsSaveSignatureOption: false)
        signatureVC.title = StringConstants.PageTitles.SIGN_PAGE_TLT
        signatureVC.tintColor = UIColor.white
        let nav = UINavigationController(rootViewController: signatureVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    fileprivate func showCautionMsg(forNumberOfAns numOfAnsRequired: Int, forNumberOfPhoto numOfPicRequired: Int) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        var msg = ""
        if numOfAnsRequired > 0 {
            msg = "\(numOfAnsRequired) required task have not been completed.\n"
        }
        if numOfPicRequired > 0 {
            msg = "\(msg)\(numOfPicRequired) required task photos have not been taken."
        }
        
        self.showAcceptCancelMsg(message: msg, acceptBtnTxt: StringConstants.ButtonTitles.BTN_NAVIGATE, closeBtnTxt: StringConstants.ButtonTitles.BTN_Cancel, title: StringConstants.ButtonTitles.TLT_Warning, acceptBlock:
            {
                let summaryView = self.storyboard?.instantiateViewController(withIdentifier: "NavSummaryVC") as! NavSummaryVController
                summaryView.isShowingAllQ = false
                self.navigationController?.pushViewController(viewController: summaryView, direction: NavPushDirection.Top)
        })
    }
    
    fileprivate func isInstanceInProcess() -> Bool {
        if Bool(truncating: instance!.isSentForProcessing) {
            self.showAcceptCancelMsg(message: StringConstants.StatusMessages.DATA_TRANS_WARNING_MSG,
                                     acceptBtnTxt: StringConstants.ButtonTitles.BTN_NAVIGATE,
                                     closeBtnTxt: StringConstants.ButtonTitles.BTN_Cancel,
                                     title: StringConstants.StatusMessages.DATA_TRANS_WARNING_HEADER,
                                     isMessage: true,
                                     btnDispTypeParallel: true) {
                if let viewControllers = self.navigationController?.viewControllers {
                    for viewControl in viewControllers {
                        if viewControl is MainMenuViewController {
                            self.navigationController?.popToViewController(viewControl, animated: false)
                            break
                        }
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.OPEN_TRANS_REPO_NOACTION),
                                                object: nil, userInfo: nil)
            }
            return true
        }
        return false
    }
    
    @IBAction func updateJobBtnAction(_ sender: Any) {
        if isInstanceInProcess() { return }
        
        self.instance?.checkJobAnswers(isCompletedJob: false, completionHandler: { (numOfAnsRequired, numOfPicRequired, isInstanceCompleted) in
            if isInstanceCompleted {
                if AppInfo.sharedInstance.selJobInstance.instId != nil {
                    instance.isSentForProcessing = true
                    instance.isSentOrUpdated = true
                    instance.instanceSentTime = NSDate()
                    instance.status = StringConstants.StatusMessages.SendingJob
                    JobServices.updateJobInstance(jobInstance: instance!)
                    
                    self.loadingView.textLabel.text = StringConstants.StatusMessages.PLEASE_WAIT_MSG
                    self.loadingView.show(in: self.view, animated: true)
                    self.disableNavigationBtnAction()
                    self.perform(#selector(updateJob), with: self, afterDelay: 0.5)
                }
            } else {
                self.showCautionMsg(forNumberOfAns: 0, forNumberOfPhoto: numOfPicRequired)
            }
        })
    }
    
    @IBAction func completeSendBtnAction(_ sender: Any) {
        if isInstanceInProcess() { return }
        
        self.instance?.checkJobAnswers(isCompletedJob: true, completionHandler: { (numOfAnsRequired, numOfPicRequired, isInstanceCompleted) in
            if isInstanceCompleted {
                if (instance?.template.signatureRequired == true) {
                    let signature = instance!.documents.filter { ($0.type == Constants.DocSignatureType) }
                    if signature.count == 0 {
                        
                        self.showAcceptCancelMsg(message: StringConstants.ButtonTitles.TLT_SIGN_REQUIRED,
                                                 acceptBtnTxt: StringConstants.ButtonTitles.BTN_NAVIGATE,
                                                 closeBtnTxt: StringConstants.ButtonTitles.BTN_Cancel,
                                                 title: StringConstants.ButtonTitles.TLT_Warning,
                                                 acceptBlock: {
                                                    self.loadSignaturePage()
                        })
                        return
                    }
                }
//<<<<<<< HEAD
//                self.instance!.completeNSendInstUpdate()
//=======
//                JobServices.completeNSendInstUpdate(jobInstance: instance!)
//>>>>>>> Dev_new
                self.instance!.completeNSendInstUpdate()
                self.loadingView.textLabel.text = StringConstants.StatusMessages.INITIATING_SEND_PROCESS
                self.loadingView.show(in: self.view, animated: true)
                self.disableNavigationBtnAction()
                self.perform(#selector(self.completeJob), with: self, afterDelay: 0.5)
            }
            else {
                self.showCautionMsg(forNumberOfAns: numOfAnsRequired, forNumberOfPhoto: numOfPicRequired)
            }
        })
    }
    
    func disableNavigationBtnAction() {
        self.removeNavigationBarItem()
    }
    
    func gotoTransmitReport(isCompleteJob:Bool = true) {
        self.loadingView.dismiss(animated: true)
        
        if let viewControllers = self.navigationController?.viewControllers {
            for viewControl in viewControllers {
                if viewControl is MainMenuViewController {
                    self.navigationController?.popToViewController(viewControl, animated: false)
                    break
                }
            }
        }
        
        // Send the flag so that the system can start the send process.
        let objInfo:[String: Bool] = ["isCompleteNSend": isCompleteJob]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.OPEN_SENT_REPORTS), object: nil, userInfo: objInfo)
    }
}

// MARK: - Location Manager
extension JobVisitInfoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .denied:
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage: StringConstants.StatusMessages.LOCATION_ACCESS_NEEDED_MSG, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_SETTINGS, animated: true, isMessage: false, continueBlock: {
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            }, cancelBlock:  {
                _ = self.navigationController?.popViewController(animated: true)
            })

        case .restricted:
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage: StringConstants.StatusMessages.LOCATION_ACCESS_NEEDED_MSG, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_SETTINGS, animated: true, isMessage: false, continueBlock: {
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            }, cancelBlock:  {
                _ = self.navigationController?.popViewController(animated: true)
            })

        case .notDetermined:
            print("not determined.")
        default:
            break
        }
    }
    
    func IsLocationAccessAuthorized() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            
            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage: StringConstants.StatusMessages.LOCATION_ACCESS_NEEDED_MSG, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_SETTINGS, animated: true, isMessage: false, continueBlock: {
                
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsURL) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            }, cancelBlock:  {})
            return false
        default:
            return true
        }
    }
}

// MARK: - TableView Data sources
extension JobVisitInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobVisitPageItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FieldVisitTVCell", for: indexPath) as! MainMenuTableViewCell
        
        if indexPath.row == 0 {
            cell.cellTitlelbl.text = jobVisitPageItems[0]
            cell.cellDetailsCtlbl.text = "\(totalNoOfTaskAnswered)/\(totalNoOfTask)"
            cell.cellImgV.image = UIImage(named: "FvPenIcon")
        } else if indexPath.row == 1 {
            cell.cellTitlelbl.text = jobVisitPageItems[1]
            cell.cellDetailsCtlbl.text = "\(totalJobVisitPhotos)"
            cell.cellImgV.image = UIImage(named: "FvPhotoIcon")
        } else if indexPath.row == 2 {
            cell.cellTitlelbl.text = jobVisitPageItems[2]
            cell.cellDetailsCtlbl.text = "\(totalJobVisitComments)"
            cell.cellImgV.image = UIImage(named: "comment-white")
//        } else if indexPath.row == 3 {
//            cell.cellTitlelbl.text = jobVisitPageItems[3]
//            cell.cellDetailsCtlbl.text = "\(totalOFScopeItem)"
//            cell.cellImgV.image = UIImage(named: "OutOfScope")
        } else {
            cell.cellTitlelbl.text = (instance?.template.signatureRequired == true) ? "\(jobVisitPageItems[jobVisitPageItems.count-1]) ★" : jobVisitPageItems[jobVisitPageItems.count-1]
            cell.cellDetailsCtlbl.text = isSignatureAvailable ? "YES" : "NO"
            cell.cellImgV.image = UIImage(named: "FvSignatureIcon")
        }
        
        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        imgView.frame = cell.frame
        cell.backgroundView = imgView
        cell.accessoryType = .disclosureIndicator
        
        let selImgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        selImgView.frame = cell.frame
        cell.selectedBackgroundView = selImgView
        cell.selectionStyle = .blue
        
        return cell
    }
}

// MARK: - TableView Deleages
extension JobVisitInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !IsLocationAccessAuthorized() {
            return
        }
        if indexPath.row == 0 {
            self.checkJobLocationFirstThenTakeDecision()
        }
        else if indexPath.row == 1 {
            let photoGallery = self.storyboard?.instantiateViewController(withIdentifier: "PhotoGalleryVC") as! PhotoGalleryViewController
            photoGallery.photoGalType = .JobVisitPhotos
            self.navigationController?.pushViewController(photoGallery, animated: true)
        }
        else if indexPath.row == 2 {
            let commentView = self.storyboard!.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsViewController
            self.navigationController?.pushViewController(viewController: commentView, direction: NavPushDirection.Bottom)
//        }else if indexPath.row == 3 {
//            let summaryView = self.storyboard?.instantiateViewController(withIdentifier: "NavSummaryVC") as! NavSummaryVController
//            self.navigationController?.pushViewController(viewController: summaryView, direction: NavPushDirection.Top)
        }else {
            if let documents = instance?.documents {
                if let signature = documents.filter({ $0.type == Constants.DocSignatureType }).last {
                    
                    let signView = self.storyboard?.instantiateViewController(withIdentifier: "SignatureVC") as! SignatureViewController
                    signView.signatureImg = Utility.getImageFromDocumentDirectory(docName: signature.name ?? "", folderName: signature.instanceId ?? "")
                    signView.signName = signature.name ?? ""
                    signView.signTitle = signature.attribute ?? ""
                    signView.signComment = signature.comment ?? ""
                    signView.signatureModel = signature
                    self.navigationController?.pushViewController(signView, animated: true)
                    return
                }
            }

            self.loadSignaturePage()
        }
    }
}

// MARK: - EPSignatur Delegate Functions
extension JobVisitInfoViewController: EPSignatureDelegate {
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
        
        if lastOrientation == UIInterfaceOrientation.portrait {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        
        let signView = self.storyboard?.instantiateViewController(withIdentifier: "SignatureVC") as! SignatureViewController
        signView.signatureImg = signatureImage
        signView.isSignUpdated = true
        self.navigationController?.pushViewController(signView, animated: true)
    }
}

// MARK: - Extentions EPSignatures Control
extension EPSignatureViewController {
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.shouldRotate = false
        }
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
    
    override open var shouldAutorotate : Bool {
        return false
    }
    
    override open var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .landscapeRight
    }
}
