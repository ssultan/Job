//
//  UserLocation.swift
//  SurveyV2.0
//
//  Created by Saleh Sultan on 10/8/19.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//


import UIKit
import GoogleMaps
import GooglePlaces
import Firebase

class UserLocation: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = UserLocation()
    
    var gotAppseeLoc: Bool = false
    var locManager: CLLocationManager!
    var userCurrentLoc: CLLocationCoordinate2D!
    
    func startLocationUpdate() {
        self.gotAppseeLoc = false
        if self.locManager != nil {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                if self.locManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                    self.locManager.requestWhenInUseAuthorization()
                }
            }
            else if CLLocationManager.authorizationStatus() != .denied && CLLocationManager.authorizationStatus() != .restricted{
                self.locManager.startUpdatingLocation()
            }
        }
    }
    
    func stopLocationUpdate() {
        if self.locManager != nil { self.locManager.stopUpdatingLocation() }
    }
    
    func startTrackingUserLocation() {
        GMSPlacesClient.provideAPIKey(Constants.Keys.GOOGLE_SERVICE_KEY)
        GMSServices.provideAPIKey(Constants.Keys.GOOGLE_SERVICE_KEY)
        
        self.locManager = CLLocationManager()
        self.locManager.delegate = self
        self.locManager.distanceFilter = kCLLocationAccuracyBest
        self.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locManager.activityType = .automotiveNavigation
        self.locManager.pausesLocationUpdatesAutomatically = true
        self.locManager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            self.locManager.showsBackgroundLocationIndicator = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)  {
        if status == .authorizedWhenInUse {
            self.locManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let currentLoc = locations.first {
            self.userCurrentLoc = currentLoc.coordinate
            
            if (!self.gotAppseeLoc) {
                self.gotAppseeLoc = true
                self.locManager.stopUpdatingLocation()
                
                GMSGeocoder().reverseGeocodeCoordinate(currentLoc.coordinate, completionHandler: { (revResponse, error) in
                    if let response = revResponse {
                        if let results = response.results() {
                            if let addressObj = results.first {
                                let locDesc = "\(addressObj.locality ?? ""), \(addressObj.administrativeArea ?? ""), \(addressObj.country ?? "")"
                                //Appsee.setLocationDescription(locDesc)
                                //Appsee.setLocation(currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude, horizontalAccuracy: 0, verticalAccuracy: 0)
                                Crashlytics.crashlytics().setCustomValue(locDesc, forKey: "GeoLocation")
                                Analytics.logEvent("User_Location", parameters: ["Address": addressObj.locality ?? "",
                                                                                        "City": addressObj.administrativeArea ?? "",
                                                                                        "Country": addressObj.country ?? "",
                                                                                        "Latitude": currentLoc.coordinate.latitude,
                                                                                        "Longitude": currentLoc.coordinate.longitude])
                                
                                if let country = addressObj.country {
                                    if country != "United States" && country != "Canada" {
                                        Analytics.logEvent("Special_Users", parameters: ["GeoLocation": locDesc, "LatLong": "\(currentLoc.coordinate.latitude),\(currentLoc.coordinate.longitude)", "LocalDateTime": String(Utility.gmtStringFromDate(date: Date()))])
                                    }
                                    else {
                                        Analytics.logEvent(AnalyticsEventAppOpen, parameters: ["GeoLocation": locDesc, "LatLong": "\(currentLoc.coordinate.latitude),\(currentLoc.coordinate.longitude)"])
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}
