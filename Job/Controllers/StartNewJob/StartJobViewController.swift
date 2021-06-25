//
//  StartJobViewController.swift
//  Job
//
//  Created by Saleh Sultan on 5/21/19.
//  Copyright © 2019 Davaco Inc. All rights reserved.
//

import UIKit

class StartJobViewController: RootViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var jobListTb: UITableView!
    var jobTempArr = [TemplateModel]()
    @IBOutlet weak var noTempAsslbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.SELECT_JOB_PAGE_TLT
        self.navigationItem.leftBarButtonItem = nil
        if let tempArray = DBTemplateServices.sharedInstance.getAllTemplatesForCurrentUser() {
            self.jobTempArr = tempArray
            if tempArray.count == 0 { self.noTempAsslbl.isHidden = false }
        }
        
        self.jobListTb.tableFooterView = UIView()
        self.jobListTb.estimatedRowHeight = 70.0; // for example. Set your average height
        self.jobListTb.rowHeight = UITableView.automaticDimension;
        
        self.setNavRightBarItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = jobListTb.indexPathForSelectedRow else {return}
        jobListTb.deselectRow(at: indexPath, animated: true)
        
        let stateVC = segue.destination as! StateCityViewController
        stateVC.loadListType = .stateList
        stateVC.projectId = getProjectId(forIdx: indexPath.row)
    }
    
    
    //MARK: - UITableView Delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobTempArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:StartJobTvCell = tableView.dequeueReusableCell(withIdentifier: "StartJobTVCIdentifier", for: indexPath) as! StartJobTvCell
        cell.updateCell(template: jobTempArr[(indexPath as NSIndexPath).row])
        return cell
    }
    
    func getProjectId(forIdx idx: Int) -> String {
        let template = jobTempArr[idx]
        AppInfo.sharedInstance.selectedTemplate = template
        AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.SELECT_STATE_PAGE
        //Appsee.addScreenAction("'\(template.templateName ?? "XX")' Selected")
        return template.projectId ?? "0"
    }
}
