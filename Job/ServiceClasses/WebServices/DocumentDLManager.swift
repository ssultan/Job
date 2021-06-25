//
//  DocumentDLManager.swift
//  Job
//
//  Created by Saleh Sultan on 8/31/20.
//  Copyright © 2020 Davaco Inc. All rights reserved.
//

import UIKit

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
}
