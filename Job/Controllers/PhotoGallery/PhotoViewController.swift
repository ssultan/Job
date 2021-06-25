//
//  PhotoViewController.swift
//  Job V2
//
//  Created by Saleh Sultan on 12/7/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class PhotoViewController: RootViewController {
    
    var selectedImgIdx: Int = 0
    // It variable will tack which image index user is right now.
    
    var isPageLoaded: Bool = false
    // Track if the view is loaded or not in view Did Layout subviews method. 'ViewDidLayoutSubviews' function is being called everytime you touch on the screen to show/hide navigation bar and bottom toolbar. And that cause problem to load the sliding image view everytime since we added the setup function in 'ViewDidLayoutSubviews' function. Subviews are causing problem in different sizes of devices(iPad min/iPad/iphone), if I put the slider setup method 'createPageViewController' in 'viewDidLoad' method.
    
    var isAddinglbl: Bool = false
    // This flag will check if user is adding a text label over the image or not. based on that we won't let the user to addd more text label when they are already in the process of adding a text label.
    
    var isBottomBarShowing: Bool = true
    // This flag will track if the controller is showing navigationBar/Bottom toolbar on the screen or not. Initially it will show the view. that's why we initialize the flag as true.
    
    var photoArray : [DocumentModel]!
    // Thi array will hold all the list of 'DocumentModel'. From Gallery view Controller we will provide the list to this array.
    
    var pageViewController: UIPageViewController? // page view controller will hold the documents or images.
    var txtField: UITextView!
    var textCenterPoint: CGPoint!
    var photoGalType: PhotoViewType!
    
    @IBOutlet weak var btmToolBar: UIToolbar!
    @IBOutlet weak var flexibleSpace: UIBarButtonItem!
    @IBOutlet weak var btmToolbarCons: NSLayoutConstraint! // This constain will make sure the position of the bottom toolbar depending on show/hide mood.
    @IBOutlet weak var pageControlHolderView: UIView!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var checkMarkBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.PHOTO_PAGE_TLT
        flexibleSpace.width = self.view.frame.width - 84
        pageViewController?.view.backgroundColor = .black
        
        self.setNavRightBarItem()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChagned), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showHideBottomToolBar), name: NSNotification.Name(rawValue: Constants.NotificationsName.IMAGE_WEBVIEW_TOUCHED_NOTIFY), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // if the page is not loaded yet. Only for the first time. Check the details of of 'iPageLoaded' flag above initialization.
        if !isPageLoaded {
            isPageLoaded = true
            createPageViewController()
            
            let touchGesture = UITapGestureRecognizer(target: self, action: #selector(showHideBottomToolBar))
            pageViewController?.view.addGestureRecognizer(touchGesture)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // On device orientation change, change the flexible space width, as we can not add constaint here.
    @objc func deviceOrientationChagned() {
        flexibleSpace.width = UIScreen.main.bounds.width - 84
    }
    
    // Setup a Page View Controller to load images.
    func createPageViewController() {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController?.view.frame = self.view.frame
        self.pageViewController?.dataSource = self
        
        if photoArray.count > 0 {
            let firstController = getItemController(selectedImgIdx)!
            let startingViewControllers = [firstController]
            self.pageViewController?.setViewControllers(startingViewControllers, direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }
        
        addChild(pageViewController!)
        self.pageControlHolderView.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParent: self)
        
        // Hide bottom toolbar and navigation bar after 3 second. Hide it as normally it keep there.
//        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerHideBottomBar), userInfo: nil, repeats: false)
    }
    
    // System will hide the bottom bar after certian time once user open the image sliding view for the first time.
    func timerHideBottomBar() {
        if isBottomBarShowing {
            showHideBottomToolBar()
        }
    }
    
    @objc func showHideBottomToolBar() {
        // If user is adding text label over the image, we should not let the user more text label until they are done. That's why system will keep hiding the top and bottom view from.
        if isAddinglbl {
            return
        }
        
        isBottomBarShowing = !isBottomBarShowing
        
        // Navigation Bar show/hide has antimation itself. If I put it under my custom animated function below, then it cause some flipping problem. To avoid that, i separated the code outside of my animation block.
        if isBottomBarShowing {
            self.navigationController?.isNavigationBarHidden = false
        } else {
            self.navigationController?.isNavigationBarHidden = true
        }
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            if self.isBottomBarShowing {
                self.btmToolbarCons.constant = 0
                //UIApplication.shared.isStatusBarHidden = false
            } else {
                self.btmToolbarCons.constant = -44
                //UIApplication.shared.isStatusBarHidden = true
            }
        })
    }
    
    // Drag and swipe element. Here when we added a text field over an image, this function is responsible to dragging the text field all over the screen.
    @objc func handlePan(recognizer:UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
            textCenterPoint = view.center
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func addTextButton() {
        crossBtn.isHidden = false
        checkMarkBtn.isHidden = false
        self.pageViewController?.view.isUserInteractionEnabled = false
        
        
        // Hide the bottom bar and top navigation bar. We should not give access to the user's to add more text label until they finish this one.
        showHideBottomToolBar()
        isAddinglbl = true
        
        txtField = UITextView(frame: CGRect(x: self.view.frame.size.width/2 - 60, y: self.view.frame.size.height/2 - 20, width: 120, height: 40))
        txtField.contentMode = .scaleAspectFit
        txtField.textColor = .white
        txtField.backgroundColor = .clear
        txtField.delegate = self
        txtField.returnKeyType = .done
        txtField.isUserInteractionEnabled = true
        txtField.becomeFirstResponder()
        textCenterPoint = CGPoint(x: self.view.frame.size.width/2 - 60, y: self.view.frame.size.height/2 - 20)
        
        txtField.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:))))
        self.view.addSubview(txtField)
    }
    
    @IBAction func saveCheckBtnAction() {
        crossBtn.isHidden = true
        checkMarkBtn.isHidden = true
        isAddinglbl = false
        txtField.resignFirstResponder()
        showHideBottomToolBar()
        
        
        if let documentName = photoArray[selectedImgIdx].originalName {
            
            //Add text over the image at specific point
            if let image = Utility.getImageFromDocumentDirectory(docName: documentName, folderName: photoArray[selectedImgIdx].instanceId ?? "") {
                
                if textCenterPoint.y < self.view.frame.height/2 {
                    
                }
                else {
                    
                }
                
                textCenterPoint = CGPoint(x: textCenterPoint.x - 60, y: txtField.frame.origin.y + 15)
                
                var val = (textCenterPoint.y * image.size.height) / self.view.frame.size.height
                textCenterPoint.y = val
                
                val = (textCenterPoint.x * image.size.width) / self.view.frame.size.width
                textCenterPoint.x = val
                
                
                // Get the updated image after adding text in speific point.
                let updateImg = image.textToImage(drawText: txtField.text as NSString, atPoint: textCenterPoint)
                
                
                // Update image document (1. Delete the old image, 2. Insert new image in document direcctory, 3. Update image name in database,
                // 4. Last, update the local 'photoArray' list with the update 'DocumentModel' object.
                photoArray[selectedImgIdx].updateDocument(image: updateImg)
            }
            
            
            // Reload the page again with the update image. Need to add a loading bar.
            let loadNextVC = [self.getItemController(self.selectedImgIdx)!]
            self.pageViewController?.setViewControllers(loadNextVC, direction: .forward, animated: false, completion: nil)
        }
        
        txtField.removeFromSuperview()
        self.pageViewController?.view.isUserInteractionEnabled = true
    }
    
    func calculateClientRectOfImage(image: UIImage) -> CGRect {
        
        let imgViewSize = self.view.frame.size
        let imgSize = image.size
        
        let scaleW = imgViewSize.width / imgSize.width
        let scaleH = imgViewSize.height / imgSize.height
        let aspect = fmin(scaleW, scaleH)
        
        var imageRect = CGRect(x: 0, y: 0, width: imgSize.width * aspect, height: imgSize.height * aspect)
        imageRect.origin.x = (imgViewSize.width - imageRect.size.width)/2
        imageRect.origin.y = (imgViewSize.height - imageRect.size.height)/2
        
        imageRect.origin.x = imageRect.origin.x + self.view.frame.origin.x
        imageRect.origin.y = imageRect.origin.y + self.view.frame.origin.y
        
        return imageRect
    }
    
    
    func getTxtLocation(lblPos: CGPoint, imageSize: CGSize) -> CGPoint {
        let targetPoint: CGPoint = textCenterPoint
        let val = (textCenterPoint.y * imageSize.height) / UIScreen.main.bounds.size.height
        textCenterPoint.y = val
        return targetPoint
    }
    
    
    // When user is in Adding text label mode, a cancel button will appear. By pressing cancel button system will delete the added label from the view. And it will take back the navigation bar and bottom toolbar.
    @IBAction func cancelBtnAction() {
        crossBtn.isHidden = true
        checkMarkBtn.isHidden = true
        isAddinglbl = false
        txtField.removeFromSuperview()
        showHideBottomToolBar()
        self.pageViewController?.view.isUserInteractionEnabled = true
    }
    
    
    // This will show the photo details view.
    @IBAction func addAttributesBtnAction() {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.PHOTO_EDIT_CLICKED)
        let detailsView = self.storyboard?.instantiateViewController(withIdentifier: "PhotoDetailsVC") as! PhotoDetailsViewController
        selectedImgIdx = self.currentControllerIndex()
        detailsView.document = photoArray[selectedImgIdx]
        
        let nav = UINavigationController(rootViewController: detailsView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func trashBtnAction() {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.PHOTO_DELETE_CLICKED)
        // Show an alert before delete
        self.showAcceptCancelMsg(message: StringConstants.StatusMessages.Photo_Delete_Msg, acceptBtnTxt: StringConstants.ButtonTitles.BTN_DELETE, closeBtnTxt: StringConstants.ButtonTitles.BTN_Cancel, title: StringConstants.ButtonTitles.TLT_Caution, isMessage: true, btnDispTypeParallel:true, acceptBlock: {
            
            
            let docModel = self.photoArray[self.selectedImgIdx]
            if let isSent = docModel.isSent {
                
                if Bool(truncating: isSent) {
                    // Change the document flag 'isPhotoDeleted' flag to true and make a delete request.
                    docModel.isPhotoDeleted = NSNumber(value: true)
                    JobServices.updateDocument(document: docModel)
                    
                    // Remove document from singleton Object and from gallery then return.
                    self.removeDocFrSingleTonObjAndGallery()
                    
                    return // DO NOT process the delete document functionalities
                }
            }
            
            
            
            
            // If Photo is not Sent yet. then just remove the document using normal process.
            // If user accept to delete the document/image, then delete the document from database and from application doument folder
            if self.photoArray[self.selectedImgIdx].deleteDocument(){
                
                // Remove document from singleton Object and from gallery.
                self.removeDocFrSingleTonObjAndGallery()
            }
        })
    }
    
    
    
    func removeDocFrSingleTonObjAndGallery() {
        if self.photoGalType == .JobVisitPhotos {
            // After deletion process has been completed then remove the item from the array and from the shared instance
            AppInfo.sharedInstance.selJobInstance.removeDocumentFromInst(documentId: self.photoArray[self.selectedImgIdx].documentId!)
        }
        else {
            // if the photo document is assicated with answer, then remove the document from answer object.
            var docIdx = 0
            for document in JobVisitModel.sharedInstance.answer.ansDocuments {
                if document.documentId! == self.photoArray[self.selectedImgIdx].documentId! {
                    JobVisitModel.sharedInstance.answer.ansDocuments.remove(at: docIdx)
                    break
                }
                docIdx += 1
            }
        }
        
        self.photoArray.remove(at: self.selectedImgIdx)
        
        
        // Then load the next item from array or previous item if the last deleted item was the last item of the array. If the array doesn't contain any photo/document after deletion process, then go back to previous page.
        if self.photoArray.count > 0 {
            if self.photoArray.count == self.selectedImgIdx {
                self.selectedImgIdx = self.selectedImgIdx - 1
            }
            let loadNextVC = [self.getItemController(self.selectedImgIdx)!]
            self.pageViewController?.setViewControllers(loadNextVC, direction: .forward, animated: false, completion: nil)
        }
        else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}




// UITextField Delegate functions
extension PhotoViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}


// Page View Controller swiping left right setup.
extension PhotoViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        selectedImgIdx = itemController.itemIndex
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! PageItemController
        selectedImgIdx = itemController.itemIndex
        
        if itemController.itemIndex+1 < photoArray.count {
            return getItemController(itemController.itemIndex+1)
        }
        
        return nil
    }
    
    
    fileprivate func getItemController(_ itemIndex: Int) -> PageItemController? {
        
        if itemIndex < photoArray.count {
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "ItemController") as! PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = photoArray[itemIndex].originalName!
            pageItemController.instanceId = photoArray[itemIndex].instanceId ?? ""
            return pageItemController
        }
        
        return nil
    }
    
    
    // MARK: - Additions
    func currentControllerIndex() -> Int {
        
        let pageItemController = self.currentController()
        
        if let controller = pageItemController as? PageItemController {
            return controller.itemIndex
        }
        
        return -1
    }
    
    func currentController() -> UIViewController? {
        if (self.pageViewController?.viewControllers?.count)! > 0 {
            return self.pageViewController?.viewControllers![0]
        }
        
        return nil
    }
}

