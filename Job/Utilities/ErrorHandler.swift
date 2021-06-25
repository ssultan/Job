//
//  ErrorHandler.swift
//  Job V2
//
//  Created by Saleh Sultan on 8/8/16.
/*
 Copyright (c) 2019. Davaco, Inc. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//

import FirebaseAnalytics
import UIKit

class ErrorHandler: NSObject {
    
    static let shared = ErrorHandler()
    
    var popViewController : PopUpViewControllerSwift!
    
    private override init() {
        self.popViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopUpVC") as? PopUpViewControllerSwift
    }
    
    func handleLoginRequestBadStatusCode(_ view:UIView, statusCode: Int) {
        switch statusCode {
        case HttpRespStatusCodes.RequestHasErrorCode.rawValue :
            Analytics.logEvent(StringConstants.AppseeEventMessages.Login_Error_500, parameters: [:])
            self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Warning,
                                              withMessage:StringConstants.StatusMessages.UnknownError,
                                              withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                              animated: true, isMessage: false)
            break
        case HttpRespStatusCodes.BadRequestCode.rawValue :
            Analytics.logEvent(StringConstants.AppseeEventMessages.Login_Error_405, parameters: [:])
            self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Warning,
                                              withMessage:StringConstants.StatusMessages.BAD_REQUEST,
                                              withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                              animated: true, isMessage: false)
            break
        case HttpRespStatusCodes.NotFoundCode.rawValue :
            Analytics.logEvent(StringConstants.AppseeEventMessages.Login_Error_404, parameters: [:])
            self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Warning,
                                              withMessage:StringConstants.StatusMessages.NOT_FOUND_ERROR,
                                              withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                              animated: true, isMessage: false)
            break
        case HttpRespStatusCodes.TokenExpiredCode.rawValue:
            Analytics.logEvent(StringConstants.AppseeEventMessages.Login_Token_Expired, parameters: [:])
            self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Warning,
                                              withMessage:StringConstants.StatusMessages.kInvalidUsernameOrPassword,
                                              withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                              animated: true, isMessage: false)
            break
        default:
            Analytics.logEvent("\(StringConstants.AppseeEventMessages.Unknow_Login_Error)\(statusCode)", parameters: [:])
            self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Warning,
                                              withMessage:StringConstants.StatusMessages.UnknownError,
                                              withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                              animated: true, isMessage: false)
            break
        }
    }
    
    func handleLoginErrors(_ view:UIView, errorDic: NSDictionary, forUsername username: String) {
        if let errorCode = errorDic[Constants.ApiRequestFields.Key_ErrorCode], let msg = errorDic[Constants.ApiRequestFields.Key_Message] {
            if let errorCodeInt = errorCode as? NSInteger, let errorMsg = msg as? String {
                
                switch errorCodeInt {
                    
                // Username or password is incorrect
                case LoginRequestErrCode.LogonFailed.rawValue:
                    Analytics.logEvent(StringConstants.AppseeEventMessages.WrongUsernamePassword, parameters: [:])
                    self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Caution,
                                                      withMessage:StringConstants.StatusMessages.kInvalidUsernameOrPassword,
                                                      withCloseBtTxt: StringConstants.ButtonTitles.BTN_GOT_IT, withAcceptBt: nil,
                                                      animated: true, isMessage: false)
                    break
                    
                // Account Dead or no longer a valid user or User Terminated
                case LoginRequestErrCode.UserTerminated.rawValue:
                    Analytics.logEvent(StringConstants.AppseeEventMessages.InvalidUser, parameters: [:])
                    let isAnonymousUser = (username.lowercased().contains(Constants.Anonymous_Initial) || username.lowercased().contains(Constants.Anonymous_Initial2)) ? true : false
                    let errMsg = isAnonymousUser ? StringConstants.StatusMessages.ACCOUNT_DEAD_LOGIN_ERROR_ANONYMOUS : StringConstants.StatusMessages.ACCOUNT_DEAD_LOGIN_ERROR
                    self.popViewController.showMsgInWebView(view, withTitle: StringConstants.ButtonTitles.TLT_Caution,
                                                            withMessage:errMsg,
                                                            withHtmlFileName:nil,
                                                            withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                                            animated: true, isMessage: false)
                    break
                    
                    
                // Account Locked out
                case LoginRequestErrCode.UserLockedOut.rawValue:
                    Analytics.logEvent(StringConstants.AppseeEventMessages.AccountLocked, parameters: [:])
                    self.popViewController.showMsgInWebView(view, withTitle: StringConstants.ButtonTitles.TLT_Caution,
                                                            withMessage: StringConstants.StatusMessages.ACCOUNT_LOCKEDOUT_LOGIN_ERROR,
                                                            withHtmlFileName:nil,
                                                            withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                                            animated: true, isMessage: false)
                    break
                    
                    
                // Password Expired
                case LoginRequestErrCode.PasswordExpired.rawValue:
                    Analytics.logEvent(StringConstants.AppseeEventMessages.PasswordExpired, parameters: [:])
                    let isAnonymousUser = (username.lowercased().contains(Constants.Anonymous_Initial) || username.lowercased().contains(Constants.Anonymous_Initial2)) ? true : false
                     let errMsg = isAnonymousUser ? StringConstants.StatusMessages.PASSWORD_EXPIRED_LOGIN_ERROR_ANONYMOUS : StringConstants.StatusMessages.PASSWORD_EXPIRED_LOGIN_ERROR
                    self.popViewController.showMsgInWebView(view, withTitle: StringConstants.ButtonTitles.TLT_Caution,
                                                            withMessage:errMsg,
                                                            withHtmlFileName:nil,
                                                            withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                                            animated: true, isMessage: false)
                    break
                    
                // User Duplicate // Manifest error
                case LoginRequestErrCode.UserDuplicate.rawValue:
                    //Appsee.addEvent(StringConstants.AppseeEventMessages.ManifestError, withProperties: ["UserName": AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId, "ErrorCode": errorCodeInt, StringConstants.ButtonTitles.TLT_Message: errorMsg])
                    self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Caution,
                                                      withMessage:errorMsg,
                                                      withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                                      animated: true, isMessage: false)
                    break
                    
                // Manifest error
                case LoginRequestErrCode.GenManifestError.rawValue:
                    Analytics.logEvent(StringConstants.AppseeEventMessages.ManifestError, parameters: ["UserName": AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId, "ErrorCode": errorCodeInt, StringConstants.ButtonTitles.TLT_Message: errorMsg])
                    self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Caution,
                                                      withMessage:errorMsg,
                                                      withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                                      animated: true, isMessage: false)
                    break
                    
                    
                // Default message
                default:
                    Analytics.logEvent(StringConstants.AppseeEventMessages.UnknownError, parameters: ["UserName": AppInfo.sharedInstance.username ?? AppInfo.sharedInstance.deviceId, "ErrorCode": errorCodeInt, StringConstants.ButtonTitles.TLT_Message: errorMsg])
                    self.popViewController.showInView(view, withTitle: StringConstants.ButtonTitles.TLT_Caution,
                                                      withMessage:StringConstants.StatusMessages.kDefaultLoginError,
                                                      withCloseBtTxt: StringConstants.ButtonTitles.BTN_Close, withAcceptBt: nil,
                                                      animated: true, isMessage: false)
                    break
                }
            }
        }
    }
}
