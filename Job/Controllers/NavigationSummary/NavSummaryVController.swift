//
//  NavSummaryVController.swift
//  Job V2
//
//  Created by Saleh Sultan on 1/12/17.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

class NavigationHeaderTVCell: UITableViewCell {
    
    @IBOutlet weak var summaryTitle: UILabel!
    @IBOutlet weak var summTitleIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        imgView.frame = self.frame
        self.backgroundView = imgView
        
        let selImgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        selImgView.frame = self.frame
        self.selectedBackgroundView = selImgView
        self.selectionStyle = .blue
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class NavSummaryVController: RootViewController {

    @IBOutlet weak var summaryTB: UITableView!
    @IBOutlet weak var gotoTopBtn: UIButton!
    
    
    let summaryArray = [StringConstants.MenuTitles.UNANSWERED_ONLY, StringConstants.MenuTitles.JOB_VISIT_INFO]
    let jobVisits: NSMutableArray = AppInfo.sharedInstance.selJobInstance.jobVisits
    let localFVs = NSMutableArray()
    var currTaskIdx:Int = 0
    var isShowingAllQ:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.SUMMARY_PG_TLT
        self.navigationItem.hidesBackButton = true
        
        self.summaryTB.estimatedRowHeight = 150.0; // for example. Set your average height
        self.summaryTB.rowHeight = UITableView.automaticDimension;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavRightBarItem()
        self.manageSlideMenu()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //09-4-19 [Updated] set the current question selected, (NEW->) if the list size is greater than current selected idx [default selected idx = 0]
        let count = isShowingAllQ ? self.localFVs.count - 1 : self.localFVs.count
        if currTaskIdx < count {
            let index = IndexPath(row: currTaskIdx, section: 1)
            self.summaryTB.selectRow(at: index, animated: true, scrollPosition: .top)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func gotoTopBtnAction(_ sender: Any) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.summaryTB.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}


extension NavSummaryVController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return summaryArray.count
        }
        
        self.localFVs.removeAllObjects()
        if isShowingAllQ {
            for fv in self.jobVisits {
                self.localFVs.add(fv)
            }
        } else {
            let unAnsFVs = self.jobVisits.filtered(using: NSPredicate(format: "answer.isAnswerCompleted = 0"))
            for fv in unAnsFVs {
                self.localFVs.add(fv)
            }
        }
        
        // Last page is the save page, which is not part of the survey task.
        return isShowingAllQ ? self.localFVs.count - 1 : self.localFVs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Show hide 'Go To Top' Button
        if self.summaryTB.contentOffset.y > 200 {
            gotoTopBtn.isHidden = false
        } else {
            gotoTopBtn.isHidden = true
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NavSumHdTVCell", for: indexPath) as! NavigationHeaderTVCell
            
            cell.summaryTitle.text = summaryArray[indexPath.row]
            cell.summaryTitle.textColor = .white
            
            if !isShowingAllQ && indexPath.row == 0 {
                cell.summaryTitle.text = StringConstants.MenuTitles.SHOW_ALL_QUES
            }
            if (indexPath.row == 0) {
                cell.summTitleIcon.image = isShowingAllQ ? UIImage(named: "HideMinusIcon") : UIImage(named: "ShowAllIcon")
            } else {
                cell.summTitleIcon.image = UIImage(named: "InfoIcon")
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NavInstTVCell", for: indexPath) as! NavigationInstTVCell
            
            if let jobVisit = self.localFVs.object(at: indexPath.row) as? JobVisitModel {
                if let task = jobVisit.task, let answer = jobVisit.answer {
                    
                    cell.summaryTitle.text = "\(jobVisit.taskNo ?? "") - \(task.taskText ?? "")"
                    
                    //IF the task is answered(i.e. in 'Answer' table, it contain a value for the task) then make the task text and asterick label to yellow. Otherwise make the task and asterick label text to white. Camera icon is different than this logic. Camera logic is added below to make the camera icon show/hide or white or yellow one.
                    cell.summaryTitle.textColor = Bool(truncating: answer.isAnswerCompleted ?? 0) ? Utility.UIColorFromRGB(Constants.LOGO_YELLOW_COLOR) : UIColor.white
                    cell.astericklbl.textColor  = Bool(truncating: answer.isAnswerCompleted ?? 0) ? Utility.UIColorFromRGB(Constants.LOGO_YELLOW_COLOR) : UIColor.white
                    
                    if let isRequired = task.required, let taskType = task.taskType {
                        if isRequired.intValue == 0 || taskType == .ParentTask {
                            cell.astericklbl.isHidden = true
                        }
                        else {
                            cell.astericklbl.isHidden = false
                        }
                    }
                    
                    if !(task.isActive ?? 0).boolValue {
                        cell.summaryTitle.textColor = .darkGray
                        cell.astericklbl.isHidden = true
                        cell.cameraIcon.isHidden = true
                        cell.photoCountlbl.isHidden = true
                        cell.selectionStyle = .none
                        
                        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
                        imgView.frame = cell.frame
                        cell.backgroundView = imgView
                        return cell
                    }
                    else if let taskType = task.taskType {
                        
                        if taskType == .ParentTask {
                            let imgView = UIImageView(image: UIImage(named: "CellBgImgBlue"))
                            imgView.frame = cell.frame
                            cell.backgroundView = imgView
                        } else {
                            let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
                            imgView.frame = cell.frame
                            cell.backgroundView = imgView
                        }
                    }
                    
                    if let isPhotoReq = task.photoRequired, let resolutionId = task.documentTypeId {
                        // According to SurveyV1.5 logic, if the photo not required and user hasn't been taken any photo for the associate task, then we don't need to display the camera icon or photo count lbl icon.
                        if isPhotoReq.intValue == 0 && answer.ansDocuments.count == 0 {
                            cell.cameraIcon.isHidden = true
                            cell.photoCountlbl.isHidden = true
                        }
                        else {
                            // We need to display the camera icon even the photo is not required and user took photo for the associated task answer.
                            cell.cameraIcon.isHidden = false
                            cell.photoCountlbl.isHidden = false
                            cell.photoCountlbl.text = "\(answer.ansDocuments.count)" //Show the number of photos available for this answer.
                            cell.cameraIcon.image = Utility.getDocumentNameForResId(resId: resolutionId, isAnswered: answer.ansDocuments.count > 0)
                        }
                    }
                }
            }
            if indexPath.section == 1 && indexPath.row == currTaskIdx {
                cell.isSelected = true
                cell.photoCountlbl.backgroundColor = Utility.UIColorFromRGB(Constants.PHOTO_COUNTER_RED_COLOR)
            }
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            //Un-answered or show all
            if indexPath.row == 0 {
                //Appsee.addScreenAction(isShowingAllQ ? StringConstants.AppseeScreenAction.NAV_SHOW_ALL_TAPPED : StringConstants.AppseeScreenAction.NAV_UNANSWERED_TAPPED)
                isShowingAllQ = !isShowingAllQ
                summaryTB.reloadData()
            }
            else if indexPath.row == 1, let viewControllers = self.navigationController?.viewControllers {
                //Appsee.addScreenAction(StringConstants.AppseeScreenAction.NAV_JOB_INFO_TAPPED)
                
                for viewController in viewControllers {
                    if viewController is JobVisitInfoViewController {
                        _ = self.navigationController?.popToViewController(viewController, animated: true)
                        break
                    }
                }
            }
        }
        else {
            self.loadTask(rowIdx: indexPath)
        }
    }
    
    func loadTask(rowIdx: IndexPath) {
        if let jobVisit = self.localFVs.object(at: rowIdx.row) as? JobVisitModel {
            if !(jobVisit.task!.isActive ?? 0).boolValue {
                return
            }
            //Appsee.addScreenAction("Q# \(jobVisit.taskNo ?? "XX") Clicked")
        }
        
        var controllerStack = [UIViewController]()
        self.summaryTB.deselectRow(at: rowIdx, animated: true)
        
        // Get all the viewControllers available in current navigation view stack.
        if let viewControllers = self.navigationController?.viewControllers {
            for controller in viewControllers {
                controllerStack.append(controller)
                
                // If a view controller is Field visit info page then break the array. Because after that we are suppose to add the task view list page.
                if controller is JobVisitInfoViewController {
                    break
                }
            }
        }
        
        var fvIdx = 0
        for fv in self.jobVisits {
            if let jobVisit = fv as? JobVisitModel {
                if jobVisit.task != nil{
                    let taskView = self.storyboard?.instantiateViewController(withIdentifier: "TaskVC") as! TaskViewController
                    taskView.currentTaskIdx = fvIdx
                    controllerStack.append(taskView)
                    
                    if let localFV = self.localFVs.object(at: rowIdx.row) as? JobVisitModel{
                        if jobVisit.taskNo == localFV.taskNo {
                            self.navigationController?.pushViewController(viewController: nil, direction: .Bottom)
                            self.navigationController?.viewControllers = controllerStack
                            break
                        }
                    }
                }
                fvIdx += 1
            }
        }
    }
}
