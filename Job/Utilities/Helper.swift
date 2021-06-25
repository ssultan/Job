import Foundation
import UIKit
import FirebaseAnalytics

class Helper: NSObject {
    
    class func isDeviceIsJailBroken() -> Bool {
    
        #if !STAGE && !DEBUG
            #if arch(i386) || arch(x86_64)
                return true
            #endif
        #endif
        
        let fileChecks = ["/bin/bash",
                          "/etc/apt",
                          "/usr/sbin/sshd",
                          "/Library/MobileSubstrate/MobileSubstrate.dylib",
                          "/Applications/Cydia.app",
                          "/bin/sh",
                          "/var/cache/apt",
                          "/var/tmp/cydia.log",
                          "/private/var/lib/apt"];
        
        for checkPath in fileChecks {
            guard let tempPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending(checkPath) else {
                continue
            }
            
            if FileManager.default.fileExists(atPath: tempPath) {
                return true
            }
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.example.package")!) {
            return true
        }
        return false
    }
    
    class func generateTransmitReportExcel(instArray:[JobInstanceModel]) -> URL? {
        let fileName = "\(AppInfo.sharedInstance.username ?? "")_TransmitReport.csv"
        if let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName) {

            var csvText = "JobName,Program,ProjectNumber,StoreNumber,Address,JobInstanceId,Status,ClientId,CustomerName,AnswerCount,PhotoCount,IsCompleted,StartDate,CompletedDate\n"

            for instance in instArray {
                if let fvArray = instance.jobVisits as? [JobVisitModel] {
                    let counter = self.countTotalPhotosForInstance(jobVisits: fvArray)
                    var address = ""
                    if let location = instance.location {
                        address = "\(location.address ?? ""), \(location.city ?? "") \(location.zipCode ?? "")"
                    }

                    let newLine =
                        "\"\(instance.templateName ?? "")\"," +
                        "\"\(instance.project != nil ? (instance.project.programName ?? "") : "")\"," +
                        "\"\(instance.projectNumber ?? "")\"," +
                        "\"\(instance.location != nil ? (instance.location.storeNumber ?? "") : "")\"," +
                        "\"\(address)\"," +
                        "\"\(instance.instServerId ?? "")\"," +
                        "\"\(instance.status ?? "")\"," +
                        "\"\(instance.instId ?? "")\"," +
                        "\"\(instance.project != nil ? (instance.project.customerName ?? "") : "")\"," +
                        "\"\(counter.ansCount)\"," +
                        "\"\(counter.phCount + instance.documents.count)\"," +
                        "\"\(Bool(truncating: instance.isCompleted) ? true : false)\"," +
                        "\"\(instance.startDate != nil ? Utility.getDateStringFor(formate: "MM-dd-yyyy hh:mm:ss", date:instance.startDate! as Date) : "")\"," +
                        "\"\(instance.completedDate != nil ? Utility.getDateStringFor(formate: "MM-dd-yyyy hh:mm:ss", date:instance.completedDate! as Date) : "")\"\n"

                    csvText.append(contentsOf: newLine)
                }
            }

            do {
                try csvText.write(to: path, atomically:true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
                return nil
            }
            return path
        }
        return nil
    }

    class func countTotalPhotosForInstance(jobVisits:[JobVisitModel]) -> (ansCount:Int, phCount:Int) {
        var photoCount = 0
        var totalAnswers = 0

        for fvModel in jobVisits {
            if let answer = fvModel.answer {
                photoCount += answer.ansDocuments.count
                
                if Bool(truncating: answer.isAnswerCompleted!) == true {
                    totalAnswers += 1
                }
            }

            photoCount = photoCount + self.countPhotoForsubTask(jobVisits: fvModel.subFVModels)
        }
        return (ansCount:totalAnswers, phCount:photoCount)
    }

    class func countPhotoForsubTask(jobVisits:[JobVisitModel]) -> Int {
        var photoCount = 0
        for fvModel in jobVisits {
            if let answer = fvModel.answer {
                photoCount += answer.ansDocuments.count
            }
            return photoCount + self.countPhotoForsubTask(jobVisits: fvModel.subFVModels)
        }
        return photoCount
    }
    
    class func setFireBaseScreenName(className: String) {
        Analytics.setScreenName(Helper.getAppSeeScreenNameForClassName(screenName: className), screenClass: className)
    }
    
    
    class func getAppSeeScreenNameForClassName(screenName: String) -> String {
        
        switch screenName {
        case "LoginViewController":
            return StringConstants.AppseePageTitles.LOGIN_PAGE
            
        case "TermsConditionViewController":
            return StringConstants.AppseePageTitles.TERMS_AND_CONDITION_PAGE
            
        case "MainMenuViewController":
            return StringConstants.AppseePageTitles.MAIN_MENU_PAGE
            
        case "StartJobViewController":
            return StringConstants.AppseePageTitles.SELECT_JOB_PAGE
            
        case "StateCityViewController":
            if let currentPage = AppInfo.sharedInstance.pageAboutToLoad {
                AppInfo.sharedInstance.pageAboutToLoad = nil
                return currentPage
            }
            return "Select State/City Page"
            
        case "SelectLocationViewController":
            return StringConstants.AppseePageTitles.SELECT_LOCATION_PAGE
            
        case "JobVisitInfoViewController":
            return StringConstants.AppseePageTitles.JOB_VISIT_PAGE
            
        case "CompIncompViewController":
            if let currentPage = AppInfo.sharedInstance.pageAboutToLoad {
                AppInfo.sharedInstance.pageAboutToLoad = nil
                return currentPage
            }
            return "Completed/Incompleted Jobs Page"
            
        case "TaskViewController":
            if let currentPage = AppInfo.sharedInstance.pageAboutToLoad {
                AppInfo.sharedInstance.pageAboutToLoad = nil
                return currentPage
            }
            return StringConstants.AppseePageTitles.TASK_PAGE
            
        case "TaskDetailsViewController":
            return StringConstants.AppseePageTitles.TASK_DETAILS_PAGE
            
        case "InstructionViewController":
            return StringConstants.AppseePageTitles.INSTRUCTION_PAGE
            
        case "CommentsViewController":
            return StringConstants.AppseePageTitles.TASK_COMMENT_PAGE
          
        case "PhotoQViewController":
            if let currentPage = AppInfo.sharedInstance.pageAboutToLoad {
                AppInfo.sharedInstance.pageAboutToLoad = nil
                return currentPage
            }
            return "Photo Type Task"
    
        case "PhotoGalleryViewController":
            return StringConstants.AppseePageTitles.PHOTO_GALLERY_PAGE
            
        case "PhotoViewController":
            return StringConstants.AppseePageTitles.FULL_SCREEN_IMG_PAGE
            
        case "PageItemController":
            return StringConstants.AppseePageTitles.FULL_SCREEN_IMG_ITEM_PAGE
            
        case "PhotoDetailsViewController":
            return StringConstants.AppseePageTitles.IMG_INFO_DETAILS_PAGE
            
        case "PanoShooterViewController":
            return StringConstants.AppseePageTitles.DMD_PANO_SHOOTER_PAGE
            
        case "SignatureViewController":
            return StringConstants.AppseePageTitles.SIGNATURE_PAGE
            
        case "NavSummaryVController":
            return StringConstants.AppseePageTitles.NAVIGATION_SUMMARY_PAGE
            
        case "HelpViewController":
            return StringConstants.AppseePageTitles.HELP_PAGE
            
        case "SlideMenuTableView":
            return StringConstants.AppseePageTitles.CONTEXT_MENU_PAGE
            
        case "TransmitReportViewController":
            return StringConstants.AppseePageTitles.TRANSMIT_REPORT_PAGE
            
        case "EmergSendProcVController":
            return StringConstants.AppseePageTitles.FTP_DATA_SEND_PAGE
            
        case "EPSignatureViewController":
            return StringConstants.AppseePageTitles.TAKING_SIGNATURE_PAGE
            
        case "GlobalWebViewController":
            if let currentPage = AppInfo.sharedInstance.pageAboutToLoad {
                AppInfo.sharedInstance.pageAboutToLoad = nil
                return currentPage
            }
            return screenName
            
        case "PDFViewerController":
            return StringConstants.AppseePageTitles.DOCUMENTATION_PAGE
            
        case "WebViewWithAuthVController":
            if let currentPage = AppInfo.sharedInstance.pageAboutToLoad {
                AppInfo.sharedInstance.pageAboutToLoad = nil
                return currentPage
            }
            return screenName
            
        case "CAMPreviewViewController", "UIImagePickerController":
            return StringConstants.AppseePageTitles.DEFAULT_CAMERA_PAGE
            
        case "DMDViewerController":
            return StringConstants.AppseePageTitles.DMD_PANO_VIEWER
        
        case "UIViewController":
            return StringConstants.AppseePageTitles.LOGIN_FIELD_EMTY_ERROR_POPUP
        
        case "PUPhotoPickerHostViewController":
            return StringConstants.AppseePageTitles.Pano_Photo_Picker
            
        default:
            print("\n***************************\(screenName)***************************\n")
            return screenName
        }
    }
    
    class func getMegabytesUsed() -> Float? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                return task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    machPtr,
                    &count
                )
            }
        }
        guard kerr == KERN_SUCCESS else {
            return nil
        }
        return Float(info.resident_size) / (1024 * 1024)
    }
}
