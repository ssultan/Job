//
//  LoginViewController.swift
//  JobV2.0
//
//  Created by Saleh Sultan on 05/07/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import Crashlytics
import AudioToolbox
import JGProgressHUD
import Alamofire
////import Appsee
import Firebase
import FirebasePerformance

let stagingPassword = ""
let prodPassword = ""

class LoginTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

class LoginViewController: RootViewController, UITextFieldDelegate, LoginOberverDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    internal func verifyEULAAcceptedForUser(_ userId: String, continueBlock: @escaping () -> ()) {
        self.eulaContinueBlock = continueBlock
        let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsConditionVC") as! TermsConditionViewController
        termsVC.delegate = self
        
        let navControl = UINavigationController.init(rootViewController: termsVC)
        self.present(navControl, animated: true, completion: nil)
    }


    @IBOutlet weak var userNaTxtFi: UITextField!
    @IBOutlet weak var passwordTxtFi: UITextField!
    @IBOutlet weak var appVersionlbl: UILabel!
    @IBOutlet weak var osVersionlbl: UILabel!
    @IBOutlet weak var envTitlelbl: UILabel!
    @IBOutlet weak var environmentlbl: UILabel!
    @IBOutlet weak var detectOldVlbl: UILabel!
    @IBOutlet weak var envPickerBt: UIButton!
    @IBOutlet weak var appInfoView: UIView!
    @IBOutlet weak var topSpacingCons: NSLayoutConstraint!
    @IBOutlet weak var bottomSpaCons:NSLayoutConstraint!
    @IBOutlet weak var bioIconSize:NSLayoutConstraint!
    @IBOutlet weak var passExSignBt: UIButton!
    @IBOutlet weak var userNExSignBt: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var userTxtBoxHolderImg: UIImageView!
    @IBOutlet weak var passTxtBoxHolderImg: UIImageView!
    @IBOutlet weak var eyeIconImg: UIImageView!
    @IBOutlet weak var showHidePassBtn: UIButton!
    
    var templateDownloaded = false
    var locationDownloaded = false
    var isTouchIdChanged = false
    var reqTimeoutReceived = 0
    
    var totalItmNeedToDl = 0
    var totalItmDownloaded = 0
    var loadingView = JGProgressHUD(style: .extraLight)
    let loginReq = LoginService.sharedInstance
    let appInfo = AppInfo.sharedInstance
    var eulaContinueBlock:()->() = {}
    var isWarningShowed = false
    var keychainAccounts = [KeychainPasswordItem]()
    var isPasswordDisplaying:Bool = false
    var biometricAuth = BiometricAuthentication()
    
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.shouldRotate = false
        }
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        self.appVersionlbl.text = appInfo.appVersion
        self.osVersionlbl.text = appInfo.osVersion
        self.environmentlbl.text = appInfo.environment
        self.environmentlbl.isHidden = true
        self.envTitlelbl.isHidden = true
        self.envPickerBt.setTitle(appInfo.baseURL, for: UIControl.State())
        self.envPickerBt.layer.cornerRadius = 8.0
        self.envPickerBt.clipsToBounds = true
        self.envPickerBt.layer.borderWidth = 1.0
        self.envPickerBt.layer.borderColor = UIColor.yellow.cgColor
        self.detectOldVlbl.text = ""
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboards)) as UITapGestureRecognizer
        self.view.addGestureRecognizer(tapGesture)
        
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(guesture:)))
        longGesture.minimumPressDuration = 3.0
        longGesture.allowableMovement = 100.0
        self.loginBtn.addGestureRecognizer(longGesture)
//        //Appsee.markView(asSensitive: self.passwordTxtFi)
        
        do {
            self.keychainAccounts = try KeychainPasswordItem.passwordItems(forService: Constants.keyChainServiceName, accessGroup: Constants.keyChainAccessGroup)
            if let user = keychainAccounts.first {
                self.userNaTxtFi.text = user.account
            }
            biometricPassSetup(isFirstLoad:true)
        } catch {
            Crashlytics.sharedInstance().setObjectValue("\(error)", forKey: "Error fetching password items")
//            //Appsee.addEvent("Error fetching Keychain password items", withProperties: [Constants.ApiRequestFields.Key_Username: AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId, "Error":  "\(error)"])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        reqTimeoutReceived = 0
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.supportLandscape = false
            appDelegate.shouldRotate = false
        }
        
        BackgroundServices.sharedInstance.stopTimer()
        setupPreloadedValues()
    }
    
    func setupPreloadedValues() {
        #if DEBUG
            passwordTxtFi.text = stagingPassword
        #elseif STAGE
        if let prevSelEnv = UserDefaults.standard.value(forKey: Constants.kSelectedEnvironment) {
            self.appInfo.setupEnvironment(enviroment: prevSelEnv as! String)
            self.environmentlbl.text = self.appInfo.environment
            self.envPickerBt.setTitle(self.appInfo.baseURL, for: UIControl.State())
            
            if prevSelEnv as! String == Constants.Environments.kStaging {
                passwordTxtFi.text = stagingPassword
            }
            else {
                passwordTxtFi.text = prodPassword
            }
        }
        else {
            passwordTxtFi.text = stagingPassword
        }
        Analytics.logEvent("Environment", parameters: ["AppEnv": "Staging"])
        #else
            Analytics.logEvent("Environment", parameters: ["AppEnv": "Production"])
            envTitlelbl.isHidden = true
            environmentlbl.isHidden = true
            envPickerBt.isHidden = true
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            topSpacingCons.constant = 320
            bottomSpaCons.constant = 15
        }
        
        let authType = biometricAuth.checkBiometricType(username: userNaTxtFi.text!)
        if authType == .faceID || authType == .touchID {
            bioIconSize.constant = 30
        } else {
            bioIconSize.constant = 24
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.removeNavigationBarItem()
        if Helper.isDeviceIsJailBroken() {
            self.loginBtn.isEnabled = false
            self.showErrorMsg(StringConstants.StatusMessages.JAILBROKEN_DEVICE_ERROR_MSG, title: StringConstants.StatusMessages.JAILBROKEN_DEVICE_ERROR_MSG_Title, closingDialogBlock: {
                exit(0)
            })
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popSegPassFi" || segue.identifier == "popSegUserNFi"  {
            let popoverViewController = segue.destination 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
    
    @objc func handleLongPress(guesture: UILongPressGestureRecognizer) {
        if guesture.state == .began {
            let emgDumpData = self.storyboard?.instantiateViewController(withIdentifier: "EmergSendProcVC") as! EmergSendProcVController
            self.navigationController?.pushViewController(emgDumpData, animated: true)
        }
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //Hide app info view, when applicaion is in landscape mode.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone {
            appInfoView.isHidden = true
            topSpacingCons.constant = 140
            bottomSpaCons.constant = 5
            envPickerBt.isHidden = true
            
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            appInfoView.isHidden = false
            topSpacingCons.constant = 200
            bottomSpaCons.constant = 15
            
            #if DEBUG
                envPickerBt.isHidden = false
            #elseif STAGE
                envPickerBt.isHidden = false
            #else
                envPickerBt.isHidden = true
            #endif
        }
        else {
            appInfoView.isHidden = false
            topSpacingCons.constant = 320
            bottomSpaCons.constant = 15
            
            #if DEBUG
                envPickerBt.isHidden = false
            #elseif STAGE
                envPickerBt.isHidden = false
            #else
                envPickerBt.isHidden = true
            #endif
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func hideKeyboards() {
        userNaTxtFi.resignFirstResponder()
        passwordTxtFi.resignFirstResponder()
    }
    
    func changeTxtFiBorderColor(_ txtField: UITextField, isError:Bool) {
        
        if txtField.tag == 1 {
            userNExSignBt.isHidden = isError ? false : true
            userTxtBoxHolderImg.layer.borderColor = UIColor.red.cgColor
            userTxtBoxHolderImg.layer.borderWidth = isError ? 1.0 : 0.0
        }
        else {
            let authType = biometricAuth.checkBiometricType(username: userNaTxtFi.text!)
            if authType == BiometricType.faceID || authType == BiometricType.touchID {
                return
            }
            
            passExSignBt.isHidden = isError ? false : true
            passTxtBoxHolderImg.layer.borderColor = UIColor.red.cgColor
            passTxtBoxHolderImg.layer.borderWidth = isError ? 1.0 : 0.0
            if (isError) {
                eyeIconImg.isHidden = true
                showHidePassBtn.isHidden = true
            } else {
                eyeIconImg.isHidden = false
                showHidePassBtn.isHidden = false
            }
        }
    }
    

    //MARK: - Button Action Method
    @IBAction func changeEnvBtAction(_ sender: AnyObject) {

        let alert = UIAlertController(title: "Select Environment", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Constants.Environments.kDevelopment, style: .default, handler: { (alertAction) in
            self.appInfo.setupEnvironment(enviroment: Constants.Environments.kDevelopment)
//            self.environmentlbl.text = self.appInfo.environment
            self.envPickerBt.setTitle(self.appInfo.baseURL, for: UIControl.State())
            
            #if DEBUG || STAGE
                UserDefaults.standard.setValue(Constants.Environments.kDevelopment, forKey: Constants.kSelectedEnvironment)
            #endif
        }))
        alert.addAction(UIAlertAction(title: Constants.Environments.kStaging, style: .default, handler: { (alertAction) in
            self.appInfo.setupEnvironment(enviroment: Constants.Environments.kStaging)
            self.environmentlbl.text = self.appInfo.environment
            self.envPickerBt.setTitle(self.appInfo.baseURL, for: UIControl.State())
            
            #if DEBUG || STAGE
                self.passwordTxtFi.text = stagingPassword
                UserDefaults.standard.setValue(Constants.Environments.kStaging, forKey: Constants.kSelectedEnvironment)
            #endif
        }))
        alert.addAction(UIAlertAction(title: Constants.Environments.kProdUAT, style: .default, handler:  { (alertAction) in
            self.appInfo.setupEnvironment(enviroment: Constants.Environments.kProdUAT)
            self.environmentlbl.text = Constants.Environments.kProdUAT
            self.envPickerBt.setTitle(self.appInfo.baseURL, for: UIControl.State())
            
            #if DEBUG || STAGE
            self.passwordTxtFi.text = prodPassword
            UserDefaults.standard.setValue(Constants.Environments.kProdUAT, forKey: Constants.kSelectedEnvironment)
            #endif
        }))
        alert.addAction(UIAlertAction(title: Constants.Environments.kProduction, style: .default, handler:  { (alertAction) in
            self.appInfo.setupEnvironment(enviroment: Constants.Environments.kRelease)
            self.environmentlbl.text = Constants.Environments.kProduction
            self.envPickerBt.setTitle(self.appInfo.baseURL, for: UIControl.State())
            
            #if DEBUG || STAGE
                self.passwordTxtFi.text = prodPassword
                UserDefaults.standard.setValue(Constants.Environments.kRelease, forKey: Constants.kSelectedEnvironment)
            #endif
        }))
        alert.addAction(UIAlertAction(title: StringConstants.ButtonTitles.BTN_Cancel, style: .destructive, handler: {(alertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            alert.popoverPresentationController?.sourceView = envPickerBt
            alert.popoverPresentationController?.sourceRect = envPickerBt.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func forgotPassBtAction(_ sender: AnyObject) {
        appInfo.pageAboutToLoad = StringConstants.AppseePageTitles.FORGOT_USERNAME_PASSWORD_PAGE
        let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalWebVC") as? GlobalWebViewController
        globalVC!.webURL = appInfo.httpType + appInfo.resetDomain + Constants.Clearthread.kForgotPasswordURL
        globalVC?.viewTitle = StringConstants.PageTitles.FORGOT_PASSWORD_PAGE_TLT
        globalVC?.pageType = .forgotPassword
        self.navigationController?.pushViewController(globalVC!, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func loginBtAction(_ sender: AnyObject) {
        userNaTxtFi.resignFirstResponder()
        passwordTxtFi.resignFirstResponder()
        callLoginProcess()
    }
    
    
    @IBAction func userFieldInitialSpaceingBtnAction() {
        userNaTxtFi.becomeFirstResponder()
    }
    
    @IBAction func passFieldInitialSpaceingBtnAction() {
        passwordTxtFi.becomeFirstResponder()
    }
    
    @IBAction func showHidePassword() {
        let authType = biometricAuth.checkBiometricType(username: userNaTxtFi.text!)
        if authType == .faceID || authType == .touchID {
            biometricPassSetup()
            return
        }
        isPasswordDisplaying = !isPasswordDisplaying
        if isPasswordDisplaying {
            passwordTxtFi.isSecureTextEntry = false
            eyeIconImg.image = UIImage(named: "EyeIcon")
        } else {
            passwordTxtFi.isSecureTextEntry = true
            eyeIconImg.image = UIImage(named: "EyeWithLineIcon")
        }
    }
    
    
    //MARK: - Login Process
    fileprivate func showFieldEmptyError(_ userName: String, _ password: String) {
        if userName == "" { changeTxtFiBorderColor(userNaTxtFi, isError: true) }
        if password == "" { changeTxtFiBorderColor(passwordTxtFi, isError: true) }
        
        self.showErrorMsg(StringConstants.StatusMessages.EmptyFieldMsg, title: StringConstants.ButtonTitles.TLT_Attention, closeBtnTxt:StringConstants.ButtonTitles.BTN_Understood)
    }
    
    func callLoginProcess() {
        templateDownloaded = false
        locationDownloaded = false
        
        totalItmNeedToDl = 0
        totalItmDownloaded = 0
        
        changeTxtFiBorderColor(userNaTxtFi, isError: false)
        changeTxtFiBorderColor(passwordTxtFi, isError: false)
        
        
        guard let userName = self.userNaTxtFi.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).lowercased(),
            let password = self.passwordTxtFi.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)  else {
                showFieldEmptyError(userNaTxtFi.text ?? "", passwordTxtFi.text ?? "")
                return
        }
        if userName == "" || password == "" {
            showFieldEmptyError(userName, password)
            return
        }
        
        //Turn ON device dimming
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        self.loadingView.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        self.loadingView.textLabel.text = StringConstants.StatusMessages.LogginDavaco
        self.loadingView.show(in: self.view, animated: true)
        
        
        //Set userId for the Appsee Session
//        //Appsee.setUserID(userName)
        Analytics.setUserID(userName)
        Crashlytics.sharedInstance().setUserName(userName)
        Crashlytics.sharedInstance().setUserIdentifier(userName)
        
        self.passwordTxtFi.resignFirstResponder()
        loginBasedOnNetworkAvailability(userName, password)
    }
    
    fileprivate func loginBasedOnNetworkAvailability(_ userName: String, _ password: String) {
        self.loginReq.delegate = self
        Utility.checkInternetConnection { (isRechable, connectionType) in

            if isRechable {
                self.loginReq.loginOnlineWithUserInfo(userName, password: password)
            }
            else if !isRechable && connectionType == StringConstants.ConnectivityStatus.Restricted {
                self.loadingView.dismiss(animated: true)

                DispatchQueue.main.async {
                    self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Warning, withMessage: StringConstants.StatusMessages.NO_CELLULAR_DATA, withCloseBtTxt: StringConstants.ButtonTitles.BTN_LOGIN_OFFLINE, withAcceptBt: StringConstants.ButtonTitles.BTN_SETTINGS, animated: true, isMessage: false, continueBlock: {

                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }, cancelBlock:  {
                        self.offlineLogin(forUsername: userName, andPassword: password)
                    })
                }
            }
            else {
                self.offlineLogin(forUsername: userName, andPassword: password)
            }
        }
    }
    
    fileprivate func offlineLogin(forUsername userName: String, andPassword password: String) {
        self.loginReq.loginOfflineWithUserInfo(userName, password: password, continueBlock: { (isSuccess) in

            DispatchQueue.main.async {
                self.loadingView.dismiss(animated: true)

                if isSuccess == OfflineLoginStatus.LoginSuccess {
                    self.loginSuccess(isOfflineLogin: true)
                }
                else if isSuccess == OfflineLoginStatus.PasswordNotMatched {
                    self.showErrorMsg(StringConstants.StatusMessages.kInvalidUsernameOrPassword)
                }
                else {
                    self.showErrorMsg(StringConstants.StatusMessages.ERROR_LOGIN_WITH_CONNECTION)
                }
            }
        })
    }
    
    
    
    //MARK: - Login Delegate methods
    func loginSuccess(isOfflineLogin: Bool) {
        
        if templateDownloaded == true && locationDownloaded == true {
            self.loadingView.dismiss()
            
            //Turn OFF device dimming
            UIApplication.shared.isIdleTimerDisabled = false
            
            if !isOfflineLogin {
                self.saveUserDetailsInKeychain()
            }
            
            self.appInfo.password = passwordTxtFi.text
            self.passwordTxtFi.text = ""
            
            
            // This funcation will check if there is any orphan instance avilable, which is not associated with any template or location. If there is, then it will map the instance with template and location if available.
            self.loginReq.syncExistingInstances()
            
            
            //Set userId for the Appsee Session
            if let userId = AppInfo.sharedInstance.username {
//                //Appsee.setUserID(userId)
                Analytics.setUserID(userId)
                Crashlytics.sharedInstance().setUserName(userId)
                Crashlytics.sharedInstance().setUserIdentifier(userId)
                Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: AppInfo.sharedInstance.username.contains(Constants.Anonymous_Initial2) ? "Anonymous" : "Employee", Constants.ApiRequestFields.Key_UserName: userId])
            }
            
            // Start background thread
            BackgroundServices.sharedInstance.startTimer()
            
            
            //Go to main menu page
            let mainMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "MainMenuVC") as! MainMenuViewController
            mainMenuVC.isOfflineLogin = isOfflineLogin
            self.navigationController!.pushViewController(mainMenuVC, animated: true)
        }
    }
    
    
    func versionUpdateRequired(manifestModel: ManifestMapping) {
        self.loadingView.dismiss(animated: true)
        #if DEBUG || STAGE
            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_HOLD_UP, withMessage: StringConstants.StatusMessages.APPLICATION_FORCE_UPDATE_MSG, withCloseBtTxt: StringConstants.ButtonTitles.BTN_CONTINUE, withAcceptBt: StringConstants.ButtonTitles.TLT_Update, animated: true, isMessage: false, continueBlock: {
                
                //Turn OFF device dimming
                UIApplication.shared.isIdleTimerDisabled = false
                
                if let url = NSURL(string: "\(Constants.Clearthread.APP_UPDATE_URL)\(manifestModel.AppUrl)") {
                    UIApplication.shared.open(url as URL)
                }
            }, cancelBlock: {
                DispatchQueue.main.async {
                    self.loginReq.continueLoginProcess(manifestMapperModel: manifestModel)
                }
            })
        #else
            self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_HOLD_UP, withMessage: StringConstants.StatusMessages.APPLICATION_FORCE_UPDATE_MSG, withCloseBtTxt: StringConstants.ButtonTitles.TLT_Update, withAcceptBt: nil, animated: true, isMessage: false) {
                
                //Turn OFF device dimming
                UIApplication.shared.isIdleTimerDisabled = false
                
                if let url = NSURL(string: "\(Constants.Clearthread.APP_UPDATE_URL)\(manifestModel.AppUrl)") {
                    UIApplication.shared.open(url as URL)
                }
            }
        #endif
    }
    
    
    func startDownloadingTemplates(_ jobDLList:NSMutableArray, _ projectIdList:NSMutableArray) {
        
        // Check if any of these list items are empty. If empty, then change the delegate boolean variable flag to true. Because based on these flags we will consider our users to login into our app and show the main menu of the app.
        if jobDLList.count == 0 {
            templateDownloaded = true
        } else if projectIdList.count == 0 {
            locationDownloaded = true
        }
        
        // Count total number of items system needs to download. If the counter is 0, then skip the calling downlaod template and download location function call
        totalItmNeedToDl = jobDLList.count + projectIdList.count
        if totalItmNeedToDl == 0 {
            self.loadingView.dismiss(animated: true)
            self.loginSuccess(isOfflineLogin: false)
        }
        else {
            loadingView.textLabel.text = StringConstants.StatusMessages.DownloadingJobTemp
            loadingView.indicatorView = JGProgressHUDPieIndicatorView()
            loadingView.indicatorView?.setProgress(0.0, animated: true)
            loadingView.show(in: self.view, animated: true)
            
            
            let tempDL = TemplatesDLService()
            tempDL.delegate = self
            tempDL.fetchAllTemplates(jobDLList)


            let locService = LocationWService()
            locService.delegate = self
            locService.fetchAllLocations(projectList: projectIdList)
        }
    }
    
    // Increase the progress bar at the time of downloading jobs
    func increaseProgressbar() {
        totalItmDownloaded += 1
        let percent = Float(totalItmDownloaded) / Float(totalItmNeedToDl)
        
        self.loadingView.indicatorView?.setProgress(percent, animated: false)
        if (percent > 0.99) {
            self.loadingView.dismiss()
        }
    }
    
    
    func loginFailureWithError(_ errorJson: NSDictionary?, reqStatusCode: Int) {
        self.loadingView.dismiss(animated: true)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        //Turn OFF device dimming
        UIApplication.shared.isIdleTimerDisabled = false
        
        // If it is not a 404 NOT found Response. Failed for some resone, then parse data
        if let errorDic = errorJson {
            if let errorCode = errorDic[Constants.ApiRequestFields.Key_ErrorCode] { //, let message = errorDic[Constants.Key_Message]
                
                if let errorCodeInt = errorCode as? Int {
                    if errorCodeInt == HttpRespStatusCodes.RequestTimeOut.rawValue {
                        //Appsee.addEvent(StringConstants.AppseeEventMessages.Login_Request_Timeout)
                        reqTimeoutReceived += 1
                        if reqTimeoutReceived < 2 {
                            self.showErrorMsg(StringConstants.StatusMessages.Request_Timeout_Login)
                        }
                        else {
                            self.showErrorMsg(StringConstants.StatusMessages.Request_Timeout_Login_2nd)
                        }
                        return
                    }
                    else if errorCodeInt == LoginRequestErrCode.UserLockedOut.rawValue {
                        //Appsee.addEvent(StringConstants.AppseeEventMessages.AccountLocked)
                        self.popViewController.showMsgInWebView(view, withTitle: StringConstants.ButtonTitles.TLT_Warning,
                                                                withMessage:StringConstants.StatusMessages.ACCOUNT_LOCKEDOUT_LOGIN_ERROR,
                                                                withHtmlFileName:nil,
                                                                withCloseBtTxt: StringConstants.ButtonTitles.BTN_Cancel, withAcceptBt: StringConstants.ButtonTitles.BTN_RESET,
                                                                animated: true, isMessage: false, continueBlock:
                            {
                                self.appInfo.pageAboutToLoad = StringConstants.AppseePageTitles.RESET_PASSWORD_PAGE
                                let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalWebVC") as? GlobalWebViewController
                                globalVC!.webURL = self.appInfo.httpType + self.appInfo.resetDomain + Constants.Clearthread.kForgotPasswordURL
                                globalVC?.viewTitle = StringConstants.PageTitles.RESET_PASSWORD_PG_TLT
                                globalVC?.pageType = .forgotPassword
                                self.navigationController?.pushViewController(globalVC!, animated: true)
                        })
                        return
                    }
                    else {
                        ErrorHandler.shared.handleLoginErrors(self.view, errorDic: errorDic, forUsername: self.userNaTxtFi.text ?? "")
                        return
                    }
                }
            }
        }
        // If the request status code is not 200, then check the
        ErrorHandler.shared.handleLoginRequestBadStatusCode(self.view, statusCode: reqStatusCode)
    }
    
    func noTemplateAssignedError() {
        self.loadingView.dismiss(animated: true)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.showErrorMsg(StringConstants.StatusMessages.No_Assigned_Template_Login)
    }
    
    //MARK: - EULA View delegate functions
    func eulaPanelViewControllerAcceptedEULA() {
        self.eulaContinueBlock()
    }
    
    func eulaPanelViewControllerDeclinedEULA() {
        self.loadingView.dismiss(animated: true)
        self.passwordTxtFi.text = ""
    }
    
//    func usePasscodeAuth() {
//        if let curDomPolicyId = self.biometricAuth.getCurrentDomainPolictyId() {
//            self.biometricAuth.authenticateUser(oldDomainStateId: curDomPolicyId, username: self.appInfo.username!, bioType: BiometricType.passCodeID) { (message, isCancelled, authFailed, fallbackPass) in
//
//                if message == nil || isCancelled {
//                    if message == nil {
//                        let authPolicy = KeychainPasswordItem(service: Constants.keyChainTouchIdDetectionServiceName, account: Constants.keyTouchId, accessGroup: Constants.keyChainAccessGroup)
//                        try! authPolicy.savePassword(curDomPolicyId)
//                    }
//                    DispatchQueue.main.async {
//                        self.loginReq.downloadManifest(self.appInfo.username!)
//                    }
//                }
//                else {
//                    DispatchQueue.main.async {
//                        self.showErrorMsg(message!)
//                        self.loadingView.dismiss()
//                    }
//                }
//            }
//        }
//    }
    

    //MARK: - UITextField Delegate functions
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordTxtFi {
            if let fieldTxt = textField.text {
                
                let text = "\(fieldTxt)\(string)"
                if text.count > 0 {
                    
                    let authType = biometricAuth.checkBiometricType(username: userNaTxtFi.text!)
                    if authType != .touchID && authType != .faceID {
                        self.eyeIconImg.image = isPasswordDisplaying ?
                            UIImage(named: "EyeIcon") :
                            UIImage(named: "EyeWithLineIcon")
                    }
                    self.changeTxtFiBorderColor(textField, isError: false)
                }
            }
        }
        else {
            self.changeTxtFiBorderColor(textField, isError: false)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            changeTxtFiBorderColor(textField, isError: true)
        } else {
            changeTxtFiBorderColor(textField, isError: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.tag == 1 {
            if let nextField = self.view.viewWithTag(2) {
                let passFi = nextField as! UITextField
                passFi.becomeFirstResponder()
            }
        }
        else if textField.tag == 2 {
            callLoginProcess()
        }
        return true
    }
    
    // MARK: - Older version of OS using
    func showOlderOSWarning(continueBlock: @escaping () -> ()) {
        self.popViewController.showInView(self.view, withTitle: StringConstants.ButtonTitles.TLT_Attention, withMessage: StringConstants.StatusMessages.UNSUPPORTED_OS_VERSION, withCloseBtTxt: StringConstants.ButtonTitles.BTN_Understood, withAcceptBt: nil, animated: true, isMessage: false, cancelBlock: {
            continueBlock()
        })
    }
    
    
    
    
    // MARK: - Biomatric Login Authentication
    func registerBioAuth() {
        let biomatType = self.biometricAuth.checkBiometricType(username: self.appInfo.username ?? "")
        keychainAccounts = try! KeychainPasswordItem.passwordItems(forService: Constants.keyChainServiceName, accessGroup: Constants.keyChainAccessGroup)
        
        if let curDomPolicyId = self.biometricAuth.getCurrentDomainPolictyId() {
            if biomatType != BiometricType.none && biomatType != BiometricType.passCodeID {
                // Continue authentication
                self.biometricAuth.authenticateUser(oldDomainStateId: curDomPolicyId, username: self.appInfo.username!, bioType: biomatType) { (message, isCancelled, authFailed, fallbackPass) in
                    
                    if message == nil || isCancelled {
                        if message == nil {
                            let authPolicy = KeychainPasswordItem(service: Constants.keyChainTouchIdDetectionServiceName, account: Constants.keyTouchId, accessGroup: Constants.keyChainAccessGroup)
                            try! authPolicy.savePassword(curDomPolicyId)
                        }
                    }
                    else if fallbackPass {
                        //self.usePasscodeAuth()
                        DispatchQueue.main.async {
                            if let topV = self.navigationController?.topViewController as? RootViewController {
                                topV.showErrorMsg("Passcode entry is not allowed here")
                            }
                            self.loadingView.dismiss()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            if let topV = self.navigationController?.topViewController as? RootViewController {
                                topV.showErrorMsg(message!)
                            }
                            self.loadingView.dismiss()
                        }
                    }
                }
            }
        }
        else {
            // PassId has been changed last time. So after successful Login delete the old policy id and get the new ID from current policy and save it to keychain.
            if (self.isTouchIdChanged) {
                self.isTouchIdChanged = false
                if let touchIdKey = keychainAccounts.first {
                    try! touchIdKey.deleteItem()
                }
                
                if let curDomPolicyId = self.biometricAuth.getCurrentDomainPolictyId() {
                    let touchIdKey = KeychainPasswordItem(service: Constants.keyChainTouchIdDetectionServiceName, account: Constants.keyTouchId, accessGroup: Constants.keyChainAccessGroup)
                    try! touchIdKey.savePassword(curDomPolicyId)
                }
            }
        }
    }
    
    func biometricPassSetup(isFirstLoad:Bool = false) {
        self.biometricAuth.resetAuthentication()
        
        let authType = biometricAuth.checkBiometricType(username: userNaTxtFi.text!)
        if authType == BiometricType.none || authType == BiometricType.passCodeID {
            return
        }
        
        eyeIconImg.image = UIImage(named: (authType == .faceID ? "FaceIdIconWhite" : "TouchIdIconWhite"))
            
        if let appAuthKey = try! KeychainPasswordItem.passwordItems(forService: Constants.keyChainTouchIdDetectionServiceName, accessGroup: Constants.keyChainAccessGroup).first,
            let user = try! KeychainPasswordItem.passwordItems(forService: Constants.keyChainServiceName, accessGroup: Constants.keyChainAccessGroup).first {
            
            let policy = try! appAuthKey.readPassword()
            self.biometricAuth.authenticateUser(oldDomainStateId: policy, username: user.account, bioType: authType, isRegister: false) { (message, isCancelled, authFailed, fallbackPass) in
                if message == nil {
                    DispatchQueue.main.async {
                        self.userNaTxtFi.text = user.account
                        self.passwordTxtFi.text = try! user.readPassword()
                        self.callLoginProcess()
                    }
                } else if let errorMsg = message {
                    DispatchQueue.main.async {
                        if errorMsg == StringConstants.StatusMessages.TOUCH_ID_CHANGE_DETECTION_MSG {
                            self.isTouchIdChanged = true
                            self.showErrorMsg(errorMsg, title: StringConstants.StatusMessages.TOUCH_ID_TEMP_DISABLED, closeBtnTxt:StringConstants.ButtonTitles.BTN_OK, closingDialogBlock: {})
                        }
                        else if authFailed {
                            self.showErrorMsg(StringConstants.StatusMessages.TOUCH_ID_DISABLED)
                        }
                    }
                }
            }
        }
        else if !isFirstLoad{
            self.showErrorMsg(StringConstants.StatusMessages.FIRST_TIME_TOUCH_ID_ERROR)
        }
    }
    
    func saveUserDetailsInKeychain() {
        if let userId = self.userNaTxtFi.text, let password = self.passwordTxtFi.text {
            do {
                if let kcItem = try KeychainPasswordItem.passwordItems(forService: Constants.keyChainServiceName, accessGroup: Constants.keyChainAccessGroup).first {
                    if kcItem.account == userId {
                        try kcItem.savePassword(password)
                    }
                    else {
                        self.deleteBioAuthDetails()
                        try kcItem.deleteItem()
                        let account = KeychainPasswordItem(service: Constants.keyChainServiceName, account: userId, accessGroup: Constants.keyChainAccessGroup)
                        try account.savePassword(password)
                        self.biometricAuth.resetAuthentication()
                    }
                }
                else {
                    let account = KeychainPasswordItem(service: Constants.keyChainServiceName, account: userId, accessGroup: Constants.keyChainAccessGroup)
                    try account.savePassword(password)
                }
                
                self.registerBioAuth()
            } catch {
                Crashlytics.sharedInstance().setObjectValue("\(error)", forKey: "Error Adding/Updating Keychain")
                //Appsee.addEvent("Error adding/updating keychain", withProperties: [Constants.ApiRequestFields.Key_Username: AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId, "Error":  "\(error)"])
            }
        }
    }
            
    func deleteBioAuthDetails() {
        if let touchIdKey = try! KeychainPasswordItem.passwordItems(forService: Constants.keyChainTouchIdDetectionServiceName, accessGroup:Constants.keyChainAccessGroup).first {
            try! touchIdKey.deleteItem()
        }
    }
}
