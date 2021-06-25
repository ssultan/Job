//
//  BaseService.swift
//  Job V2
//
//  Created by Saleh Sultan on 6/5/19.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import UIKit
import Alamofire
import DeviceKit

@objc class BaseService: NSObject {
    
    func fetchData(_ requestType:HTTPMethod, serviceURL: String, params: [String : AnyObject]?, completionClosure:@escaping (_ jsonRes: AnyObject?, _ statusCode: Int, _ isSucceeded:Bool) ->()) {
        
        let apiLogModel = ApiLogsModel()
        apiLogModel.reqURL = serviceURL
        apiLogModel.reqMethod = requestType.rawValue
        apiLogModel.requestTime = NSDate()
        
        let hearders = HTTPHeaders(getHeaders() ?? [:])
        AF.request(serviceURL, method: requestType, parameters: params, encoding: JSONEncoding.default, headers: hearders)
            .downloadProgress(closure: { (progress) in
                //print("Count: \(progress.completedUnitCount)/\(progress.totalUnitCount) < - >  File:  < - >  Fraction Completed: \(progress.fractionCompleted)")
            })
            .validate()
            .responseJSON { response in
            
                apiLogModel.responseTime = NSDate()
                apiLogModel.resTimeInSec = NSNumber(value: NSDate().timeIntervalSince((apiLogModel.requestTime as Date?)!))
                
                let statusCode = response.response?.statusCode ?? HttpRespStatusCodes.RequestTimeOut.rawValue
                apiLogModel.responseStatus = NSNumber(value: statusCode)
                
                switch response.result {
                    case .success(_):
                        if statusCode == HttpRespStatusCodes.HTTP_200_OK.rawValue {
                            DBErrorLogServices.storeAllAPILogs(apiLogModel: apiLogModel)
                            
                            do {
                                let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                                completionClosure(json as AnyObject?, statusCode, true)
                            } catch {
                                completionClosure(nil, statusCode, false)
                            }
                        }
                        else {
                            do {
                                print("Response: \(response.response!) -> Data: \(response.data!) -> statusCode: \(statusCode)")
                                let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                                apiLogModel.responseJson = String(describing: json)
                                DBErrorLogServices.storeAllAPILogs(apiLogModel: apiLogModel)
                                completionClosure(json as AnyObject?, statusCode, false)
                            }
                            catch {
                                completionClosure(self.parseError(error as NSError) as AnyObject?, statusCode, false)
                            }
                        }
                        break
                    case .failure(let afError):
                        if let jData = response.data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: jData, options: JSONSerialization.ReadingOptions.mutableContainers)
                                apiLogModel.responseJson = String(describing: json)
                                DBErrorLogServices.storeAllAPILogs(apiLogModel: apiLogModel)
                                completionClosure(json as AnyObject?, statusCode, false)
                            }
                                
                            catch {
                                if let apiRes = response.response {
                                    apiLogModel.responseJson = String(describing: apiRes)
                                }
                                
                                DBErrorLogServices.storeAllAPILogs(apiLogModel: apiLogModel)
                                if let error = afError.underlyingError  {
                                    completionClosure(self.parseError(error as NSError) as AnyObject?, statusCode, false)
                                } else {
                                    completionClosure(["ErrorCode": HttpRespStatusCodes.RequestTimeOut.rawValue,
                                    StringConstants.ButtonTitles.TLT_Message: StringConstants.StatusMessages.Request_Timeout_Global] as AnyObject, HttpRespStatusCodes.RequestTimeOut.rawValue, false)
                                }
                            }
                        } else {
                            apiLogModel.responseStatus = NSNumber(value: HttpRespStatusCodes.RequestTimeOut.rawValue)
                            DBErrorLogServices.storeAllAPILogs(apiLogModel: apiLogModel)
                            completionClosure(["ErrorCode": HttpRespStatusCodes.RequestTimeOut.rawValue,
                                    StringConstants.ButtonTitles.TLT_Message: StringConstants.StatusMessages.Request_Timeout_Global] as AnyObject, HttpRespStatusCodes.RequestTimeOut.rawValue, false)
                        }
                        
                        break
                }
        }
    }
    
    
    /*
    func fetchData(_ requestType:HTTPMethod, serviceURL: String, params: [String : AnyObject]?, completionClosure:@escaping (_ jsonRes: AnyObject?, _ statusCode: Int, _ isSucceeded:Bool) ->()) {
        
        Alamofire.request(serviceURL, method: requestType, parameters: params, encoding: JSONEncoding.default, headers: getHeaders())
            .downloadProgress(closure: { (progress) in
                //print("Count: \(progress.completedUnitCount)/\(progress.totalUnitCount) < - >  File:  < - >  Fraction Completed: \(progress.fractionCompleted)")
            })
            .validate { request, response, data in
                // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                return .success
            }
            .responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    
                    if(response.result.isSuccess && statusCode == HttpRespStatusCodes.HTTP_200_OK.rawValue) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                            completionClosure(json as AnyObject?, statusCode, true)
                        } catch {
                            completionClosure(nil, statusCode, false)
                        }
                    }
                    else {
                        
                        //print("response.request: \(response.request!)\n NEXT: \(response.result)")
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                            print("Response: \(response.response!) -> Data: \(response.data!) -> statusCode: \(statusCode)")
                            completionClosure(json as AnyObject?, statusCode, false)
                        }
                            
                        catch {
                            if let error = response.result.error {
                                completionClosure(self.parseError(error as NSError) as AnyObject?, statusCode, false)
                            } else {
                                completionClosure(nil, statusCode, false)
                            }
                        }
                    }
                }
                else {
                    completionClosure(["ErrorCode": HttpRespStatusCodes.RequestTimeOut.rawValue,
                                       StringConstants.ButtonTitles.TLT_Message: StringConstants.StatusMessages.Request_Timeout_Global] as AnyObject, HttpRespStatusCodes.RequestTimeOut.rawValue, false)
                }
        }
    }*/
    
    func fetchReponseInData(forRequestType type:HTTPMethod, forServiceURL url: String, params: [String : AnyObject]?, completionClosure:@escaping (_ jsonRes: AnyObject?, _ data: Data?, _ statusCode: Int, _ isSucceeded:Bool) ->()) {
        
        let apiLogModel = ApiLogsModel()
        apiLogModel.reqURL = url
        apiLogModel.reqMethod = type.rawValue
        apiLogModel.requestTime = NSDate()
        
        let hearders = HTTPHeaders(getHeaders() ?? [:])
        AF.request(url, method: type, parameters: params, encoding: JSONEncoding.default, headers: hearders)
            .downloadProgress(closure: { (progress) in
            })
            .validate()
            .responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    
                    switch response.result {
                        case .success(_):
                            if statusCode == HttpRespStatusCodes.HTTP_200_OK.rawValue {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                                    completionClosure(json as AnyObject?, response.data!, statusCode, true)
                                } catch {
                                    completionClosure(nil, nil, statusCode, false)
                                }
                            }
                            else {
                                do {
                                    print("Response: \(response.response!) -> Data: \(response.data!) -> statusCode: \(statusCode)")
                                    let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                                    completionClosure(json as AnyObject?, response.data!, statusCode, false)
                                }
                                catch {
                                    if let error = error as NSError? {
                                        completionClosure(self.parseError(error as NSError) as AnyObject?, nil, statusCode, false)
                                    } else {
                                        completionClosure(nil, nil, statusCode, false)
                                    }
                                }
                            }
                            break
                        case .failure(let afError):
                            if let jData = response.data {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: jData, options: JSONSerialization.ReadingOptions.mutableContainers)
                                    completionClosure(json as AnyObject?, response.data!, statusCode, false)
                                }
                                    
                                catch {
                                    if let apiRes = response.response {
                                        apiLogModel.responseJson = String(describing: apiRes)
                                    }
                                    
                                    DBErrorLogServices.storeAllAPILogs(apiLogModel: apiLogModel)
                                    if let error = afError.underlyingError  {
                                        completionClosure(self.parseError(error as NSError) as AnyObject?, nil, statusCode, false)
                                    } else {
                                        completionClosure(["ErrorCode": HttpRespStatusCodes.RequestTimeOut.rawValue,
                                        StringConstants.ButtonTitles.TLT_Message: StringConstants.StatusMessages.Request_Timeout_Global] as AnyObject, nil, HttpRespStatusCodes.RequestTimeOut.rawValue, false)
                                    }
                                }
                            } else {
                                apiLogModel.responseStatus = NSNumber(value: HttpRespStatusCodes.RequestTimeOut.rawValue)
                                DBErrorLogServices.storeAllAPILogs(apiLogModel: apiLogModel)
                                completionClosure(["ErrorCode": HttpRespStatusCodes.RequestTimeOut.rawValue,
                                        StringConstants.ButtonTitles.TLT_Message: StringConstants.StatusMessages.Request_Timeout_Global] as AnyObject, nil, HttpRespStatusCodes.RequestTimeOut.rawValue, false)
                            }
                            
                            break
                    }
                }
        }
    }
    
    func fetchDataRAW(_ requestType:HTTPMethod, serviceURL: String, params: [String : AnyObject]?, completionClosure:@escaping (_ jsonRes: AnyObject?, _ statusCode: Int, _ isSucceeded:Bool) ->()) {
        
        let parameters = params as! [String: String]
        var request = URLRequest(url: URL(string: serviceURL)!)
        for header in self.getHeaders()! {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpMethod = requestType.rawValue
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        print("Headers: \(request.allHTTPHeaderFields!)")
        
        let session = URLSession.shared
        session.reset {
            print("Reset done")
            
            let task = session.dataTask(with: request) { data, response, error in
                guard let dataN = data,                            // is there data
                    let responseN = response as? HTTPURLResponse,  // is there HTTP response
                    (200 ..< 300) ~= responseN.statusCode,         // is statusCode 2XX
                    error == nil else {                           // was there no error, otherwise ...
                        if let responseN = response as? HTTPURLResponse {
                            print(responseN)
                            print("Wifi: \(Utility.getWiFiAddress() ?? "Cellular"),\nTask Request: \(String(describing: response!.url)) \n Original: \(request.url!)" )
                            
                            DispatchQueue.main.async {
                                completionClosure(nil, responseN.statusCode, false)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completionClosure(nil, 0, false)
                            }
                        }
                        return
                }
                
                let responseObject = (try? JSONSerialization.jsonObject(with: dataN)) as? [String: Any]
                completionClosure(responseObject as AnyObject?, responseN.statusCode, true)
            }
            task.resume()
        }
    }
    
    func downloadImage(forURL url: String, complitionHandler:@escaping(Bool, UIImage?) ->()){
        //https://clearthread.davacoinc.com/documents/Collection/CustomerId_11/TemplateId_16048/InstanceId_193807/AnswerId_6148016/eVbgRMaWu1-tyE_itvlm0g2.jpg
        
        AF.request(url, method: .get).response{ response in
            switch response.result {
                 case .success(let responseData):
                    complitionHandler(true, UIImage(data: responseData!))
                      

                 case .failure(let error):
                    print("++++++ ERROR download photo: ", error)
                    complitionHandler(false, nil)
            }
        }
    }
    
    
    func fetchDataDepricatedMethod(_ requestType:HTTPMethod, serviceURL: String, params: [String : AnyObject]?, completionClosure:@escaping (_ jsonRes: AnyObject?, _ statusCode: Int, _ isSucceeded:Bool) ->()) {
        
        let parameters = params as! [String: String]
        var request = URLRequest(url: URL(string: serviceURL)!)
        for header in self.getHeaders()! {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpMethod = requestType.rawValue
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        print("Headers: \(request.allHTTPHeaderFields!)")
        
        do {
            // Perform the request
            let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            
            // Convert the data to JSON
            let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            
            if let json = jsonSerialized {
                print(json)
                completionClosure(json as AnyObject?, 200, true)
            }
        } catch {
            completionClosure(nil, 0, false)
        }
    }
    
    func parseError(_ error:NSError?) -> [String : AnyObject]? {
        if error != nil {
            let errorDic = error!.userInfo as NSDictionary
            if let message = errorDic.object(forKey: "NSLocalizedDescription") {
                let resultDic = ["ErrorCode": "100", StringConstants.ButtonTitles.TLT_Message: message as! String]
                return resultDic as [String : AnyObject]?
            }
        }
        return nil
    }
    
    func getHeaders() -> [String: String]? {
        let headers = [
            Constants.RequestHeaders.Accept_Type : Constants.DataSendRecType,
            Constants.RequestHeaders.Content_Type : Constants.DataSendRecType,
            Constants.RequestHeaders.SDKVersion : String(describing: UIDevice.current.systemVersion),
            Constants.RequestHeaders.AppVersion : "2.0.0.0",
            Constants.RequestHeaders.DeviceID : (UIDevice.current.identifierForVendor?.uuidString)!,
            Constants.RequestHeaders.Manufacturer : Constants.RequestHeaders.DeviceManufacturer,
            Constants.RequestHeaders.DeviceModel : Device.current.description,
            Constants.RequestHeaders.Product : "Apple",
            Constants.RequestHeaders.CTClient: Constants.RequestHeaders.kClientType,
            Constants.RequestHeaders.Authorization: Constants.Keys.ClearthreadBackdoorLoginKey
        ]
        
        return headers;
    }
}
