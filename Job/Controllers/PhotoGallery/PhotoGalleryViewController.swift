//
//  PhotoGalleryViewController.swift
//  Job V2.0
//
//  Created by Saleh Sultan on 06/14/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.

 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import ImageIO
import Photos
import AVFoundation
import JGProgressHUD

// These are the types of Gallaries that could be happen in a gallary view.
enum PhotoViewType {
    case JobVisitPhotos
    case TaskPhotos
}

var imageScaleSize:CGFloat = 800

class PhotoGalleryViewController: RootViewController {

    var photoGalType: PhotoViewType!
    var photoArray = [DocumentModel]()
    var taskDelegate: TaskDetailsDelegate!

    // Define the progress bar
    var loadingView = JGProgressHUD(style: .extraLight)

    // This flag will make sure user can choose only one photo at at time.
    var isPhotoPickedAlready: Bool = false

    // This flag will track if the gallery view is already loaded or not. If the gallery view contain only one photo and that photo is being deleted, then when we will come back in this page, we don't want to show the image picker controller, since according to our program, we have to show image picker controller if there is not image in photo gallery view.
    var isLoaded = false

    @IBOutlet weak var takePhtBtn: UIButton!
    @IBOutlet weak var photoCollectionV: UICollectionView!
    @IBOutlet weak var cameraIconPosition: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        if photoGalType == .JobVisitPhotos {
            self.title = StringConstants.PageTitles.FV_PHOTO_GALLERY_TLT
        }
        else {
            self.navigationItem.hidesBackButton = true
            self.title = StringConstants.PageTitles.ANS_PHOTO_GALLERY_TLT
        }
        setNavRightBarItem()

        // Set the padding of collection view and items per row in the collection view.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/(UIApplication.shared.statusBarOrientation == .portrait ? 3.09 : 5.8),
                                 height: UIScreen.main.bounds.size.width/((UIApplication.shared.statusBarOrientation == .portrait ? 3.09 : 5.8)))

        if UIDevice.current.userInterfaceIdiom == .pad {
            layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/(UIApplication.shared.statusBarOrientation == .portrait ? 5.09 : 7.09),
                                     height: UIScreen.main.bounds.size.width/(UIApplication.shared.statusBarOrientation == .portrait ? 5.09 : 7.09))
        }
        photoCollectionV!.collectionViewLayout = layout

        if isPano180Photo() {
            takePhtBtn.setTitle(StringConstants.ButtonTitles.BTN_CHOOSE_PHOTO, for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // if the photo gallery view is for field visit photos then get the list of documents from shared instance.
        if photoGalType == .JobVisitPhotos {
            let documents = AppInfo.sharedInstance.selJobInstance.documents
            photoArray = documents.filter { $0.type == Constants.DocImageType && $0.isPhotoDeleted == NSNumber(value: false) }
                .sorted(by: { (($0.createdDate?.compare(($1.createdDate as Date?)!)) == .orderedAscending) })
        }
        //Otherwise it is task answered photo document gallery.
        else {
            let jobFV = JobVisitModel.sharedInstance
            photoArray = jobFV.answer.ansDocuments
                .filter { $0.type == Constants.DocImageType && $0.isPhotoDeleted == NSNumber(value: false) }
                .sorted(by: { (($0.createdDate?.compare(($1.createdDate as Date?)!)) == .orderedAscending) })
        }

        // if the photo gallery is empty and this is the first time we are loading this view.
        if (photoArray.count == 0 && !isLoaded) || isStorePhoto() {
            self.takePhotoBtnAction(sender: takePhtBtn)
        } else {
            photoCollectionV.reloadData()
        }
        isLoaded = true

//        if let menu = self.navigationController?.slideMenuController() {
//            menu.closeRight()
//        }

        if UIApplication.shared.statusBarFrame.width == 320 {
            cameraIconPosition.constant = -40
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //Is view is moving to it's parent view which is a task page, then animate to top direction
        if isMovingFromParent {
            if photoGalType == .TaskPhotos {
                self.navigationController?.popViewController(animated: true, direction: .Top, callPopupVC: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func showAlertForPermission() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        var altMessage = ""
        var acceptBtn = ""
        if UIApplication.shared.canOpenURL(settingsURL) {
            altMessage = isPano180Photo() ? StringConstants.StatusMessages.Photo_Gallery_Access_Denied_WithSettingsURL : StringConstants.StatusMessages.Photo_Access_Denied_WithSettingsURL
            acceptBtn = StringConstants.ButtonTitles.BTN_GO
        }
        else {
            altMessage = isPano180Photo() ? StringConstants.StatusMessages.Photo_Gallery_Access_Denied_WithOUTSettingsURL : StringConstants.StatusMessages.Photo_Access_Denied_WithOUTSettingsURL
            acceptBtn = StringConstants.ButtonTitles.BTN_OK
        }

        self.showAcceptCancelMsg(message: altMessage, acceptBtnTxt: acceptBtn, closeBtnTxt: StringConstants.ButtonTitles.BTN_Cancel, title: StringConstants.ButtonTitles.TLT_Warning, acceptBlock: {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        })
    }

    @IBAction func takePhotoBtnAction(sender: UIButton) {
        if isPano180Photo() {
            let authStatus = PHPhotoLibrary.authorizationStatus()
            if authStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == PHAuthorizationStatus.authorized {
                        DispatchQueue.main.async {
                            self.openCameraController(sender: sender)
                        }
                    }
                }
            }
            else if authStatus == .denied || authStatus == .restricted {
                self.showAlertForPermission()
            } else {
                self.openCameraController(sender: sender)
            }
        } else {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                    DispatchQueue.main.async {
                        if granted {
                            self.openCameraController(sender: sender)
                        }
                    }
                })
            }
            else if authStatus == .denied {
                self.showAlertForPermission()
            }
            else {
                self.openCameraController(sender: sender)
            }
        }
    }

    fileprivate func pick180Photo(_ sender: UIButton) {
        let cameraView = UIImagePickerController()
        cameraView.sourceType = .photoLibrary
        cameraView.delegate = self

        // For iPad, show the library as popover view.
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cameraView.modalPresentationStyle = .popover
            let popover: UIPopoverPresentationController = cameraView.popoverPresentationController!
            popover.permittedArrowDirections = .down
            popover.sourceView = sender
            self.present(cameraView, animated: true, completion: nil)
        }
        else {
            present(cameraView, animated: true, completion: nil)
        }
    }

    fileprivate func takeDefaultPhoto(_ sourceType: UIImagePickerController.SourceType) {
        let cameraView = UIImagePickerController()
        cameraView.sourceType = sourceType
        cameraView.delegate = self
        present(cameraView, animated: true, completion: nil)
    }

    func openCameraController(sender: UIButton) {
        isPhotoPickedAlready = false

        if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear) {

            if photoGalType == .JobVisitPhotos {
                takeDefaultPhoto(.camera)
            }
            else {
                if let resolutionTypeId = JobVisitModel.sharedInstance.task.documentTypeId {
                    if Int(truncating: resolutionTypeId) == ResolutionType.SphericalPhoto.getResolutionId() {
//                        let panoShooter = UINavigationController(rootViewController: PanoShooterViewController())
//                        self.present(panoShooter, animated: true, completion: nil)
                    }
                    else if isPano180Photo() {
                        pick180Photo(sender)
                    }
                    else {
                        takeDefaultPhoto(.camera)
                    }
                }
            }
        }
        else {
            takeDefaultPhoto(.photoLibrary)
        }
    }

    @IBAction func doneBtnAction() {
        saveAndgoBack()
        if taskDelegate != nil {
            taskDelegate.triggerCompletedDate()
        }
    }

    func saveAndgoBack(animate:Bool = true) {
        _ = self.navigationController?.popViewController(animated: animate)
    }
}

extension PhotoGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        saveAndgoBack(animate: false)
    }

    fileprivate func getImageMetadata(_ url: URL, completion:@escaping (_ metadataDic:NSDictionary)->()) {
        if let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject {
            print(asset.location  ?? "NO VALUE")

            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true

            asset.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput, test) -> Void in
                let fullImage = CIImage(contentsOf: contentEditingInput!.fullSizeImageURL!)
                if let fullImageMetadata = fullImage?.properties as NSDictionary? {
                    completion(fullImageMetadata)
                } else {
                    completion(NSDictionary())
                }
            })
        }
    }

    fileprivate func getDocumentObject() -> DocumentModel {
        let instance = JobServices.createInstanceObjectIfNotAvilable()
        let photoType:PhotoAttributesTypes = self.photoGalType == .JobVisitPhotos ? PhotoAttributesTypes.FieldVisit : PhotoAttributesTypes.General
        let photoName = Utility.generateDcoumentNameFor(projectNumber: instance.template.projectNumber,
                                                        storeNumber: instance.location.storeNumber,
                                                        taskNumber: (self.photoGalType == .JobVisitPhotos ? nil : JobVisitModel.sharedInstance.taskNo ?? "0"),
                                                        attribute: PhotoAttributesTypes.General,
                                                        documentType: Constants.JPEG_DOC_TYPE)

        let curDocument = DocumentModel()
        curDocument.attribute = photoType.rawValue
        curDocument.attributeId = String(photoType.getAttributeId())
        curDocument.mimeType = Constants.ImageMimeType
        curDocument.type =  Constants.DocImageType
        curDocument.name = photoName
        curDocument.originalName = photoName
        curDocument.comment = ""
        curDocument.createdDate = NSDate()
        curDocument.instanceId = instance.instId
        curDocument.isSent = NSNumber(value: false)
        curDocument.isNeedToSend = NSNumber(value: true)
        curDocument.isPhotoDeleted = NSNumber(value: false)
        return curDocument
    }

    func isHDPhoto() -> Bool {
        if self.photoGalType != .JobVisitPhotos, let resId = JobVisitModel.sharedInstance.task.documentTypeId {
            if Int(truncating: resId) == ResolutionType.HDPhoto.getResolutionId() {
                return true
            }
        }
        return false
    }

    fileprivate func photo180ExistInGallery(url: URL) -> Bool{
        if let answer = JobVisitModel.sharedInstance.answer {
            if answer.isDocumentAlreadyExist(photoURL: url) {
                self.dismiss(animated: true) {
                    self.showErrorMsg(StringConstants.StatusMessages.Same_Pano180_Photo_Selected_Msg, title: StringConstants.StatusMessages.Pano180_Photo_Import_Title) {
                    }
                }
                return true
            }
        }
        return false
    }

    fileprivate func save180ImgMetadata(_ url: URL, _ newImg: UIImage) {
        self.getImageMetadata(url) { (picMetadata) in
            DispatchQueue.main.async {

                let documentObj = self.getDocumentObject()
                documentObj.exifDic = picMetadata
                if let photoId = Utility.getPhotoId(url: url, param: "id") {
                    documentObj.documentId = photoId
                } else {
                    documentObj.documentId = UUID().uuidString
                }

                if let document = JobServices.saveImageNew(image: newImg, documentObj: documentObj) {
                    self.loadingView.dismiss()
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        self.viewWillAppear(true)
                    } else {
                        self.photoArray.append(document)
                        self.photoCollectionV.reloadData()
                    }
                }
            }
        }
    }

    fileprivate func processs180Photo(forMediaInfo info: [String: Any]) {
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            return
        }
        let whratio = fmax(image.size.width, image.size.height) / fmin(image.size.width, image.size.height)

        if whratio < 2.0 {
            self.dismiss(animated: true) {
                self.showErrorMsg(StringConstants.StatusMessages.Wrong_Pano180_Photo_Selected_Msg, title: StringConstants.StatusMessages.Pano180_Photo_Import_Title)
            }
            return
        }
        else if let newImg = image.imageScaleAspectToMinSize(newSize: imageScaleSize) {
            if let url = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.referenceURL)] as? URL {

                if !photo180ExistInGallery(url: url) {
                    self.loadingView.textLabel.text = StringConstants.StatusMessages.LOADING
                    self.loadingView.show(in: self.view, animated: true)
                    save180ImgMetadata(url, newImg)
                }
            }
        }
    }

    fileprivate func processDefaultnHDphotos(_ image: UIImage, _ info: [String : Any]) {
        let resizedImg = image.resizeImage(targetSize: getPhotoReSizedforImg(image: image))
        var metadata = NSDictionary()
        if let mdata = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaMetadata)] as? NSDictionary {
            metadata = mdata
        }

        let documentObj = self.getDocumentObject()
        documentObj.exifDic = metadata
        documentObj.documentId = UUID().uuidString

        if let _ = JobServices.saveImageNew(image: resizedImg, documentObj: documentObj) {
            self.loadingView.textLabel.text = StringConstants.StatusMessages.LOADING
            self.loadingView.show(in: self.view, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.photoCollectionV.reloadData()
                self.loadingView.dismiss()
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        // At a time user can choose only one photo
        if isPhotoPickedAlready {
            return
        }
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            isPhotoPickedAlready = true
            if isStorePhoto() {
                self.removeAllExistingStorePhotos()
            }

            if isPano180Photo() {
                processs180Photo(forMediaInfo: info)
            }
            else {
                processDefaultnHDphotos(image, info)
            }
        }

        self.dismiss(animated: true, completion: nil)
        if isStorePhoto() {
            self.saveAndgoBack(animate:false)
        }
    }

    func reloadTableView() {

    }

    func isPano360Photo() -> Bool {
        if self.photoGalType != .JobVisitPhotos, let resId = JobVisitModel.sharedInstance.task.documentTypeId {
            if Int(truncating: resId) == ResolutionType.SphericalPhoto.getResolutionId() {
                return true
            }
        }
        return false
    }

    func isPano180Photo() -> Bool {
        if self.photoGalType != .JobVisitPhotos, let resId = JobVisitModel.sharedInstance.task.documentTypeId {
            if Int(truncating: resId) == ResolutionType.Pano180Photo.getResolutionId() {
                return true
            }
        }
        return false
    }

    func removeAllExistingStorePhotos() {
        // For Store photo remove existing photo
        if let document = JobVisitModel.sharedInstance.answer.ansDocuments.first {
            if document.deleteDocument() {
                JobVisitModel.sharedInstance.answer.ansDocuments.removeAll()
            }
        }
    }

    func isStorePhoto() -> Bool {
        if self.photoGalType != .JobVisitPhotos {
//            if let taskType = JobVisitModel.sharedInstance.task.taskType {
//                if taskType == .StoreFrontPhoto {
//                    return true
//                }
//            }
        }
        return false
    }

    func getPhotoReSizedforImg(image: UIImage) -> CGSize {
        if self.photoGalType != .JobVisitPhotos {
            if let resolutionId = JobVisitModel.sharedInstance.task.documentTypeId {
                if Int(truncating: resolutionId) == ResolutionType.HDPhoto.getResolutionId() {
                    return (image.size.width > image.size.height) ? CGSize(width: 1920, height: 1440) : CGSize(width: 1440, height: 1920)
                }
            }
        }
        return (image.size.width > image.size.height) ? CGSize(width: 800, height: 600) : CGSize(width: 600, height: 800)
    }
}


extension PhotoGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDelegate functions
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellIdentifier", for: indexPath) as! PhotoGalleryViewCell
        cell.photoView.image = Utility.getThumbnailImageFromDocumentDirectory(docName: photoArray[indexPath.row].originalName ?? "", folderName: photoArray[indexPath.row].instanceId ?? "")
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    fileprivate func showSphericaln180PanoPhoto(_ indexPath: IndexPath, _ resolutionTypeId: NSNumber) {
        let document = photoArray[indexPath.row]
        self.loadingView.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        self.loadingView.show(in: self.view, animated: true)

        autoreleasepool {
            if let docName = document.originalName, let docInstId = document.instanceId {
                if let docDir = Utility.getPhotoParentDir(imgName: docName, folderName: docInstId) {

                    let photoPath = docDir.appendingPathComponent(docName).path
                    if let equiData = NSData(contentsOfFile: photoPath) {
                        let length = Int(equiData.length)
                        let ptr:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: length)

                        equiData.getBytes(ptr, length: length)
//                        let fovx:Int32 = 360
//                        guard let img:UIImage = UIImage.init(contentsOfFile: photoPath) else {return}
//                        let orientation = img.imageOrientation
//                        let panoViewer = DMDViewerController()
//                        panoViewer.photoArray = photoArray
//                        panoViewer.isPhotoGallery = true
//                        panoViewer.selectedImgIdx = indexPath.row
//
//                        if Int(truncating: resolutionTypeId) == ResolutionType.SphericalPhoto.getResolutionId() {
//                            if panoViewer.loadSphericalPanorama(fromData: ptr, andSize: UInt(length), andOrientation: orientation) {
//                                self.loadingView.dismiss()
//                                self.navigationController?.pushViewController(panoViewer, animated: true)
//                            }
//                        } else {
//                            if panoViewer.loadPanorama(fromData: ptr, andSize: UInt(length), andOrientation: orientation, fovx: fovx) {
//                                self.loadingView.dismiss()
//                                self.navigationController?.pushViewController(panoViewer, animated: true)
//                            }
//                        }
                        ptr.deallocate()
                    }
                }
            }
        }
    }

    fileprivate func showDefaultPhotoViewer(_ indexPath: IndexPath) {
        let photoView = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewC") as! PhotoViewController
        photoView.photoArray = photoArray
        photoView.photoGalType = self.photoGalType
        photoView.selectedImgIdx = indexPath.row
        self.navigationController?.pushViewController(photoView, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photoGalType == .JobVisitPhotos {
            showDefaultPhotoViewer(indexPath)
        }
        else {
            if let resolutionTypeId = JobVisitModel.sharedInstance.task.documentTypeId {
                if Int(truncating: resolutionTypeId) == ResolutionType.SphericalPhoto.getResolutionId() {
                    // || Int(truncating: resolutionTypeId) == ResolutionType.Pano180Photo.getResolutionId()
                    showSphericaln180PanoPhoto(indexPath, resolutionTypeId)
                }
                else {
                    showDefaultPhotoViewer(indexPath)
                }
            }
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
