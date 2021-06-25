//
//  SelectLocationViewController.swift
//  Job V2
//
//  Created by Saleh Sultan on 9/7/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import MapKit

let GoogleOpenURL = "comgooglemaps://"

class SelectLocationViewController: RootViewController, UITableViewDelegate, UITableViewDataSource {

    var locationList = [LocationModel]()
    var projectId: String!
    var stateName: String!
    var cityName : String!
    @IBOutlet weak var tbView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = StringConstants.PageTitles.SELECT_LOCATION_PAGE_TLT
        self.navigationItem.leftBarButtonItem = nil
        
        self.locationList = DBLocationServices.sharedInstance.getLocationListForCityState(projectId, state: stateName, city: cityName)
        self.tbView.tableFooterView = UIView()
        self.tbView.estimatedRowHeight = 280.0; // for example. Set your average height
        self.tbView.rowHeight = UITableView.automaticDimension;
        self.setNavRightBarItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tbView.indexPathForSelectedRow else {return}
        
        let jobInfo = segue.destination as! JobVisitInfoViewController
        jobInfo.instance = self.loadInstance(forIdx: indexPath.row)
        tbView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func loadInstance(forIdx row:Int) -> JobInstanceModel {
        //Appsee.addScreenAction("Store #\(locationList[row].storeNumber ?? "xxxx") Selected")
        let jobInstance = JobServices.getInstance(forLocation: locationList[row])
        AppInfo.sharedInstance.selJobInstance = jobInstance
        return jobInstance
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LocationCardCell = tableView.dequeueReusableCell(withIdentifier: "LocationCardCell", for: indexPath) as! LocationCardCell
        let location = locationList[indexPath.row]
        
        cell.storeNolbl.text = (location.locationName)! as String
        cell.addresslbl.text = (location.address)! as String
        cell.cityStZiplbl.text = "\((location.city)! as String), \((location.state)! as String) \((location.zipCode)! as String)"
        cell.mapDirLocation.addTarget(self, action: #selector(mapDirectionBtnAction(sender:)), for: .touchUpInside)
        cell.streetViewBtn.addTarget(self, action: #selector(mapStreetViewBtnAction(sender:)), for: .touchUpInside)
        
        if let locId = location.locationId {
            cell.mapDirLocation.tag = Int(locId)!
            cell.streetViewBtn.tag = Int(locId)!
        }
        
        return cell
    }
    
    //MARK: - Button Action Event
    @objc func mapDirectionBtnAction(sender: UIButton) {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.MAP_DIRECTION_CLICKED)
        if let location = self.locationList.filter({$0.locationId == String(sender.tag)}).first {
            
            // If latitude and longitude is available along with the physical address.
            if let latitude = location.latitude, let longitude = location.longitude, let address = location.address, let city = location.city, let state = location.state, let zipCode = location.zipCode {

                // If google map is available
                if (UIApplication.shared.canOpenURL(URL(string: GoogleOpenURL)!)) {
                    if let url = URL(string:
                        "\(GoogleOpenURL)?q=\(address.replacingOccurrences(of: " ", with: "+")),\(city.replacingOccurrences(of: " ", with: "+")),\(state.replacingOccurrences(of: " ", with: "+"))-\(zipCode.replacingOccurrences(of: " ", with: "+"))&center=\(latitude),\(longitude)&zoom=14&views=standard") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                else if let latVal = Double(latitude), let longVal = Double(longitude) {
                    self.openInAppleMap(forName:location.locationName ?? "", forLatitude: latVal, forLongitude: longVal)
                }
            }
            // If not then use the physical address to locate
            else if let address = location.address, let city = location.city, let state = location.state, let zipCode = location.zipCode {
                
                // If google map is available
                if (UIApplication.shared.canOpenURL(URL(string: GoogleOpenURL)!)) {
                    if let url = URL(string:
                        "\(GoogleOpenURL)?q=\(address.replacingOccurrences(of: " ", with: "+")),\(city.replacingOccurrences(of: " ", with: "+")),\(state.replacingOccurrences(of: " ", with: "+"))-\(zipCode.replacingOccurrences(of: " ", with: "+"))&zoom=14&views=standard") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                else {
                    LocationWService.geoCodeUsingAddress(address: "\(address.replacingOccurrences(of: " ", with: "+")),\(city.replacingOccurrences(of: " ", with: "+")),\(state)-\(zipCode)", completionHandler: { (locationAPI) in
                        self.openInAppleMap(forName:location.locationName ?? "", forLatitude: locationAPI.latitude, forLongitude: locationAPI.longitude)
                    })
                }
            }
        }
    }
    
    fileprivate func openInAppleMap(forName locName:String, forLatitude latitude:CLLocationDegrees, forLongitude longitude:CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = locName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    
    @objc func mapStreetViewBtnAction(sender: UIButton) {
        //Appsee.addScreenAction(StringConstants.AppseeScreenAction.GOOGLE_STREETVIEW_CLICKED)
        if let location = self.locationList.filter({$0.locationId == String(sender.tag)}).first {
            if let latitude = location.latitude, let longitude = location.longitude {
                
                AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.GOOGLE_STREETVIEW_PAGE
                let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalWebVC") as! GlobalWebViewController
                globalVC.viewTitle = StringConstants.PageTitles.GOOGLE_STREET_VIEW_PTLE
                globalVC.pageType = .googleStreetView
                globalVC.latitude = Double(latitude) ?? 0
                globalVC.longitude = Double(longitude) ?? 0
                self.navigationController?.pushViewController(globalVC, animated: true)
            }
            else if let address = location.address, let city = location.city, let state = location.state, let zipCode = location.zipCode {
                LocationWService.geoCodeUsingAddress(address: "\(address.replacingOccurrences(of: " ", with: "+")),\(city.replacingOccurrences(of: " ", with: "+")),\(state)-\(zipCode)", completionHandler: { (location) in
                    
                    AppInfo.sharedInstance.pageAboutToLoad = StringConstants.AppseePageTitles.GOOGLE_STREETVIEW_PAGE
                    let globalVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalWebVC") as! GlobalWebViewController
                    globalVC.viewTitle = StringConstants.PageTitles.GOOGLE_STREET_VIEW_PTLE
                    globalVC.pageType = .googleStreetView
                    globalVC.latitude = location.latitude
                    globalVC.longitude = location.longitude
                    self.navigationController?.pushViewController(globalVC, animated: true)
                })
            }
        }
    }
}
