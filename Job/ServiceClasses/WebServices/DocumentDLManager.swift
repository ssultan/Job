//
//  DocumentDLManager.swift
//  Job
//
//  Created by Saleh Sultan on 8/31/20.
//  Copyright © 2020 Davaco Inc. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class DocumentDLManager: BaseService {
    
    func downloadImagesIfNotExist(forAnswer answer:AnswerModel){
        for document in answer.ansDocuments {
            if let docURL = document.photoServerURL {
                if !Utility.checkDocumentExist(docName: document.name!, folderName: document.instanceId!) {
                    self.downloadImage(forURL: docURL) { (isSucceeded, image) in
                        
                        if isSucceeded, let img = image {
                            if let _ = Utility.savePhotoInDocumentDirectoryNew(photo: img, documentObj:document, lossyData: JobServices.isResizePhoto(photoType: document.attribute!)){
                                Utility.saveThumbnailPhoto(withPhotoName: document.originalName ?? "Unknown", withImage: img, folderName: document.instanceId!)
                                NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationsName.RELOAD_GALLERY_NOTIFY), object: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func downloadImagesIfNotExist(forInstance instance:JobInstanceModel){
        for document in instance.documents {
            if let docURL = document.photoServerURL {
                if !Utility.checkDocumentExist(docName: document.name!, folderName: instance.instId!) {
                    self.downloadImage(forURL: docURL) { (isSucceeded, image) in
                        
                        if isSucceeded, let img = image {
                            if let _ = Utility.savePhotoInDocumentDirectoryNew(photo: img, documentObj:document, lossyData: JobServices.isResizePhoto(photoType: document.attribute!)){
                                Utility.saveThumbnailPhoto(withPhotoName: document.originalName ?? "Unknown", withImage: img, folderName: document.instanceId!)
                                NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationsName.RELOAD_GALLERY_NOTIFY), object: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Delete a document
    // Request to delete specific photo document from server, since that photo user deleted from client side
    class func deleteSignatureFromServer(documentId: String) {
        
        //DELETE http://api.staging.clearthread.com/api/MobileDocument/{client_GUID}
        let docDeleteURL = AppInfo.sharedInstance.httpType + AppInfo.sharedInstance.baseURL + Constants.APIServices.DocumentDeleteUpdateAPI + documentId
        print("Photo Delete URL: ", docDeleteURL)
        
        // For deleting a document we don't need to send the parameters
        BaseService().fetchData(.delete, serviceURL: docDeleteURL, params: nil) { (jsonRes, statusCode, isSucceeded) in

            if (statusCode == HttpRespStatusCodes.HTTP_200_OK.rawValue) {
                print("Delete successfully")
            }
            else {
                print("Failed to delete photo: ", statusCode)
                Analytics.logEvent("\(StringConstants.AppseeEventMessages.Failed_To_Delete_Img_Device)\(AppInfo.sharedInstance.username ?? "")",
                                   parameters: ["DocumentId": documentId])
            }
        }
    }
}
