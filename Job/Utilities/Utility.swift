//
//  Utility.swift
//  Job V2
//
//  Created by Saleh Sultan on 8/4/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//


import ImageIO
import JGProgressHUD
import Reachability
import CoreTelephony
import UserNotifications
//import Appsee

class Utility: NSObject {
    
    class func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    class func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
    class func showCustomMsg(_ curView:UIView, label: String, detailslbl:String?, isSuccessImg: Bool, duration:Int64 = 1, completion:@escaping ()->()) {
        
        let progressInd = JGProgressHUD(style: .extraLight)
        progressInd.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(named: (isSuccessImg ? "BlueCheckMark" : "RedCrossIconSm"))!)
        progressInd.textLabel.text = label
        progressInd.detailTextLabel.text = detailslbl
        progressInd.show(in: curView, animated: true)
        progressInd.dismiss(afterDelay: TimeInterval(duration))
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(duration))) {
            completion()
        }
    }
    
    class func checkInternetConnection(_ completion:@escaping (_ isRechable:Bool, _ connectionType:String?)->()) {
        do {
            let reachability = try Reachability()
            if reachability.connection == .wifi {
                completion(true, StringConstants.ConnectivityStatus.Wifi)
            }
            else if reachability.connection ==  .cellular {
                completion(true, StringConstants.ConnectivityStatus.Cellular)
            }
            else if reachability.connection == .unavailable {
                completion(false, StringConstants.ConnectivityStatus.Unknown)
            }
            else {
                completion(false, nil)
            }
        }
        catch {
            completion(false, nil)
        }
    }
    
    class func updateDcoumentNameFor(oldDocName: String, documentType docType: String, updateDate date: Date = Date()) -> String {
        let nameArr = oldDocName.components(separatedBy: "_")
        
        var newDocName = ""
        for idx in 0 ..< nameArr.count-2 {
            newDocName = "\(newDocName)\(nameArr[idx])_"
        }
        
        newDocName = "\(newDocName)\(getDateStringFor(formate: "yy-MM-dd_hh:mm:ss", date: date)).\(docType)"
        return newDocName
    }
    
    class func generateDcoumentNameFor(projectNumber projNo:String?,
                                       storeNumber: String?,
                                       taskNumber taskNo:String?,
                                       attribute type:PhotoAttributesTypes,
                                       documentType docType: String,
                                       forDate date: Date = Date()) -> String {
        var docName = ""
        if let tNo = taskNo {
            docName = "\(tNo)_"
        } else {
            docName = "FV_"
        }
        
        if let locSNo = storeNumber {
            docName = "\(docName)\(locSNo)_"
        }
        
        if let projectNo = projNo {
            docName = "\(docName)\(projectNo)_"
        }
        
        let val = type.attributeShortForm()
        docName = "\(docName)\(val)_"
        docName = "\(docName)\(getDateStringFor(formate: "yy-MM-dd_hh:mm:ss", date: date)).\(docType)"
        
        return docName
    }
    
    
    class func getDateStringFor(formate: String, date:Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        
        let timeStump = formatter.string(from: date)
        return timeStump
    }
    
    class func getImageFromDocumentDirectory(docName: String, folderName:String) -> UIImage? {
        
        if let dir = getPhotoParentDir(imgName: docName, folderName: folderName) {
            let path = dir.appendingPathComponent(docName).path
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
    
    class func getThumbnailImageFromDocumentDirectory(docName: String, folderName:String) -> UIImage? {
        if let thumbDir = getPhotoThumbnailDir(imgName: docName, folderName: folderName) {
            return UIImage(contentsOfFile: thumbDir.appendingPathComponent(docName).path)
        }
        return nil
    }
    
    class func getImageFullPath(docName: String, folderName:String) -> String? {
        if let dir = getPhotoParentDir(imgName: docName, folderName: folderName) {
            return dir.appendingPathComponent(docName).path
        }
        return nil
    }
    
    
    // Save document in application document folder after converting them into JPEG format
    class func saveDocumentInDocumentDirectory(document: UIImage, docName: String, folderName:String, imgMetaDataDic: NSDictionary, lossyData:Bool) -> Data? {
        guard let instanceDir = getInstanceFolder(folderName: folderName) else {
            return nil
        }

        let path = instanceDir.appendingPathComponent(docName)
        if let imgData = document.addImageMetadata(photoName: docName, photoCreator: AppInfo.sharedInstance.username ?? "", photoDesc: "Job app photo taken by \(AppInfo.sharedInstance.username ?? "")", imgMetaDataDic: imgMetaDataDic, lossyData: lossyData)
        {
            do {
                try imgData.write(to: path, options: .completeFileProtectionUnlessOpen)
                return imgData
            } catch {
                return nil
            }
        }
        return nil
    }
    
    
    // Save document in application document folder after converting them into JPEG format
    class func savePhotoInDocumentDirectoryNew(photo: UIImage, documentObj: DocumentModel, lossyData:Bool) -> Data? {
        guard let instanceDir = getInstanceFolder(folderName: documentObj.instanceId!), let instance = AppInfo.sharedInstance.selJobInstance else {
            return nil
        }

        let path = instanceDir.appendingPathComponent(documentObj.originalName!)
        //let locationAddress = "\(instance.location.address ?? ""), \(instance.location.city ?? ""), \(instance.location.state ?? ""), \(instance.location.zipCode ?? "")"
        let photoDetailsDic:[CFString: CFString] = ["Username" as CFString: (AppInfo.sharedInstance.username ?? "") as CFString,
                                                    "PhotoId" as CFString: documentObj.documentId! as CFString,
                                                    "InstanceClientId" as CFString: documentObj.instanceId! as CFString,
                                                    "PhotoName" as CFString: documentObj.originalName! as CFString,
                                                    "SurveyName" as CFString: instance.template.templateName! as CFString,
                                                    "ProjectNumber" as CFString: instance.projectNumber! as CFString,
                                                    "LocationNumber" as CFString: instance.location.storeNumber! as CFString,
                                                    "CreatedDate" as CFString: documentObj.createdDate!.convertToString(format: Constants.SERVER_EXP_DATE_FORMATE) as CFString]

        if let imgData = photo.addImageMetadata(photoName: documentObj.originalName!, photoCreator: AppInfo.sharedInstance.username ?? "", photoDesc: String(describing: photoDetailsDic), imgMetaDataDic: documentObj.exifDic!, lossyData: lossyData)
        {
            do {
                try imgData.write(to: path, options: .completeFileProtectionUnlessOpen)
                return imgData
            } catch {
                return nil
            }
        }
        return nil
    }
    
    
    class func saveDocumentInDocumentDirectory(image: UIImage,  docName: String, folderName:String) -> Data? {
        guard let instanceDir = getInstanceFolder(folderName: folderName) else {
            return nil
        }
        let path = instanceDir.appendingPathComponent(docName)
        if let imgData = image.jpegData(compressionQuality: 1.0) {
            
            do {
                try imgData.write(to: path, options: .completeFileProtectionUnlessOpen)
                return imgData
            } catch {
                return nil
            }
        }
        return nil
    }
    
    class func saveThumbnailPhoto(withPhotoName name: String, withImage orgImage: UIImage, folderName:String){
        // Create Thumbnail directory if not available inside document folder
        guard let thumbDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(Constants.ThumbImagesFolder) else {
            return
        }
        
        // Create Thubmnail Directory if not exist.
        if !FileManager.default.fileExists(atPath: thumbDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: thumbDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Failed to Create directory path")
                return
            }
        }
        
        let thumbnailPath = thumbDirectory.appendingPathComponent(name)
        let resizedImg = orgImage.resizeImage(targetSize: (orgImage.size.width > orgImage.size.height) ? CGSize(width: 400, height: 300) : CGSize(width: 300, height: 400))
        let imgData = resizedImg.jpegData(compressionQuality: 0.5)
        do {
            try imgData?.write(to: thumbnailPath, options: Data.WritingOptions.completeFileProtectionUnlessOpen)
        } catch {
            //AppSee event for failure
        }
    }
    
    class func getImageSize(image: UIImage) -> Int {
        let imgData = image.jpegData(compressionQuality: 1)!
        let imgNSData: NSData = NSData(data: imgData)
        let imageSize: Int = imgNSData.length
        return imageSize/1024
    }
    
    // Remove a file(image/video) from application document directory and replace it with a new file.
    class func renameFileInAppDocDirectory(oldImgName: String, newImgName: String, folderName:String) -> Bool {
        let fileManager = FileManager.default
        if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            var oldPath = dir.appendingPathComponent(oldImgName)
            
            // Search inside the instance folder
            if !FileManager.default.fileExists(atPath: oldPath.path) {
                oldPath = dir.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(oldImgName)
            }
            
            guard let instanceDir = getInstanceFolder(folderName: folderName) else {
                return false
            }
            let newPath = instanceDir.appendingPathComponent(newImgName)
            
            do {
                try fileManager.moveItem(at: oldPath, to: newPath)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    class func getInstanceFolder(folderName: String) -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let instanceDir = dir.appendingPathComponent(folderName, isDirectory: true)
            if !FileManager.default.fileExists(atPath: instanceDir.path) {
                do {
                    try FileManager.default.createDirectory(at: instanceDir, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    print("Failed to Create directory path")
                    return dir
                }
            }
            return instanceDir
        }
        return nil
    }
    
    class func getPhotoParentDir(imgName: String, folderName: String) -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let docPath = dir.appendingPathComponent(imgName).path
            if FileManager.default.fileExists(atPath: docPath) {
                return dir
            }
            else {
                let instanceDir = dir.appendingPathComponent(folderName, isDirectory: true)
                let docPath = instanceDir.appendingPathComponent(imgName).path
                if FileManager.default.fileExists(atPath: docPath) {
                    return instanceDir
                }
            }
        }
        return nil
    }
    
    class func getPhotoThumbnailDir(imgName: String, folderName: String) -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let docPath = dir.appendingPathComponent(Constants.ThumbImagesFolder, isDirectory: true)
            if FileManager.default.fileExists(atPath: docPath.appendingPathComponent(imgName).path) {
                return docPath
            }
            else {
                let instanceThumbDir = dir.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(Constants.ThumbImagesFolder, isDirectory: true)
                if FileManager.default.fileExists(atPath: instanceThumbDir.appendingPathComponent(imgName).path) {
                    return instanceThumbDir
                }
            }
        }
        return nil
    }
    
    class func deleteImageFromDocumentDirectory(docName: String, folderName:String) -> Bool {
        if let dir = getPhotoParentDir(imgName: docName, folderName: folderName) {
            let path = dir.appendingPathComponent(docName).path
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch {
                print("Failed to remove photo from file path location")
                return false
            }
        }
        return false
    }
    
    class func checkDocumentExist(docName: String, folderName:String) -> Bool {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let docPath = dir.appendingPathComponent(docName).path
            if FileManager.default.fileExists(atPath: docPath) {
                return true
            }
            else {
                let instanceDir = dir.appendingPathComponent(folderName, isDirectory: true)
                let docPath = instanceDir.appendingPathComponent(docName).path
                if FileManager.default.fileExists(atPath: docPath) {
                    return true
                }
            }
        }
        return false
    }
    
    class func deleteInstanceDirectory(instanceId:String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let instanceDir = dir.appendingPathComponent(instanceId, isDirectory: true)
            if FileManager.default.fileExists(atPath: instanceDir.path) {
                do {
                    try FileManager.default.removeItem(at: instanceDir)
                } catch {
                    print("Failed to delete Directory.....")
                }
            }
        }
    }
    
    class func deleteThumbnailImgDocumentFromDirectory(docName: String, folderName:String) -> Bool {
        if let dir = getPhotoThumbnailDir(imgName: docName, folderName: folderName) {
            let path = dir.appendingPathComponent(docName).path
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch {
                print("Failed to remove thumbnail document from file path location")
                return false
            }
        }
        return false
    }
    
    
    
    // Get image metadata.
    class func getMetaDataFromImgData(imgData: NSData) -> NSDictionary? {
        
        if let imgSource = CGImageSourceCreateWithData(imgData, nil)  {
            let options: NSDictionary = [kCGImageSourceShouldCache: NSNumber(booleanLiteral: false)]
            
            if let imgProperties = CGImageSourceCopyPropertiesAtIndex(imgSource, 0, options) {
                let metaData: NSDictionary = imgProperties
                return metaData
            }
        }
        return nil
    }
    
    class func stringFromDate(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current   //NSTimeZone(name: "UTC") as TimeZone!
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    class func dateFromString(dateStr: String, format: String) -> NSDate {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateStr)! as NSDate
    }
    
    class func gmtStringFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: Constants.SERVER_EXP_DATE_FORMATE)
    }
    
    class func UTCStringFromDate(date: Date) -> String {
        return stringFromDate(date: date, format: Constants.SERVER_EXPECT_DATE_FORMAT_WITH_ZONE)
    }
    
    class func dateFromGMTdateString(dateStr: String, withTimeZone timezone:String?) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timezone == nil ? TimeZone.current : (NSTimeZone(name: timezone!) as TimeZone?)
        dateFormatter.dateFormat = Constants.SERVER_EXP_DATE_FORMATE
        
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }
        
        dateFormatter.dateFormat = Constants.SERVER_EXP_DATE_FORMATE_2nd
        if let date = dateFormatter.date(from: dateStr) {
            return date
        }
        return Date()
    }
    
    
    // Get Required image for specific resolution type and based on task answered or not
    class func getDocumentNameForResId(resId: NSNumber, isAnswered: Bool) -> UIImage? {
        
        if Int(truncating: resId) == ResolutionType.SphericalPhoto.getResolutionId() {
            return isAnswered ? UIImage(named: "pano_spherical_yellow") : UIImage(named: "pano_spherical_white")
        }
        else if Int(truncating: resId) == ResolutionType.Pano180Photo.getResolutionId() {
            return isAnswered ? UIImage(named: "pano_180_yellow") : UIImage(named: "pano_180_white")
        }
        else if Int(truncating: resId) == ResolutionType.HDPhoto.getResolutionId() {
            return isAnswered ? UIImage(named: "photo_hd_yellow") : UIImage(named: "photo_hd_white")
        }
        return isAnswered ? UIImage(named: "CameraNew-Yellow") : UIImage(named: "CameraNew-White")
    }
    
    // Get Required image for specific resolution type and based on task answered or not
    class func getLargeDocumentNameForResId(resId: NSNumber) -> UIImage? {
        
        if Int(truncating: resId) == ResolutionType.SphericalPhoto.getResolutionId() {
            return UIImage(named: "PhotoPano360BigIcon")
        }
        else if Int(truncating: resId) == ResolutionType.Pano180Photo.getResolutionId() {
            return UIImage(named: "PhotoPano180BigIcon")
        }
        else if Int(truncating: resId) == ResolutionType.HDPhoto.getResolutionId() {
            return UIImage(named: "photo_hd_white")
        }
        return UIImage(named: "PhotoBigIcon")
    }
    
    // Get Required image for specific resolution type and based on task answered or not
    class func getRequiredDocumentNameForResId(resId: NSNumber, isAnswered: Bool) -> UIImage? {
        
        if Int(truncating: resId) == ResolutionType.SphericalPhoto.getResolutionId() {
            return isAnswered ? UIImage(named: "pano_spherical_yellow") : UIImage(named: "pano_spherical_white")
        }
        else if Int(truncating: resId) == ResolutionType.Pano180Photo.getResolutionId() {
            return isAnswered ? UIImage(named: "pano_180_yellow") : UIImage(named: "pano_180_white")
        }
        else if Int(truncating: resId) == ResolutionType.HDPhoto.getResolutionId() {
            return isAnswered ? UIImage(named: "photo_hd_yellow") : UIImage(named: "photo_hd_white")
        }
        return isAnswered ? UIImage(named: "CameraNew-Yellow") : UIImage(named: "CameraNew-White")
    }
    
    class func showAlertMsgWhenRunningInBG(withMessage message: String, withTitle title:String = StringConstants.StatusMessages.BG_Upload_Process_Failure_Msg_Title) {
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState == .background {
                let content = UNMutableNotificationContent()
                content.sound = UNNotificationSound.default
                content.categoryIdentifier = "ErrorSendingInstance"
                content.badge = 1
                content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
                
                // Configure the trigger after 5 second of current time
                var dateInfo = NSCalendar.current.dateComponents([.hour, .minute, .second], from: NSDate() as Date)
                dateInfo.second = dateInfo.second! + 5
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
                
                // Create the request object.
                let request = UNNotificationRequest(identifier: "JobStatusBGNew", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    class func getLastLoggedInUserName() -> String? {
        do {
            if let keychainAccount = try KeychainPasswordItem.passwordItems(forService: Constants.keyChainServiceName, accessGroup: Constants.keyChainAccessGroup).first {
                return keychainAccount.account
            }
        }catch {
            return nil
        }
        return nil
    }
    
    class func deleteAllZippedFiles() {
        if let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileManager = FileManager.default
            
            let files = try! fileManager.contentsOfDirectory(at: docDirectory, includingPropertiesForKeys: nil, options: [])
            for file in files {
                if file.absoluteString.lowercased().contains(".zip") {
                    try! fileManager.removeItem(at: file)
                }
            }
        }
    }
    
    class func getPhotoId(url:URL, param: String)-> String? {
        if let urlParams = url.queryParameters {
            if let photoId = urlParams[param] {
                return photoId
            }
        }
        return nil
    }
}
