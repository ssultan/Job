//
//  DocumentModel.swift
//  Job
//
//  Created by Saleh Sultan on 5/29/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit
//import Appsee

class DocumentModel: NSObject {

    @objc dynamic var attribute: String?
    @objc dynamic var comment: String?
    @objc dynamic var docTags: String?
    @objc dynamic var documentId: String?
    @objc dynamic var docServerId: String?
    @objc dynamic var photo180GalleryPath: String?
    @objc dynamic var isSent: NSNumber?
    //@objc dynamic var location: String?
    @objc dynamic var mimeType: String?
    @objc dynamic var name: String?
    @objc dynamic var originalName: String?
    @objc dynamic var sentTime: NSDate?
    @objc dynamic var createdDate: NSDate?
    @objc dynamic var type: String?
    @objc dynamic var exifDic: NSDictionary?
    @objc dynamic var instanceId: String?
    @objc dynamic var answerId: String?
    @objc dynamic var insServerId: String?
    @objc dynamic var ansServerId: String?
    @objc dynamic var associatedQNo: String?
    @objc dynamic var username: String?
    @objc dynamic var resolution: String?
    @objc dynamic var resolutionId: Int = 1
    @objc dynamic var attributeId: String?
    @objc dynamic var photoAttrType: String?
    @objc dynamic var serverCreatedDate: NSDate?
    @objc dynamic var isPhotoDeleted: NSNumber? // If user deleted the photo
    @objc dynamic var isDataNull: NSNumber?
    @objc dynamic var photoServerURL: String? // Server photo URL once that specific photo successfully got inserter into server file system and database
    @objc dynamic var isNeedToSend: NSNumber? // For only Update request. If user change the photo name or any attributes of the photo, then do not need to send the photo data; only metadata of the photo.
    @objc dynamic var documentInstance: JobInstance?
    @objc dynamic var documentAnswer: Answer?
    @objc dynamic var isAddedByOthers: Bool = false
    
    override init() {
        
    }
    
    init(forAnswerObject answer: Answer, withDocObject docObj:DocumentObj, forDocName photoName: String, completion:(Bool)->()) {
        super.init()
        self.answerId = answer.ansId
        self.instanceId = answer.jobInstance?.instId
        self.attribute = PhotoAttributesTypes.General.rawValue
        self.attributeId = String(PhotoAttributesTypes.General.getAttributeId())
        self.mimeType = Constants.ImageMimeType
        self.type =  Constants.DocImageType
        self.name = photoName
        self.originalName = photoName
        self.comment = ""
        self.createdDate = NSDate()
        self.exifDic = NSDictionary()
        self.documentId = docObj.docId?.uppercased()
        self.photoServerURL = docObj.documentURL
        self.docServerId = String(docObj.docServerId)
        self.isSent = NSNumber(value: true)
        self.isNeedToSend = NSNumber(value: false)
        self.isPhotoDeleted = NSNumber(value: false)
        self.documentAnswer = answer
        self.isAddedByOthers = true
        completion(DBDocumentServices.insertNewPhoto(documentModel: self, isAddedByOtherUser: true))
    }
    
    private func getDocId(forURL url: String) -> String {
        var docId = UUID().uuidString
        if let last = url.components(separatedBy: "/").last {
            if last.components(separatedBy: ".").count > 1 {
                docId = last.components(separatedBy: ".")[0]
            }
        }
        return docId
    }
    
    init(forInstance instance: JobInstance, withDocObject docObj:DocumentObj, forDocName photoName: String, completion:(Bool)->()){
        super.init()
        //https://clearthread.davacoinc.com/documents/Collection/CustomerId_11/TemplateId_16048/InstanceId_193807/AnswerId_6148016/eVbgRMaWu1-tyE_itvlm0g2.jpg

        self.instanceId = instance.instId
        self.attribute = PhotoAttributesTypes.FieldVisit.rawValue
        self.attributeId = String(PhotoAttributesTypes.FieldVisit.getAttributeId())
        self.mimeType = Constants.ImageMimeType
        self.type =  Constants.DocImageType
        self.name = photoName
        self.originalName = photoName
        self.comment = ""
        self.createdDate = NSDate()
        self.exifDic = NSDictionary()
        self.documentId = docObj.docId?.uppercased()
        self.photoServerURL = docObj.documentURL
        self.docServerId = String (docObj.docServerId)
        self.isSent = NSNumber(value: true)
        self.isNeedToSend = NSNumber(value: false)
        self.isPhotoDeleted = NSNumber(value: false)
        self.documentInstance = instance
        self.isAddedByOthers = true
        completion(DBDocumentServices.insertNewPhoto(documentModel: self, isAddedByOtherUser: true))
    }
    
    init(document: Document) {
        super.init()
        self.attribute = document.attribute
        self.attributeId = document.attributeId
        self.photoAttrType = document.photoAttrType
        self.comment = document.comment
        self.docTags = document.docTags
        self.documentId = document.documentId
        self.isSent = document.isSent
        //self.location = document.location
        self.mimeType = document.mimeType
        self.name = document.name
        self.originalName = document.originalName
        self.sentTime = document.sentTime as NSDate?
        self.createdDate = document.createdDate as NSDate?
        self.type = document.type
        self.photoServerURL = document.photoServerURL
        self.isNeedToSend = document.isNeedToSend
        self.isDataNull = document.isDataNull
        self.photo180GalleryPath = document.photo180GalleryPath
        self.isPhotoDeleted = document.isPhotoDeleted ?? NSNumber(value: false)
        self.isAddedByOthers = document.isAddedByOthers
        
        if let instance = document.jobInstance {
            self.instanceId = instance.instId
            self.insServerId = instance.instServerId
            self.username = instance.manifest!.user!.userName
        }
        else if let answer = document.answer {
            self.answerId = answer.ansId
            self.ansServerId = answer.ansServerId
            self.username = answer.jobInstance?.manifest!.user!.userName
            self.resolution = answer.task?.documentType
            
            if let resolId = answer.task?.documentTypeId {
                self.resolutionId = Int(truncating: resolId)
            }
            if let quesNo = answer.task?.taskNo {
                self.associatedQNo = quesNo
            }
            
            //Since instance Id is a required field in server to insert an photo, we always have to send the either serverId or client Id of an instance
            if let instance = answer.jobInstance {
                self.insServerId = instance.instServerId
                self.instanceId = instance.instId
            }
        }
        
        if let exifStr = document.exifDic {
            do {
                if let data = exifStr.data(using: .utf8) {
                    if let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        self.exifDic = dataDictionary
                    }
                }
            } catch {
                self.exifDic = NSDictionary()
            }
        }
    }
    
    func makeJsonForDocument(isUpdating:Bool = false) -> [String: AnyObject] {
        var docJson = [String: AnyObject]()
        docJson[Constants.ApiRequestFields.Key_DeviceId] = AppInfo.sharedInstance.deviceId as AnyObject
        docJson[Constants.ApiRequestFields.Key_MimeType] = Constants.ImageMimeType as AnyObject // We do NOT need to send the mimeType. But still i kept it.
        
        // Mobile database identifier ID is known as client Id in server side. Same way local database server Id know as just 'Id' in server side. Because that Id is being generated by Server automatically using auto generated identifier in Server database
        
        // We have to send either serverId or client id of an instance or answer. Since I have both, so i am sending both of them. Server will decide which on server should pick for comparison.
        if let insClientId = self.instanceId {
            docJson[Constants.ApiRequestFields.Key_ClientInstanceId] = insClientId as AnyObject
        }
        if let instanceId = self.insServerId {
            docJson[Constants.ApiRequestFields.Key_InstanceId] = instanceId as AnyObject
        }
        if let ansClientId = self.answerId {
            docJson[Constants.ApiRequestFields.Key_ClientAnswerId] = ansClientId as AnyObject
        }
        if let answerId = self.ansServerId {
            docJson[Constants.ApiRequestFields.Key_AnswerId] = answerId as AnyObject
        }
        if let username = self.username {
            docJson[Constants.ApiRequestFields.Key_UserName] = username as AnyObject
        } else if let username = AppInfo.sharedInstance.username {
            docJson[Constants.ApiRequestFields.Key_UserName] = username as AnyObject
        }
        
        //This is the client generated ID. We will wait to get the server Id from reseponse if we do Syncronous request. For asyncronous request we have to wait to call acknowledgement service reqeust to get documentId, created Date and URL
        if let docClientId = self.documentId {
            docJson[Constants.ApiRequestFields.Key_DocumentId] = docClientId as AnyObject
        }
        if let dId = self.docServerId {
            docJson[Constants.ApiRequestFields.Key_Id] = dId as AnyObject
        }
        
        // Josh Said, 'We don't care the original name since we are not doing any parsing on the name. So just leave it and take the name what ever user updated'
        if let origName = self.originalName, let name = self.name, let isSent = self.isSent {
            docJson[Constants.ApiRequestFields.Key_Name] = name as AnyObject
            
            // IF the photo never sent yet, then we have to add the photo into the metadata. Otherwise do not add the metadata since we are going to make PUT request to update photo metadata only
            if Bool(truncating: isSent) == false {
                if let fullPath = Utility.getImageFullPath(docName: origName, folderName: self.instanceId ?? "") {
                    if let imageData = NSData(contentsOfFile: fullPath) {
                        docJson[Constants.ApiRequestFields.Key_Data] = imageData.base64EncodedString(options: .lineLength64Characters) as AnyObject
                    }
                }
            }
        }
        if let docTag = self.docTags {
            docJson[Constants.ApiRequestFields.Key_Tag] = docTag as AnyObject
        }
        
        if let comments = self.comment {
            
            if self.type == Constants.DocSignatureType, var attribute = self.attribute {
                attribute = (attribute != "") ? "Title: \(attribute)" : ""
                
                if self.attribute! != "" && comments != "" {
                    attribute = "\(attribute), Comment: "
                }
                docJson[Constants.ApiRequestFields.Key_Comments] = "\(attribute)\(comments)" as AnyObject
            } else {
                docJson[Constants.ApiRequestFields.Key_Comments] = comments as AnyObject
            }
        }
        else if self.type == Constants.DocSignatureType {
            let attribute = self.attribute != nil ? "Title: \(self.attribute!)" : ""
            docJson[Constants.ApiRequestFields.Key_Comments] = "\(attribute)" as AnyObject
        }
        
        if var attributeId = self.attributeId {
            //It's mendatory to have a attributeId
            if attributeId == "0" {
                attributeId = "3"
            }
            docJson[Constants.ApiRequestFields.Key_AttributeId] = attributeId as AnyObject
        }else {
            // AttributeID is requered and hance even for signature we have to make sure to add attribute ID
            docJson[Constants.ApiRequestFields.Key_AttributeId] = 3 as AnyObject
        }
        
        docJson[Constants.ApiRequestFields.Key_ResolutionId] = self.resolutionId as AnyObject
        if self.type == Constants.DocSignatureType {
            docJson[Constants.ApiRequestFields.Key_CategoryId] = 4 as AnyObject // For signature: 4
        } else {
            docJson[Constants.ApiRequestFields.Key_CategoryId] = 1 as AnyObject // For All photo type: 1
        }
        
        print("++++ Sending Document InstanceId: \(String(describing: docJson[Constants.ApiRequestFields.Key_InstanceId])), AnswerId: \(String(describing: docJson[Constants.ApiRequestFields.Key_AnswerId])), DocId: \(String(describing: docJson[Constants.ApiRequestFields.Key_DocumentId]))")
        return docJson
    }
    
    
    @objc func deleteDocument() -> Bool {
        // remove document from local database.
        if JobServices.removeDocument(docId: self.documentId ?? "") {
            
            if Utility.deleteImageFromDocumentDirectory(docName: self.originalName!, folderName: self.instanceId ?? "") {
                if !Utility.deleteThumbnailImgDocumentFromDirectory(docName: self.originalName!, folderName: self.instanceId ?? "") {
                    print("Failed to delete Thumb Image\(StringConstants.AppseeEventMessages.Failed_Delete_Thumb_Img) => \(self.originalName!)" )
                }
                if self.type == Constants.DocSignatureType && (self.isSent ?? 0).boolValue{
                    DocumentDLManager.deleteSignatureFromServer(documentId: self.documentId!)
                }
                return true
            }
        }
        print("Failed to delete Original Image: \(self.originalName!)" )
        return false
    }
    
    func updateDocument(image: UIImage) {
        if !(Utility.deleteImageFromDocumentDirectory(docName: self.originalName!, folderName: self.instanceId ?? "")) {
            print("Failed to delete the document from local directory")
        }
        
        let docNewName = Utility.updateDcoumentNameFor(oldDocName: self.originalName!, documentType: Constants.JPEG_DOC_TYPE)
        if let imgData = Utility.saveDocumentInDocumentDirectory(document: image, docName: docNewName, folderName: self.instanceId ?? "", imgMetaDataDic: self.exifDic ?? NSDictionary(), lossyData: false) {
            if let dic = Utility.getMetaDataFromImgData(imgData: imgData as NSData) {
                self.exifDic = dic
            }
            
            self.originalName = docNewName
            JobServices.updateDocument(document: self)
        }
    }
}
