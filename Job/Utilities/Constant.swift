//
//  Constant.swift
//  Job V2
//
//  Created by Saleh Sultan on 8/5/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//


struct Constants {
    
    // Keys
    struct Keys {
        static let GOOGLE_SERVICE_KEY  = "AIzaSyACW2h9FePO5TzXZnjsaJyostSGGUyjyhk"
        static let AppSeeKey = "249d3b3c60cd4e01b37a94f8c5bbae89"
        static let ClearthreadBackdoorLoginKey = "toughsecurity"
    }
    
    // Background Thread refresh interval
    static let BGThreadRefreshInerval = 30
    static let OfflineLoginAllowedDays = 15
    static let LocalBackupDataIntTime = 30
    static let ErrorThresholdMaxCounter = 100
    static let DocErrorThresholdMaxCounter = 100
    static let photoAckReqWaitingTimeInMin = 1
    static let MAX_INST_COMMENT_CHAR_ALLOWED = 2000
    static let MAX_ANS_COMMENT_CHAR_ALLOWED = 4000
    
    static let keyChainServiceName = "JobLoginService"
    static let keyChainAccessGroup:String? = nil
    static let keyChainTouchIdDetectionServiceName = "JobTouchIdDetection"
    static let keyTouchId:String = "JobTouchId"
    
    static let JobBgUpService = "UploadJobInstance"
    static let Empty_Photo_No_Name = "Empty_Photo_No_Name"
    
    static let FTP_UserName = "atest"
    static let FTP_Password = "d@v@c013"
    static let Anonymous_User = "Anonymous"
    static let Anonymous_Initial = "ct-"
    static let Anonymous_Initial2 = "ct."
    static let SERVER_EXP_DATE_FORMATE = "yyyy-MM-dd'T'HH:mm:ss"
    static let SERVER_EXP_DATE_FORMATE_2nd = "yyyy-MM-dd'T'HH:mm:ss.SS"
    static let SERVER_EXPECT_DATE_FORMAT_WITH_ZONE = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

    
    struct Environments {
        static let kStaging = "Staging"
        static let kDevelopment = "Dev"
        static let kProdUAT = "UAT"
        static let kProduction = "Production"
        static let kRelease = "Release"
        static let kApiTest = "APITEST"
    }
    static let kSelectedEnvironment = "SelectedEnvironment"
    static let kFV_REPORT = "Transmit Report"
    
    //Request Headers
    struct RequestHeaders {
        static let Authorization       = "Authorization"
        static let DeviceID            = "Device"
        static let CTClient            = "client-type"
        static let SDKVersion          = "SDKVersion"
        static let Manufacturer        = "Manufacturer"
        static let Product             = "Product"
        static let DeviceModel         = "Model"
        static let AppVersion          = "Version"
        static let RegistrationId      = "RegistrationId"
        static let Content_Type        = "Content-Type"
        static let Accept_Type         = "Accept"
        static let DeviceManufacturer  = "Apple"
        static let kEULAAcceptedDict   = "EULAAcceptedDict"
        static let kClientType         = "iOS"
    }
    
    
    static let DataSendRecType  = "application/json"
    static let ImageMimeType    = "image/jpeg"
    static let DocImageType     = "Image"
    static let DocVideoType     = "Video"
    static let DocSignatureType = "Signature"
    
    
    //Document Type
    static let JPEG_DOC_TYPE    = "jpeg"
    static let PNG_DOC_TYPE     = "png"
    static let VIDEO_DOC_TYPE   = "mp4"
    
    
    static let BackArrowImgName = "ArrowLeftIcon"
    
    
    struct LensNames {
        static let OLLOCLIP1    = "Olloclip1"
        static let MANFROTTO1   = "Manfrotto1"
        static let IPRO1        = "Ipro1"
        static let LENS180S1    = "Lens180S1"
        static let LENS160M1    = "Lens160M1"
    }
    
    
    //EntityNames
    struct EntityNames {
        static let UserEntity           = "User"
        static let ManifestEntity       = "Manifest"
        static let TemplateEntity       = "JobTemplate"
        static let LocationEntity       = "Location"
        static let ProjectEntity        = "Project"
        static let TaskEntity           = "Task"
        static let AnswerEntity         = "Answer"
        static let JobInstanceEntity    = "JobInstance"
        static let CommentEntity        = "Comment"
        static let DocumentEntity       = "Document"
        static let ErrorLogs            = "ErrorLogs"
        static let ApiMessageLog        = "ApiMessageLog"
    }
    
    //API Services
    struct APIServices {
        static let loginServiceAPI       = "/api/Login"
        static let manifestServiceAPI    = "/api/Manifest?userName="
        static let templateServiceAPI    = "/api/template/"
        static let locationServiceAPI    = "/api/project/"
        static let sendInstanceServiceAPI = "/api/simpleinstance/"
        static let sendJobInstanceQueueAPI = "/api/JobInstanceQueue/"
        static let GetAllInstanceDocumentsAPI = "/api/instance/"//{0}/documents
        static let GetAllInstanceDocumentsAPI2nd = "/api/document?instanceid="
        static let DocumentAPI     = "/api/Document/"
        static let DocumentDeleteUpdateAPI     = "/api/MobileDocument/"
        static let GetInstanceIdForClientId = "/api/Instance?clientid="
        static let GET_InstanceStatusUpdate = "/api/instance/status/"
        static let GET_SharedInstance = "/api/instance/SharedInstance/"

    }
    
    struct FileNames {
        static let AccountDeadHTMLFile = "accountdead";
        static let AccountLockedOutHTMLFile = "accountlockedout";
        static let PasswordExpiredHTMLFile = "passwordexpired";
    }
    
    struct Clearthread {
        static let FTP_HOSTNAME = "ftp.davacoinc.com"
        static let APP_UPDATE_URL        = "itms-services://?action=download-manifest&url="
        static let Documentation         = "http://mobileapps.davacoinc.com/m/TaskDocuments.aspx"
        static let AnonymousDocuments    = "https://apps.davacoinc.com/Apps/home/Documents"
        static let ApprovedDeviceListURL = "http://davacoworks.com/approved_devices.html"
        static let ApprovedDeviceOSURL   = "http://portal.davacoinc.com/sites/ops/techblog/Lists/Posts/AllPosts.aspx"
        static let kForgotPasswordURL    = "/_login/ClearThread/UnableToLogin.aspx"
        static let WhatsNewURL           = "http://davacoworks.com/whatsnew/index.html"
    }
    
    
    static let IMAGE_COMPRESSION_RATIO = 0.6
    static let LOGO_YELLOW_COLOR = UInt(0xFFD700)
    static let BLUE_COLOR = UInt(0x0D68DF)
    static let PHOTO_COUNTER_RED_COLOR = UInt(0xFF0008)
    
    //Notification Names
    struct NotificationsName {
        static let RELOAD_TABLE_NOTIFY = "ReloadTableNotification"
        static let IMAGE_WEBVIEW_TOUCHED_NOTIFY = "ImageViewTouched"
        static let OPEN_TRANS_REPO_NOACTION = "OPEN_TRANS_REPO_NOACTION"
        static let OPEN_SENT_REPORTS = "OPEN_SENT_REPORTS"
        static let SHOW_OFFLINE_LOGIN_POPUP_NOTIFY = "SHOW_OFFLINE_LOGIN_POPUP"
        static let RELOAD_CONFIG_TASKS = "RELOAD_CONFIG_TASKS"
        static let ReloadReportTableNotifier = "ReloadReportTableNotifier"
        static let SendEmailNotifier = "SendEmailNotifier"
        static let MENU_BTN_CLICKED_NOTIFY = "MENU_BTN_CLICKED_NOTIFY"
        static let RELOAD_GALLERY_NOTIFY = "ReloadGalleryGrid"
    }
    
    static let DMD_LENS_SELECTOR_REUSABLE_ID = "LensSelector"
    static let DMD_CURRENT_SELECTED_LENS_KEY = "currentSelectedLens"
    static let TEMP_SPHERICAL_PHOTO_NAME = "/global_360_spherical_photo.jpeg"
    static let ThumbImagesFolder = "ThumbImages"
    static let TASK_RESULT_TRUE   = "true"
    static let TASK_RESULT_FALSE  = "false"
    
    
    static let SERVER_EXPECT_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    
    // Keys or Fields name at the time send instance
    struct ApiRequestFields {
        static let Key_Username        = "Username"
        static let Key_Password        = "Password"
        static let Key_Token           = "Token"
        static let Key_FullName        = "FullName"
        static let Key_RoleName        = "RoleName"
        static let Key_Id              = "Id"
        static let Key_ClientId        = "ClientId"
        static let Key_UserId          = "UserId"
        static let Key_UserName        = "UserName"
        static let Key_TemplateId      = "TemplateId"
        static let Key_ProjectId       = "ProjectId"
        static let Key_LocationId      = "LocationId"
        static let Key_StartedOn       = "StartedOn"
        static let Key_CompletedOn     = "CompletedOn"
        static let Key_DeviceId        = "DeviceId"
        static let Key_Comments        = "CommentList"
        static let Key_CtPostsList     = "CtPostsList"
        static let Key_Answers         = "Answers"
        static let Key_Flagged         = "Flagged"
        static let Key_DocumentCount   = "DocumentCount"
        static let Key_AuthorizedUserName = "AuthorizedUserName"
        static let Key_ErrorCode       = "ErrorCode"
        static let Key_Message         = "Message"
        
        //Comment
        static let Key_CommentTxt      = "Text"
        static let Key_LastUpdatedOn   = "LastUpdatedOn"
        static let Key_LastUpdateBy    = "LastUpdatedBy"
        static let Key_CommentId       = "Id"
        
        //Answer
        static let Key_QuestionId      = "QuestionId"
        static let Key_Value           = "Value"
        static let Key_SetNumber       = "SetNumber"
        static let Key_StartDate       = "Start"
        static let Key_EndDate         = "End"
        
        //Document
        static let Key_InstanceId      = "InstanceId"
        static let Key_AnswerId        = "AnswerId"
        static let Key_MimeType        = "MimeType"
        static let Key_QuestionNumber  = "QuestionNumber"
        static let Key_Data            = "Data"
        static let Key_DocumentId      = "DocumentId"
        static let Key_ClientInstanceId = "ClientInstanceId"
        static let Key_ClientAnswerId  = "ClientAnswerId"
        static let Key_Ordinal         = "Ordinal"
        static let Key_Width           = "Width"
        static let Key_Height          = "Height"
        static let Key_AttributeId     = "AttributeId"
        static let Key_Attribute       = "Attribute"
        static let Key_ResolutionId    = "ResolutionId"
        static let Key_Resolution      = "Resolution"
        static let Key_CategoryId      = "CategoryId"
        static let Key_Category        = "Category"
        static let Key_Tag             = "Tag"
        static let Key_Name            = "Name"
        static let Key_CreatedOn       = "CreatedOn"
        
        
        static let Key_FieldVisitId    = "FieldVisitId"
        static let Key_SurveyAnswerId  = "SurveyAnswerId"
        static let Key_Documents       = "Documents"
    }
    
    struct BgUIUpdateNotifierKeys {
        static let KeyInstanceId = "instanceId"
        static let KeyUserId = "UserId"
        static let KeyStatus     = "status"
        static let KeyInstanceSentTime = "instanceSuccSentTime"
        static let KeyInstServerId = "instanceServerId"
        static let KeyInstTempId = "KeyInstTempId"
        static let KeyInstProjId = "KeyInstProjId"
        static let KeyInstLocId = "KeyInstLocId"
    }
}



public enum ResolutionType: String {
    case DefaultPhoto   = "DefaultPhoto"
    case Pano180Photo   = "Pano180Photo"
    case SphericalPhoto = "SphericalPhoto"
    case HDPhoto        = "HDPhoto"
    
    func getResolutionId() -> Int {
        switch self {
        case .DefaultPhoto:
            return 1
        case .Pano180Photo:
            return 2
        case .SphericalPhoto:
            return 3
        case .HDPhoto:
            return 4
        }
    }
    
    func getResolution(resId: Int) -> ResolutionType {
        switch resId {
        case 1:
            return .DefaultPhoto
        case 2:
            return .Pano180Photo
        case 3:
            return .SphericalPhoto
        case 4:
            return .HDPhoto
        default:
            return .DefaultPhoto
        }
    }
}


enum PhotoAttributesTypes: String {
    case Before         = "Before"
    case After          = "After"
    case General        = "General"
    case Left_Before    = "Left-Before"
    case Left_After     = "Left-After"
    case Center_Before  = "Center-Before"
    case Center_After   = "Center-After"
    case Right_Before   = "Right-Before"
    case Right_After    = "Right-After"
    case Additional     = "Additional"
    case FieldVisit     = "FieldVisit"
    case Signature      = "Signature"
    
    static let allValues = [Before, After, Left_Before, Left_After, Center_Before, Center_After, Right_Before, Right_After, General, Additional]
    
    func attributeShortForm() -> String {
        switch self {
        case .Before :
            return  "B"
        case .After  :
            return  "A"
        case .General  :
            return  "G"
        case .Left_Before  :
            return  "LB"
        case .Left_After  :
            return  "LA"
        case .Center_Before  :
            return  "CB"
        case .Center_After  :
            return  "CA"
        case .Right_Before  :
            return  "RB"
        case .Right_After  :
            return  "RA"
        case .Additional  :
            return  "AD"
        case .FieldVisit  :
            return  "FV"
        case .Signature:
            return  "SIGN"
        }
    }
    
    func getAttributeId() -> String {
        switch self {
        case .Before :
            return  "1"
        case .After  :
            return  "2"
        case .General  :
            return  "3"
        case .Left_Before  :
            return  "4"
        case .Left_After  :
            return  "5"
        case .Center_Before  :
            return  "6"
        case .Center_After  :
            return  "7"
        case .Right_Before  :
            return  "8"
        case .Right_After  :
            return  "9"
        case .Additional  :
            return  "10"
        case .FieldVisit  :
            return  "3" // Because photo attribute expect a attributeID. it's medatory for make a request.
        case .Signature:
            return  "3" // Because photo attribute expect a attributeID. it's medatory for make a request.
        }
    }
}


enum NavPushDirection: String {
    case Left       = "Left"
    case Right      = "Right"
    case Top        = "Top"
    case Bottom     = "Bottom"
}


enum OfflineLoginStatus: Int {
    case LoginSuccess = 1
    case PasswordNotMatched = 2
    case LastLoginTimeout = 3
    case UserNotFound = 4
}


enum HttpRespStatusCodes: Int {
    case HTTP_200_OK = 200
    case TokenExpiredCode = 403
    case BadRequestCode = 405
    case NotFoundCode = 404
    case RequestTimeOut = 999 // This is a custom error code that I made
    case RequestHasErrorCode = 500
}

enum LoginRequestErrCode: Int {
    case LogonFailed = 1123512
    case UserTerminated = 1123513
    case UserLockedOut = 1123514
    case PasswordExpired = 1123515
    case UserDuplicate = 1123516
    case GenManifestError = 112351
}

enum SendProcErrorCode: Int {
    case UnknownErrorCode = 11235               //Unknown Error
    case InvalidBackSlash = 1123511             //Invalid: Message: "Image Data contains invalid double-backslash characters"
    case DocumentDataNullorEmpty = 112354       //EmptyRequiredField, Message "Data property of a document must not be null OR Empty
    case InsertFailed = 112355              //Insert Failed
    case InstIdorClientIdNullInJSON = 1123517   //ForeignKeyConstraint, Message: “InstanceId or ClientInstanceId must be present. Instance must exist before document can be created.
    
    case InstDoesNotExistOrDeletedInServerDB = 112356   //ForeignKeyConstraint, Message: "Instance not found for InstanceId or ClientInstanceId
    case DuplicateItmAvailInServerDB = 11235600 //Already Exists
}

enum TaskType: String {
    case ParentTask = "0"
    case SubTask = "1"
    
    
    func getTaskName() -> String {
        switch self {
        case .ParentTask :
            return "MasterTask"
        default:
            return "SubTask"
        }
    }

}
