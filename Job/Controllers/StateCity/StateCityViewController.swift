//
//  StateCityViewController.swift
//  Job V2
//
//  Created by Saleh Sultan on 8/23/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit

enum LoadDataType {
    case stateList
    case cityList
}

class StateCityViewController: RootViewController, UITableViewDelegate, UITableViewDataSource {

    var loadListType: LoadDataType!
    var projectId: String!
    var itemList: [String]!
    var stateName: String!
    
    @IBOutlet weak var noItemslbl: UILabel!
    @IBOutlet weak var tbView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if loadListType == .stateList {
            self.title = StringConstants.PageTitles.SELECT_STATE_PAGE_TLT
            self.itemList = DBLocationServices.sharedInstance.getStateListForProjectId(projectId)
        } else if loadListType == .cityList {
            self.title = StringConstants.PageTitles.SELECT_CITY_PAGE_TLT
            self.itemList = DBLocationServices.sharedInstance.getCityListForState(projectId, state: stateName)
        }
        
        // Show the message of no item available.
        if self.itemList.count == 0 {
            noItemslbl.isHidden = false
        } else {
            noItemslbl.isHidden = true
        }
        
        tbView.tableFooterView = UIView()
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
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemList != nil {
            return itemList.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        cell.textLabel?.text = itemList[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = .white
        cell.textLabel?.backgroundColor = .clear
        cell.textLabel?.font = UIFont(name: "Arial", size: 18)
        
        let imgView = UIImageView(image: UIImage(named: "CellBgImg"))
        imgView.frame = cell.frame
        cell.backgroundView = imgView
        cell.accessoryType = .disclosureIndicator
        
        let selImgView = UIImageView(image: UIImage(named: "CellBgSelected"))
        selImgView.frame = cell.frame
        cell.selectedBackgroundView = selImgView
        cell.selectionStyle = .blue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if loadListType == .stateList {
            AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.SELECT_CITY_PAGE
            //Appsee.addScreenAction("'\(itemList[(indexPath as NSIndexPath).row])' Selected")
            
            let stateV = self.storyboard?.instantiateViewController(withIdentifier: "StateCityVC") as! StateCityViewController
            stateV.loadListType = .cityList
            stateV.projectId = projectId
            stateV.stateName = itemList[(indexPath as NSIndexPath).row]
            self.navigationController?.pushViewController(stateV, animated: true)
        }
        else {
            AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.SELECT_STATE_PAGE
            //Appsee.addScreenAction("'\(itemList[(indexPath as NSIndexPath).row])' Selected")
            
            let locationView = self.storyboard?.instantiateViewController(withIdentifier: "SelectLocationVC") as! SelectLocationViewController
            locationView.projectId = projectId
            locationView.stateName = stateName
            locationView.cityName = itemList[(indexPath as NSIndexPath).row]
            self.navigationController?.pushViewController(locationView, animated: true)            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
}
