//
//  StringConstants.swift
//  Job V2
//  Job V2
//
//  Created by Saleh Sultan on 8/5/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//


struct StringConstants {
    
    struct StatusMessages {
        
        static let LOADING = "Loading..."
        static let EMAIL_SUBJECT = "Job Support Request"
        static let LOADING_CONFIG_SUBTASKS = "Loading job subtasks..."
        static let FORGOT_USERID_PASS_MSG = "Please check your email. An email has been sent."
        
        // Login Page
        static let DownloadingJobTemp = "Downloading Job Templates..."
        static let LogginDavaco = "Logging into Davaco..."
        static let LoadingConfigTask = "Loading Config Tasks..."
        static let EmptyFieldMsg = "Username or password field is empty."
        static let kInvalidUsernameOrPassword  = "Username or Password is incorrect. Please try again."
        static let kDefaultLoginError          = "Login Failed. Web Services not reachable. Contact Mobile Support."
        static let ACCOUNT_DEAD_LOGIN_ERROR = "We cannot validate your information at this time. Please contact ClearThread&#8217;s Mobile Support at <a href='mailto:mobile.support@clearthread.com'>mobile.support@clearthread.com</a> or call Toll-Free <a href='telprompt:800.478.7593'>800.478.7593</a> during business hours."
        static let ACCOUNT_DEAD_LOGIN_ERROR_ANONYMOUS = "We cannot validate your information at this time. Please contact to your manager"
        static let PASSWORD_EXPIRED_LOGIN_ERROR_ANONYMOUS = "Your password has expired. Please contact to your manager."
        static let PASSWORD_EXPIRED_LOGIN_ERROR = "Your password has expired. Tap Reset to change your password. You may also contact ClearThread&#8217;s Mobile Support at <a href='mailto:mobile.support@clearthread.com'>mobile.support@clearthread.com</a> or call Toll-Free <a href='telprompt:800.478.7593'>800.478.7593</a> during business hours."
        static let ACCOUNT_LOCKEDOUT_LOGIN_ERROR = "Your account is locked out. Tap Reset to change your password. You may also contact ClearThread&#8217;s Mobile Support at <a href='mailto:mobile.support@clearthread.com'>mobile.support@clearthread.com</a> or call Toll-Free <a href='telprompt:800.478.7593'>800.478.7593</a> during business hours."
        static let ERROR_LOGIN_WITH_CONNECTION = "Please login to the application with wireless, or WiFi, connectivity to download assigned load templates";
        static let Request_Timeout_Login = "Looks like the server is taking to long to respond, this can be caused by either poor connectivity or an error with our servers. Please try again in a few minutes."
        static let Request_Timeout_Login_2nd = "Looks like you have poor network connectivity. If you need to completed a job please login with airplane mode turned on."
        static let No_Assigned_Template_Login = "You don't have any assigned job template. Please contact to your manager."
        static let JAILBROKEN_DEVICE_ERROR_MSG_Title = "Jailbroken Device"
        static let JAILBROKEN_DEVICE_ERROR_MSG = "For security reasons, jailbroken devices are not allowed to run ClearThread mobile applications. \nPlease contact Mobile Support if you believe this message is in error."
        static let APPLICATION_FORCE_UPDATE_MSG = "Please install the latest version of the Application."
        static let APPLICATION_OPTIONAL_UPDATE = "There is a new version of the Fuel Advance app, would you like to install?"
        static let INSTANCE_ERROR_GEN_MSG = "Please contact Mobile Support to solve your job issue."
        static let BetaAppWarning = "This is a beta app only to be used in Beta Program. If you are not in the Beta Program, please use the blue Job app."
        static let TOUCH_ID_CHANGE_DETECTION_MSG = "We've detected a change to this device touch ID. Please sign in with your Online ID and Password, so that we can verify your identity. \n\nYou can use Touch ID sign in the next time you open the app."
        static let FIRST_TIME_TOUCH_ID_ERROR = "Please sign in with your Online ID and Password, so that we can verify your identity. \n\nYou can use Touch ID sign in the next time you open the app."
        static let TOUCH_ID_DISABLED = "You've reached the maximum number of attempts to sign in with touch ID. Please enter your password to sign in"
        static let TOUCH_ID_TEMP_DISABLED = "Touch ID is temporarily Disabled"
        static let UNSUPPORTED_OS_VERSION = "We have detected an unsupported version of the Mobile Operating System. Please consider upgrading your iOS operating system or your device."
        static let STORE_LOC_WARNING = "We have detected that you are not within the proximity of the selected physical location. Please validate this is the correct store/location."
        
        // Main menu
        static let LOADING_MENU_DETAILS = "Loading menu details..."
        
        
        static let StoreFrontPhotoReplaceMsg = "You are about to replace the existing photo, would you like to proceed?"
        
        // Transmit Report Page
        static let SuccessfullySent = "Successfully Sent"
        static let SuccessfullyUpdated = "Successfully Updated"
        static let TokenExpired = "Token Expired. Refreshing token..."
        static let InQueue = "In Queue"
        static let SendingJob = "Sending Job..."
        static let UnknownError = "Error: Unknown server error. Please contact Mobile Support."
        static let UnknownErrorInstance = "Error: Failed to Send instance. Unknown server error. Please contact Mobile Support."
        static let TemplateNotAssigned = "Error: You are no longer assigned to this template. Please contact to your manager."
        static let FailedToSendPhoto = "X/XX photos sent. Attempting to resend X photos. Please do not log off."
        static let EMAIL_SENT_SUCCESS = "Email Sent Successfully"
        static let LOADING_ALL_JOBS = "Loading all the jobs..."
        static let Document_Failure_Max_Threshold = "Document upload failure Reached Max Threshould. Please contact Mobile Support."
        
        // Job Visit Info Page
        static let DATA_TRANS_WARNING_HEADER = "Data Transmission Warning"
        static let DATA_TRANS_WARNING_MSG = "Load is in the process of transmission. Please try again later"
        static let DATA_TRANS_ALERT = "One or more loads are in the process of transmission and could not be sent"
        static let TASK_VALIDATION_FAILED = "xx required jobs have not been answered."
        static let Photos_VALIDATION_FAILED = "xx required photos have not been taken."
        static let LOCATION_ACCESS_NEEDED_MSG = "You must need to give access to your location. Please go to your settings and turn on your location service."
        static let NO_CELLULAR_DATA = "Cellular Data is Turned Off for \"Job\". \n\nYou can turn on cellular data for this app in settings."
        static let LOADING_JOB_DETAILS = "Loading job details..."
        static let INITIATING_SEND_PROCESS = "Initiating send process..."
        static let NO_TASK_MSG = "Please logout and log back in to see the jobs"
        static let JOB_COMPLETED = "This job has been completed for this location. Please contact your manager for more information"
        
        
        // Task Details page
        static let END_DATE_EARLY_WARNING = "End date can not be earlier than the start date"
        static let TASK_PHOTO_REQUIRED_MSG = "You need to take a photo before completing the task."
        
        
        // If user hit the Home button, then we allow system to upload all the unsent photos and job in Background.
        static let BG_Upload_Process_Success_Message_Title = "Uploaded Successfully"
        static let BG_Upload_Process_Success_Message = "Background Upload process has been completed."
        static let BG_Upload_Process_Failure_Msg_Title = "Failed to Send Instance"
        
        
        // Global Messages
        static let Request_Timeout = "Error: Request timeout. This can be caused by either poor connectivity or an error with our servers. Please make sure you have a good connection."
        static let Request_Timeout_Global = "Looks like you have an unstable network at the moment, please try again when network stabilizes."
        static let LogoutPopupMsg = "Are you sure, you want to logout?"
        static let Photo_Delete_Msg = "Are you sure, you want to delete this photo?"
        static let NOT_FOUND_ERROR = "Error: Not Found. Please contact Mobile Support."
        static let BAD_REQUEST = "Error: Bad Request. Please try again."
        static let Photo_Access_Denied_WithSettingsURL = "It looks like your privacy settings are preventing us from accessing your camera to take Job Photo. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Turn the Camera on.\n\n3. Open this app and try again."
        static let Photo_Access_Denied_WithOUTSettingsURL = "It looks like your privacy settings are preventing us from accessing your camera to take Job Photo. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Turn the Camera on.\n\n5. Open this app and try again."
        static let Photo_Gallery_Access_Denied_WithSettingsURL = "It looks like your privacy settings are preventing us from accessing your photo gallery to take Job Photo. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Give access of 'Read and Write' to 'Photos'.\n\n3. Open this app and try again."
        static let Photo_Gallery_Access_Denied_WithOUTSettingsURL = "It looks like your privacy settings are preventing us from accessing your photo gallery to take Job Photo. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Give access of 'Read and Write' to 'Photos'.\n\n5. Open this app and try again."
        static let Camera_Access_Denied_WithSettingsURL_For_QRScanner = "It looks like your privacy settings are preventing us from accessing your camera to scan the BarCode/QRCode. You can fix this by doing the following:\n\n1. Touch the Settings button below to open the Settings app.\n\n2. Turn the Camera on.\n\n3. Open this app and try again."
        static let ChangeExisting_Comment_Msg = "Do you want to change the existing comments?"
        static let Wrong_Pano180_Photo_Selected_Msg = "The photo you have selected is not Panoramic. Please select a Panoramic photo."
        static let Same_Pano180_Photo_Selected_Msg = "The photo you have selected is already exist in the photo gallery."
        static let Pano180_Photo_Import_Title = "PANORAMIC PHOTO IMPORT"
        static let PLEASE_WAIT_MSG = "Please wait..."
        
        // Incomplete or Complete Job Page
        static let Job_Not_Assigned_Msg = "You are no longer assigned to this template. Please contact to support center."
        static let Location_InActive = "This location is inactive. Please contact to your project manager."
        static let Sending_Job_Status_Msg = "Sending Job..."
        
        // Location Page
        static let StreetView_Not_Available_Msg_Title = "Not Found"
        static let StreetView_Not_Available_Msg = "Street View is not available for this location."
        static let Redirect_To_Browser_Msg = "You will be redirect to your brower. Are you sure you want to open?"
        
        // For all global web pages
        static let Connection_Error_Msg_Title = "Connection Error"
        static let Connection_Error_Msg = "Please check your internet connection"
        
        // Signature page
        static let Signature_Is_Required_Msg = "Signature is required"
        static let Signature_Name_Required_Msg = "Please enter your name"
        
        
        // Photo Gallery page
        static let Download_photo_Message = "You have some shared photos, that are not downloaded. Would you like to download and view them?"
        
        // Help Page
        static let CallHelpDesk = "Call Mobile Support?"
        static let Device_DoesNot_Support_Call_Msg = "Your device does not support calling a number. Please check your device settings."
        static let Device_DoesNot_Support_Call_Msg_Title = "Could Not Call"
        static let Helpdesk_No_Not_Avaiable = "Mobile Support number is not available. Please send an email."
        static let EmailHelpDesk = "Email Mobile Support?"
        static let Device_DoesNot_Support_Email_Title = "Could Not Send Email"
        static let Device_DoesNot_Support_Email = "Your device could not send e-mail. Please check e-mail configuration and try again."
        
        
        // Emergency Data Sent Page
        static let UPLOADING_FILE_MSG = "UPLOADING ZIPPED FILE..."
        static let ZIPPING_FILES_MSG = "ZIPPING ALL FILES..."
        static let UNABLE_TO_ZIP_FILE_MSG = "UNABLE TO ZIP THE FILES"
        static let ZIP_FILE_UPLOAD_SUCCESS_MSG = "YOUR FILES HAS BEEN\nSUCCESSFULLY UPLOADED!"
        static let UNABLE_TO_UPLOAD_ZIP_FILE_MSG = "UNABLE TO CONNECT FTP SERVER, PLEASE TRY AGAIN"
        static let EMERGENCY_SEND_DATABASE_ONLY = "DATABASE ONLY"
        static let EMERGENCY_SEND_IMG_ONLY = "PHOTOS ONLY"
        static let EMERGENCY_SEND_DATABASE_N_IMG = "DATABASE AND PHOTOS"
    }
    
    // For Dermander 360 Degree pano Photos
    struct DMDStatusMessages {
        static let TXT_HOLD_DEVICE_VERTICAL = "Hold your device vertically"
        static let TXT_MOVE_LEFT_RIGHT = "Rotate left or right or tap to restart"
        static let TXT_ROTATOR_TAKING_PHOTO = "Taking photo, wait to finish"
        static let TXT_KEEP_MOVING = "Tap to finish when ready or continue rotating"
        static let TXT_TAP_TO_START = "Tap anywhere to start"
        static let TXT_TAKING_PHOTO = "Taking Photo"
        static let TXT_ROTATOR_DISCONNECTED = "Rotator disconnected.\nRestart or turn the rotator on"
        static let TXT_BLUETOOTH_UNAUTHORIZED = "Bluetooth access is required. Please enable Bluetooth access from\nSettings > theVRkit > Bluetooth"
        static let TXT_BLUETOOTH_OFF = "Bluetooth should be turned on. Please turn on Bluetooth from\nSettings > Bluetooth"
        static let TXT_CAMERA_ACCESS_REQUIRED_TITLE = "Camera access is required"
        static let TXT_CAMERA_ACCESS_REQUIRED = "Camera access is required.\nPlease enable Camera access from\nSettings > Privacy > Camera"
        static let TXT_SHOOTING_COMPLETED = "Shooting Completed"
    }
    
    // All the Appsee Event we track in our Appsee account
    struct AppseeEventMessages {
        static let Login_Request_Timeout = "Login Request Timeout"
        static let User_Account_Dead = "User Account Dead"
        static let PDF_Loaded_URL = "Loaded URL: http:\\xxxx.xxx"
        static let Login_Error_500 = "Login Error: Unknown Error 500"
        static let Login_Error_405 = "Login Error: 405 Bad request"
        static let Login_Error_404 = "Login Error: 404 Not Found"
        static let Login_Token_Expired = "Login Error: Token Expired 403"
        static let Unknow_Login_Error = "Unknown Login status Error status code: "
        static let WrongUsernamePassword = "Username Or Password Incorrect"
        static let InvalidUser = "User is no longer a valid user"
        static let PasswordExpired = "User Password Expired"
        static let AccountLocked = "User Account Locked"
        static let ManifestError = "User Manifest Error"
        static let UnknownError = "Unknown Error Received"
        static let Failed_Delete_Thumb_Img = "Failed To Delete Thumbnail Photo:"
        static let Template_Not_Assigned = "Template No Longer Assigned"
        static let Failed_To_Get_InstanceId = "Failed to get instanceId for ClientId"
        static let Failed_To_Get_InstanceId_For_Status = "Failed to get instanceId Status"
        static let Token_Expired_BG_SendProcess = "Token Expired."
        static let BAD_REQUEST = "Error: Bad Request. Please try again."
        static let NOT_FOUND_ERROR = "Error: Not Found. Please contact Mobile Support."
        static let Request_Timeout_BG_SendProcess_Photo = "Request timeout at the time of sending photos"
        static let Request_Timeout_BG_SendProcess_Instance = "Request timeout at the time of sending instance"
        static let Failed_To_Upload_Image = "Failed to Send Photo"
        static let Failed_To_Delete_Img = "Failed To Delete Photo: "
        static let Failed_To_Delete_Img_Device = "Failed To Delete Photo from Device"
        static let Failed_To_Update_Instance = "Failed To Update Instance"
        static let Failed_To_Send_Instance = "Failed To Send Instance"
        static let BackSlash_Found_In_Doc = "Found Back-Slash in the JSON"
        static let InstanceId_ClientInstanceId_Not_Found = "InstanceId or ClientInstanceId does not exist in server Database"
        static let InstanceId_ClientId_Empty_In_JSON = "InstanceId or ClientInstanceId is empty in the document JSON"
        static let Empty_Photo_Data_Property = "Document Data property is null or Empty"
    }
    
    struct AppseeScreenAction {
        static let BG_THREAD_STARTED = "Background Thread Started"
        static let APP_WILL_TERMINATE = "Application will terminate now."
        static let START_JOB_CLICKED = "Start New Job Clicked"
        static let INCOMPLETE_CLICKED = "Incomplete Job Clicked"
        static let COMPLETE_CLICKED = "Complete/Unsent Job Clicked"
        static let TEANSMIT_REPO_CLICKED = "Transmit Report Clicked"
        static let HELP_CLICKED = "Help Clicked"
        static let TERMS_AND_CONDITION_CLICKED = "Transmit Report Clicked"
        static let LOGOUT_CLICKED = "Logout Clicked"
        static let START_JOB = "Start Job Clicked"
        static let FV_PHOTO_CLICKED = "JobVisit Photos Clicked"
        static let FV_COMMENTS_CLICKED = "JobVisit Comments Clicked"
        static let SIGNATURE_CLICKED = "Signature Clicked"
        static let CALL_CLICKED = "Call Btn Clicked"
        static let EMAIL_CLICKED = "Email Btn Clicked"
        static let DOCUMENTATION_CLICKED = "Documentation Btn Clicked"
        static let SUPPORTED_DEVICE_CLICKED = "Supported Device Btn Clicked"
        static let SUPPORTED_OS_CLICKED = "Supported OS Btn Clicked"
        static let Q_NEXT_BTN_CLICKED = "Next Btn Clicked"
        static let Q_PREV_BTN_CLICKED = "Back Btn Clicked"
        static let PHOTO_BTN_CLICKED = "Photo Btn Clicked"
        static let COMMENT_BTN_CLICKED = "Comment Btn Clicked"
        static let INFO_BTN_CLICKED = "Info Btn Clicked"
        static let SIGNATURE_FRAME_CLICKED = "Signature Frame Clicked"
        static let PHOTO_EDIT_CLICKED = "Photo Edit Btn Clicked"
        static let PHOTO_DELETE_CLICKED = "Photo Delete Btn Clicked"
        static let NAV_MAIN_MENU_TAPPED = "Tapped Button \"Main Menu\""
        static let NAV_UNANSWERED_TAPPED = "Tapped Button \"Unanswered Only\""
        static let NAV_LOGOUT_TAPPED = "Tapped Button \"Logout\""
        static let NAV_JOB_INFO_TAPPED = "Tapped Button \"Job Info\""
        static let NAV_SHOW_ALL_TAPPED = "Tapped Button \"Show All\""
        static let GOOGLE_STREETVIEW_CLICKED = "StreetView Btn Clicked"
        static let MAP_DIRECTION_CLICKED = "Map Btn Clicked"
        static let HAMBURGER_MENU_TAPPED = "Tapped Button \"Hamburger Menu\""
        static let SELECT_ALL_CHECKED = "Select All Checked"
        static let UNSELECT_ALL_CHECKED = "UnSelect All Checked"
    }
    
    struct AppseePageTitles {
        static let LOGIN_PAGE = "Login Page"
        static let TERMS_AND_CONDITION_PAGE = "Terms And Conditions Page"
        static let MAIN_MENU_PAGE = "MainMenu Page"
        static let SELECT_JOB_PAGE = "Start New Job Page"
        static let SELECT_STATE_PAGE = "Select State Page"
        static let SELECT_CITY_PAGE = "Select City Page"
        static let SELECT_LOCATION_PAGE = "Select Location Page"
        static let JOB_VISIT_PAGE = "Job Info Page"
        static let COMPLETED_JOB_PAGE =  "Completed Job Page"
        static let INCOMPLETED_JOB_PAGE = "Incomplete Job Page"
        static let TASK_PAGE = "Task Page"
        static let END_OF_JOB = "End of Job"
        static let INSTRUCTION_PAGE = "Instruction Page"
        static let TASK_COMMENT_PAGE = "Task Comments List Page"
        static let PHOTO_GALLERY_PAGE = "Photo Gallery Page"
        static let FULL_SCREEN_IMG_PAGE = "Full Screen Image Page"
        static let FULL_SCREEN_IMG_ITEM_PAGE = "Full Screen Image Item Page"
        static let IMG_INFO_DETAILS_PAGE = "Image Information Details Page"
        static let DMD_PANO_SHOOTER_PAGE = "DMD Pano Shooter Page"
        static let SIGNATURE_PAGE = "Job Confirmation Signature Page"
        static let NAVIGATION_SUMMARY_PAGE = "Job Navigation Summary Page"
        static let HELP_PAGE = "Help Page"
        static let CONTEXT_MENU_PAGE = "Context Menu Page"
        static let TRANSMIT_REPORT_PAGE = "Transmit Report Page"
        static let FTP_DATA_SEND_PAGE = "Send Data to FTP Server Page"
        static let TAKING_SIGNATURE_PAGE = "Taking Signature Page"
        static let GOOGLE_STREETVIEW_PAGE = "Google StreetView Page"
        static let CLEARTHREAD_DOC_PAGE = "ClearThread Documentation Page"
        static let FORGOT_USERNAME_PASSWORD_PAGE = "Forgot Username or Password/Reset Password Page"
        static let RESET_PASSWORD_PAGE = "Reset Password Page"
        static let APPROVED_DEVICE_PAGE = "Approved Devices Page"
        static let APPROVED_OS_PAGE = "Approved OS Page"
        static let DOCUMENTATION_PAGE = "Documentation Page"
        static let DEFAULT_CAMERA_PAGE = "iOS Default Camera Page"
        static let DMD_PANO_VIEWER = "DMD Pano Viewer"
        static let LOGIN_FIELD_EMTY_ERROR_POPUP = "Empty TextBox Error Popup"
        static let Pano_Photo_Picker = "180 Pano Photo Picker view"
        static let TASK_DETAILS_PAGE = "Task Detail Page"
        static let TASK_PARENT_PAGE = "Task Parent Page"
        static let WHATs_NEW_PAGE = "What's New Page"
    }
    
    struct PageTitles {
        static let FTP_PAGE_TLT = "EMERGENCY SEND DATA"
        static let FORGOT_PASSWORD_PAGE_TLT = "RETRIEVE USER DETAILS"
        static let MAIN_MENU_PAGE_TLT = "MAIN MENU"
        static let COMPLETE_JOB_PAGE_TLT = "COMPLETE JOBS"
        static let INCOMPLETE_JOB_PAGE_TLT = "INCOMPLETE JOBS"
        static let SELECT_JOB_PAGE_TLT = "SELECT A JOB"
        static let SELECT_STATE_PAGE_TLT = "SELECT STATE"
        static let SELECT_CITY_PAGE_TLT = "SELECT CITY"
        static let SELECT_LOCATION_PAGE_TLT = "SELECT LOCATION"
        static let GOOGLE_STREET_VIEW_PTLE = "STREET VIEW"
        static let JOB_PAGE_TITLE = "JOB INFO"
        static let SIGN_PAGE_TLT = "SIGNATURE"
        static let SAVE_JOB_PAGE_TLT = "COMPLETE VISIT"
        static let Comment_PAGE_TLT = "COMMENT"
        static let FV_PHOTO_GALLERY_TLT = "JOB PHOTOS"
        static let ANS_PHOTO_GALLERY_TLT = "TASK PHOTOS"
        static let PHOTO_PAGE_TLT = "PHOTO"
        static let PHOTO_DETAILS_PAGE_TLT = "DETAILS"
        static let SUMMARY_PG_TLT = "SUMMARY"
        static let HELP_PG_TLT = "HELP"
        static let DOCUMENATION_PG_TLT = "DOCUMENTATION"
        static let SUPPORTED_DEVICE_PG_TLT = "SUPPORTED DEVICES"
        static let TMS_N_CONDS_PG_TLT = "TERMS AND CONDITIONS"
        static let VIDEO_TUTORIAL_PG_TLT = "TUTORIALS"
        static let TRANSMIT_REPORT_PG_TLT = "TRANSMIT REPORT"
        static let RESET_PASSWORD_PG_TLT = "RESET PASSWORD"
        static let JOB_TASKS_PG_TLT = "JOB TASKS"
        static let SEARCH_LOCATION_PG_TLT = "SEARCH LOCATION"
        static let APPROVED_OS_PG_TLT = "APPROVED OS"
    }
    
    struct ButtonTitles {
        static let BTN_Rotator = "ROTATOR"
        static let BTN_Handheld = "HANDHELD"
        static let BTN_Cancel = "CANCEL"
        static let BTN_GO_BACK = "GO BACK"
        static let BTN_Close = "CLOSE"
        static let BTN_Understood = "UNDERSTOOD!"
        static let BTN_TRY_AGAIN = "TRY AGAIN"
        static let BTN_GOT_IT = "GOT IT!"
        static let BTN_SEND = "SEND"
        static let BTN_SAVE = "SAVE"
        static let BTN_SEND_ALL = "SEND ALL"
        static let BTN_GO = "GO"
        static let BTN_OK = "OK"
        static let BTN_W_OK = "OK!"
        static let BTN_PROCEED = "PROCEED"
        static let BTN_DOWNLOAD = "DOWNLOAD"
        static let BTN_TAKE_PHOTO = "TAKE PHOTO"
        static let BTN_OPN_TUTORIAL = "OPEN TUTORIAL"
        static let BTN_SETTINGS = "SETTINGS"
        static let BTN_LOGIN_OFFLINE = "LOGIN OFFLINE"
        static let BTN_NAVIGATE = "NAVIGATE"
        static let BTN_RESET = "RESET"
        static let BTN_COMMENT = "COMMENT"
        static let BTN_DELETE = "DELETE"
        static let BTN_LOGOUT = "LOGOUT"
        static let BTN_CALL = "CALL"
        static let BTN_EMAIL = "EMAIL"
        static let BTN_DONE = "DONE"
        static let BTN_CONTINUE = "CONTINUE"
        static let BTN_PHOTO = "PHOTO"
        static let BTN_SUCESS = "SUCCESS"
        static let BTN_CHOOSE_PHOTO = "CHOOSE PHOTO"
        static let TLT_Warning = "WARNING"
        static let TLT_Attention = "ATTENTION!"
        static let TLT_Message = "MESSAGE"
        static let TLT_NO_CELLULAR_DATA = "Cellular Data is Turned Off for \"Job\" app"
        static let TLT_Caution = "CAUTION!"
        static let TLT_Update = "UPDATE"
        static let TLT_HOLD_UP = "HOLD UP!"
        static let TLT_COMMENTS_REQ = "COMMENT REQUIRED"
        static let TLT_ADD_COMMENT = "ADD COMMENT"
        static let TLT_SIGN_REQUIRED = "SIGNATURE IS REQUIRED"
        static let TLT_NO_CODE = "NO CODE"
        static let TLT_CLEARTHREAD = "CLEARTHREAD"
        static let TLT_BARCODE_NUMBER = "BARCODE NUMBER"
        static let TLT_QUES_INSTRUCTIONS = "TASK INSTRUCTION"
        static let OPEN_TRANSMIT_REPORT = "OPEN TRANSMIT REPORT"
    }
    
    struct MenuTitles {
        static let MAIN_MENU = "MAIN MENU"
        static let HELP = "MOBILE SUPPORT"
        static let LOGOUT = "LOG OUT"
        static let TUTORIALS = "TUTORIALS"
        static let EMAIL = "EMAIL TRANSMIT REPORT"
        static let DEBUGGER = "DEBUGGER"
        static let ABOUT_US = "ABOUT US"
        static let START_NEW_JOB = "START NEW JOB"
        static let INCOMPLETE_JOBS = "INCOMPLETE JOBS"
        static let COMPLETE_JOBS = "COMPLETE/UNSENT JOBS"
        static let TRANSMIT_REPORT = "TRANSMIT REPORT"
        static let TERMS_AND_CONDITIONS = "Terms and Conditions"
        static let START_JOB = "START JOB"
        static let JOB_VISIT_PHOTOS =  "JOB PHOTOS"
        static let JOB_VISIT_COMMENTS =  "JOB COMMENTS"
        static let OUT_OF_SCOPE       =  "OUT OF SCOPE"
        static let SIGNATURE = "SIGNATURE"
        static let JOB_VISIT_INFO = "JOB INFO"
        static let REFRESH_JOB_INFO = "REFRESH JOB"
        static let UNANSWERED_ONLY = "SHOW UNANSWERED TASKS"
        static let SHOW_ALL_QUES = "SHOW ALL TASKS"
        static let CALL_HELP_DESK = "CALL MOBILE SUPPORT"
        static let EMAIL_HELP_DESK = "EMAIL MOBILE SUPPORT"
        static let DOCUMENTATION = "DOCUMENTATION AND TUTORIALS"
        static let SUPPORTED_DEVICES = "SUPPORTED DEVICES"
        static let SUPPORTED_OS = "SUPPORTED OS"
        static let WHATS_NEW = "WHAT'S NEW"
    }
    
    struct ConnectivityStatus {
        static let Restricted   = "Restricted"
        static let Wifi         = "Wifi"
        static let Cellular     = "Cellular"
        static let Unknown      = "Unknown"
    }
}
