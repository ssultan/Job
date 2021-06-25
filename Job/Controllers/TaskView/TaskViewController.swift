//
//  TaskViewController.swift
//  Job
//
//  Created by Saleh Sultan on 6/10/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import JGProgressHUD


protocol TaskViewDelegate {
    
    var currentTaskIdx:Int { get set }
    
    func answerFromChild(answer:AnswerModel)
    func goToNextTask()
    func showTaskAnswerPhoto()
    func commentBtnAction()
    func disableEnableMovingToNewVC(isEnabled: Bool, withChoiceMsg: String?)
    func hideBottomButtons()
}

let LeftArrowTag = 101
let RightArrowTag = 102
let TaskTitleTag = 103
let TaskSubTitleTag = 104
let TaskReqStarTag = 105

class TaskViewController: RootViewController, TaskViewDelegate {
    
    var tapNavGest: UITapGestureRecognizer!
    var swipeDownGest: UISwipeGestureRecognizer!
    var swipeUpGest: UISwipeGestureRecognizer!
    var swipeLeftGest: UISwipeGestureRecognizer!
    var swipeRightGest: UISwipeGestureRecognizer!
    
    var isNavigatingAllowed = true
    var isShowingInstruction = false
    internal var currentTaskIdx:Int = -1
    let instance = AppInfo.sharedInstance.selJobInstance
    var jobVisits: NSMutableArray!
    var dateTimeVId: String = ""
    var choicePromptTxt: String?
    var currentFB: JobVisitModel?
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var taskConView: UIView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var commentIcon: UIImageView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var photoCounterlbl: UILabel!
    @IBOutlet weak var taskSubTitle: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var subTltView: UIView!
    @IBOutlet weak var rightArrowBtn: UIButton!
    @IBOutlet weak var infoBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var headerTask: UILabel!
    
    var taskChildView:ParentTaskView!
    var instructionView: InstructionViewController!
    
    // Define the progress bar
    var loadingView = JGProgressHUD(style: .extraLight)
    
    
    //MARK: - View life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        jobVisits = instance?.jobVisits
        self.removeNavigationBarItem()
        
        self.setNavRightBarItem()
        self.manageSlideMenu()
        self.navigationItem.hidesBackButton = false
        
        
        // If the current task is not the last task of this survey, then show right arrow.
        if currentTaskIdx + 1 < jobVisits.count {
            rightArrowBtn.isHidden = false
            subTltView.isHidden = false
            self.navigationItem.hidesBackButton = true
            self.loadQPageDetailAtStart()
        } else {
            self.loadEndOfSurveyPage()
        }
        
        //Setup Gesture Recognizers
        self.gestureRecognizerSetup()
        
        self.photoCounterlbl.layer.cornerRadius = 10
        self.photoCounterlbl.clipsToBounds = true
        self.instructionView = self.storyboard!.instantiateViewController(withIdentifier: "InstructionVC") as? InstructionViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.addGestureRecognizer(tapNavGest)
        
        // Enable navigation controller Gesture recognizer
        if let gestureRegs = self.navigationController?.navigationBar.gestureRecognizers {
            for eachItem in gestureRegs {
                eachItem.isEnabled = true
            }
        }
        
        //Update title each time land on the task view page
        if currentTaskIdx + 1 < jobVisits.count, let jobVisit = jobVisits.object(at: currentTaskIdx) as? JobVisitModel {
            self.reloadQParentView(jobVisit)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let fvInfo = currentFB {
            if fvInfo.task != nil, let taskType = fvInfo.task.taskType {
                if taskType == .ParentTask, let answer = fvInfo.answer {
                    answer.isAnswerCompleted = NSNumber(value: true)
                    answer.syncAnswerToDB()
                }
            }
        }
        
        // Disable navigation controller all Gesture recognizers
        if let gestureRecs = self.navigationController?.navigationBar.gestureRecognizers {
            for gesture in gestureRecs {
                self.navigationController?.navigationBar.removeGestureRecognizer(gesture)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if currentTaskIdx + 1 < jobVisits.count {
            // if the task is showing instructions, then make the camera and comment button zposition to 0. it means as background view
            if isShowingInstruction {
                self.setupContentzPosition(0)
                return
            }
            if self.taskChildView != nil {
                self.taskChildView.view.frame = taskConView.bounds
                self.taskChildView.view.sizeToFit()
            }
            self.setupContentzPosition(1)
        }
        else {
            taskConView.isHidden = true // Save Btn
        }
    }
    
    fileprivate func setupContentzPosition(_ position: CGFloat) {
        cameraBtn.layer.zPosition = position
        cameraIcon.layer.zPosition = position
        photoCounterlbl.layer.zPosition = position
        commentBtn.layer.zPosition = position
        commentIcon.layer.zPosition = position
    }
    
    fileprivate func loadQPageDetailAtStart() {
        // Load survey task title and subtitle.
        if let jobVisit = jobVisits.object(at: currentTaskIdx) as? JobVisitModel {
            currentFB = jobVisit
            
            if let task = jobVisit.task {
                taskTitle.text = "\(jobVisit.taskNo ?? "0") - \(task.taskText ?? "")"
                
                // set the camera icon based on document resolution type Id
                if task.photoRequired?.intValue == 0, let resolutionId = task.documentTypeId {
                    self.cameraIcon.image = Utility.getDocumentNameForResId(resId: resolutionId, isAnswered: false)
                }
                
                if let _ = task.longDesc, task.longDesc != "" {
                    self.infoBtn.isHidden = false
                    self.infoBtnWidth.constant = 28
                }
            }
        }
        //Setup the main task body of the page.
        self.setupTaskView()
    }
    
    fileprivate func reloadQParentView(_ jobVisit: JobVisitModel) {
        
        self.title = StringConstants.PageTitles.JOB_TASKS_PG_TLT
        self.taskSubTitle.text = "\((jobVisit.task.required?.boolValue)! ? "★   " : "")\(jobVisit.taskNo ?? "0") of \(jobVisits.count - 1)"
        self.taskSubTitle.text = "\((jobVisit.task.required?.boolValue)! ? "★   " : "")\(jobVisit.taskNo ?? "0") of \(jobVisits.count - 1)"
        
        if let answer = jobVisit.answer, let photoReq = jobVisit.task.photoRequired, let resTypeId = jobVisit.task.documentTypeId {
            
            if answer.ansDocuments.count > 0 {
                self.photoCounterlbl.text = "\(answer.ansDocuments.count )"
                self.photoCounterlbl.isHidden = false
                self.cameraIcon.image = Utility.getDocumentNameForResId(resId: resTypeId, isAnswered: true)
            } else if let quesType = jobVisit.task.taskType {
                
                if quesType != .ParentTask {
                    self.photoCounterlbl.isHidden = false
                    cameraIcon.image = Utility.getDocumentNameForResId(resId: resTypeId, isAnswered: false) //UIImage(named: "CameraNew-White")
                    
                    // For multichoice task type, we disabled global photo button. SO no need.
                    if Bool(truncating: photoReq){
                        self.photoCounterlbl.text = "★"
                    } else {
                        self.photoCounterlbl.isHidden = true
                    }
                }
            }
        }
        
        if jobVisit.answer.comments.count > 0 {
            self.commentIcon.image = UIImage(named: "comment-yellow")
        } else {
            self.commentIcon.image = UIImage(named: "comment-white")
        }
    }
    
    fileprivate func loadEndOfSurveyPage() {
        //Last page doesn't contain any subtitle.
        saveBtn.isHidden = false
        taskTitle.isHidden = true
        cameraBtn.isHidden = true
        cameraIcon.isHidden = true
        commentBtn.isHidden = true
        commentIcon.isHidden = true
        photoCounterlbl.isHidden = true
        self.title = StringConstants.PageTitles.SAVE_JOB_PAGE_TLT
        AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.END_OF_JOB
    }
    
    func answerFromChild(answer:AnswerModel) {
        //Save task answer details to database, It will automatically update the current sharedInstance(SingleTon Object)
        answer.syncAnswerToDB()
    }
    
    private lazy var titleLabel:UILabel = {
        let isLandScape = UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft
        let titleLabel = UILabel(frame: CGRect(x: 0, y: isLandScape ? -2 : 4, width: 0, height: 0))
        
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = Utility.UIColorFromRGB(Constants.LOGO_YELLOW_COLOR)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.tag = TaskTitleTag
        return titleLabel
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let isLandScape = UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: isLandScape ? 18 : 25, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .white  //isAnswered ? Utility.UIColorFromRGB(Constants.LOGO_YELLOW_COLOR) :
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.tag = TaskSubTitleTag
        return subtitleLabel
    }()
    
    private lazy var astricklbl: UILabel = {
        let isLandScape = UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft
        let astricklbl = UILabel(frame: CGRect(x: subTitleLabel.frame.origin.x - 18, y: isLandScape ? 18 : 25, width: 0, height: 0))
        astricklbl.backgroundColor = .clear
        astricklbl.font = UIFont.boldSystemFont(ofSize: 12)
        astricklbl.text = "★"
        astricklbl.tag = TaskReqStarTag
        astricklbl.sizeToFit()
        return astricklbl
    }()
    
    fileprivate func gestureRecognizerSetup() {
        // Gesture Recognizer to show Survey Summary page. On touch of the navigation bar and the second one is responsible for swiping to the down direction
        if tapNavGest == nil {
            tapNavGest = UITapGestureRecognizer(target: self, action: #selector(showSurveySummary))
            tapNavGest.delegate = self
        }
        if swipeDownGest == nil {
            swipeDownGest = UISwipeGestureRecognizer(target: self, action: #selector(showSurveySummary))
            swipeDownGest.direction = .down
        }
        if swipeUpGest == nil {
            // This swipe gesture is responsible for showing task answer photo gallery.
            swipeUpGest = UISwipeGestureRecognizer(target: self, action: #selector(showTaskAnswerPhoto))
            swipeUpGest.direction = .up
        }
        if swipeLeftGest == nil {
            // This swipe gesture is responsible for to show the next task
            swipeLeftGest = UISwipeGestureRecognizer(target: self, action: #selector(goToNextTask))
            swipeLeftGest.direction = .left
            swipeLeftGest.delegate = self
        }
        if swipeRightGest == nil {
            // This swipe gesture is responsible for either go back to preivous task or go back to field visit page if the current task is the first task.
            swipeRightGest = UISwipeGestureRecognizer(target: self, action: #selector(goBackToPreviousTask))
            swipeRightGest.direction = .right
            swipeRightGest.delegate = self
        }
        
        self.view.addGestureRecognizer(swipeDownGest)
        self.view.addGestureRecognizer(swipeUpGest)
        self.view.addGestureRecognizer(swipeRightGest)
        
        // If the current task is not the last task of this survey, then show right arrow.
        if currentTaskIdx + 1 < jobVisits.count {
            self.view.addGestureRecognizer(swipeLeftGest)
        }
    }
    
    
    //MARK: - SETUP Quetsion View
    fileprivate func setupTaskView() {
        
        if let jobVisitInfo = currentFB {
            //Having some problem to update the task number after adding a new task at the middle of the template. That's why I added this below line of code to update the task number in answer object.
            jobVisitInfo.answer.taskNo = jobVisitInfo.taskNo
            
            if let childSubVC = TaskFactory.getTaskVC(forJobVisit: jobVisitInfo, withViewHeight: self.taskConView.bounds.height) {
                if self.taskChildView != nil {
                    self.taskChildView.view.removeFromSuperview()
                    self.taskChildView.removeFromParent()
                }
                self.taskChildView = childSubVC
                self.taskChildView.initFun(jobVisitInfo: jobVisitInfo, delegate: self)
                self.addChild(taskChildView)
                self.taskConView.addSubview(taskChildView.view)
                self.taskChildView.didMove(toParent: self)
            } else {
                taskTitle.isHidden = true
                headerTask.isHidden = false
                photoCounterlbl.isHidden = true
                headerTask.text = taskTitle.text
                bgImgView.image = UIImage(named: "BgImgBlue")
                hideBottomButtons()
            }
        }
    }
    
    func disableAllGestures() {
        isShowingInstruction = true
        for gesture in self.view.gestureRecognizers! {
            gesture.isEnabled = false
        }
    }
    
    func enableAllGestures() {
        isShowingInstruction = false
        for gesture in self.view.gestureRecognizers! {
            gesture.isEnabled = true
        }
    }
    
    @objc func showSurveySummary() {
        // Navigation is not allowed for Single Choice task; For choice task choosen value required comment, which is not answered yet.
        if !isNavigatingAllowed {
            self.navigationNotAllowedDisplayMsg()
            return
        }
        
        let summaryView = self.storyboard?.instantiateViewController(withIdentifier: "NavSummaryVC") as! NavSummaryVController
        summaryView.currTaskIdx = self.currentTaskIdx
        self.navigationController?.pushViewController(viewController: summaryView, direction: NavPushDirection.Top)
    }
    
    
    //MARK: - Button event actions
    @IBAction func showTaskAnswerPhoto() {
        if self.currentTaskIdx == self.jobVisits.count-1 {
            return
        }
        // Navigation is not allowed for Single Choice task; For choice task choosen value required comment, which is not answered yet.
        if !isNavigatingAllowed {
            self.navigationNotAllowedDisplayMsg()
            return
        }
        
        guard (TaskFactory.getTaskVC(forJobVisit: currentFB!, withViewHeight: self.taskConView.bounds.height) != nil) else {
            return
        }
        self.TakePhotoBtnAction()
    }
    
    func TakePhotoBtnAction() {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.PHOTO_BTN_CLICKED)
        //--------------- * * * * * ------------------------
        // For all other type tasks. Except Configurable
        let photoGallery = self.storyboard?.instantiateViewController(withIdentifier: "PhotoGalleryVC") as! PhotoGalleryViewController
        photoGallery.photoGalType = .TaskPhotos
        photoGallery.taskDelegate = self.taskChildView as? TaskDetailsDelegate
        if let fv = self.currentFB {
            JobVisitModel.sharedInstance = fv
        }
        self.navigationController?.pushViewController(viewController: photoGallery, direction: NavPushDirection.Bottom)
    }
    
    @IBAction func saveBtnAction() {
        // Disable navigation controller all Gesture recognizers
        if let gestureRecs = self.navigationController?.navigationBar.gestureRecognizers {
            for gesture in gestureRecs {
                gesture.isEnabled = false
            }
        }
        
        if let vcList = self.navigationController?.viewControllers {
            for viewController in vcList {
                if viewController is JobVisitInfoViewController {
                    _ = self.navigationController?.popToViewController(viewController, animated: true)
                    return
                }
            }
        }
    }
    
    @IBAction func infoBtnAction() {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.INFO_BTN_CLICKED)
        var instructionMsg = ""
        if let task = self.currentFB?.task {
            instructionMsg = task.longDesc!
        }
        
        self.disableAllGestures()
        self.instructionView.showInView(self.view, withInstruction: instructionMsg,
                                        withInstructTitle: StringConstants.ButtonTitles.TLT_QUES_INSTRUCTIONS,
                                        withInstructionType: InstructionType.Text,
                                        animated: true, closeBlock: {
                                            self.enableAllGestures()
        })
    }
    
    @IBAction func commentBtnAction() {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.COMMENT_BTN_CLICKED)
        let commentView = self.storyboard!.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsViewController
        commentView.answerModel = currentFB?.answer
        self.navigationController?.pushViewController(viewController: commentView, direction: NavPushDirection.Bottom)
    }
    
    func hideBottomButtons() {
        cameraBtn.isHidden = true
        cameraIcon.isHidden = true
        commentBtn.isHidden = true
        commentIcon.isHidden = true
        photoCounterlbl.isHidden = true
    }
    
    @IBAction func goToNextTask() {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.Q_NEXT_BTN_CLICKED)
        
        // Navigation is not allowed for Single Choice task; For choice task choosen value required comment, which is not answered yet.
        if !isNavigatingAllowed {
            self.navigationNotAllowedDisplayMsg()
            return
        }
        
        var index = self.currentTaskIdx
        
        // Get next parent task index, which is not a brach to task.
        while (true) {
            if index + 1 < self.jobVisits.count {
                if let jobVisit = self.jobVisits.object(at: index + 1) as? JobVisitModel {
                    if let task = jobVisit.task {
                        if !(task.isActive ?? 0).boolValue {
                            index += 1
                        } else { break }
                    }
                    else if index + 1 == self.jobVisits.count - 1 {
                        // This is the last task with save button which is not actually the part of the survey
                        break
                    }
                }
                else { return }
            }
            else { return }
        }
        
        if index + 1 < self.jobVisits.count {
            let taskView = self.storyboard?.instantiateViewController(withIdentifier: "TaskVC") as! TaskViewController
            taskView.currentTaskIdx = index + 1
            self.navigationController?.pushViewController(taskView, animated: true)
        }
    }
    
    
    @IBAction func goBackToPreviousTask() {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.Q_PREV_BTN_CLICKED)
        
        // Navigation is not allowed for Single Choice task; For choice task choosen value required comment, which is not answered yet.
        if !isNavigatingAllowed {
            self.navigationNotAllowedDisplayMsg()
            return
        }
        if self.currentTaskIdx == 0, let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is JobVisitInfoViewController  {
                    _ = self.navigationController?.popToViewController(viewController, animated: true)
                }
            }
        }
        else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func navigationNotAllowedDisplayMsg() {
        self.popViewController.showInView(self.navigationController?.view, withTitle: StringConstants.ButtonTitles.TLT_COMMENTS_REQ, withMessage:choicePromptTxt ?? "", withCloseBtTxt: StringConstants.ButtonTitles.BTN_OK, withAcceptBt: nil, animated: true, isMessage: false, continueBlock: {}, cancelBlock: {
            
            self.commentBtnAction()
        })
    }
    
    func disableEnableMovingToNewVC(isEnabled: Bool, withChoiceMsg promptTxt: String?) {
        isNavigatingAllowed = isEnabled
        choicePromptTxt = promptTxt
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let touchView = touch.view {
            if touchView.isKind(of: StepSlider.self) {
                return false
            }
        }
        return true
    }
}
