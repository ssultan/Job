//
//  BiometricAuthentication.swift
//  Job V2
//
//  Created by Saleh Sultan on 1/26/18.
/*
 Copyright (c) 2019. Davaco, Inc.. All Rights Reserved. Permission to use, copy, modify, and distribute this software and its documentation without fee and without a signed licensing agreement, is hereby strictly prohibited.
 
 IN NO EVENT SHALL DAVACO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF DAVACO HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 DAVACO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". DAVACO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 */
//
import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
    case passCodeID
    case biometryLockout
}

class BiometricAuthentication {
    var context: LAContext!
    
    func checkBiometricType(username: String) -> BiometricType {
        // Check if the user is able to use the policy we've selected previously
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .none:
                    return .none
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                default:
                    return .none
                }
            } else {
                return .touchID
            }
        }
        else {
            var bioType: BiometricType = .none
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {

                let semaphore = DispatchSemaphore(value: 0)
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sign In with Clearthread account '\(username)'") { (success, evaluateError) in
                    if #available(iOS 11.0, *) {
                        switch evaluateError {
                        case LAError.biometryNotAvailable?:
                            bioType = .passCodeID
                            break
                        case LAError.biometryNotEnrolled?:
                            bioType = .passCodeID
                            break
                        case LAError.biometryLockout?:
                            bioType = .biometryLockout
                            break
                        case .none:
                            bioType = .none
                            break
                        case .some(_):
                            bioType = .none
                            break
                        }
                    }
                    else {
                        switch evaluateError {
                        case LAError.touchIDNotAvailable?:
                            bioType = .passCodeID
                            break
                        case LAError.touchIDNotEnrolled?:
                            bioType = .passCodeID
                            break
                        case LAError.touchIDLockout?:
                            bioType = .biometryLockout
                            break
                        case .none:
                            bioType = .none
                            break
                        case .some(_):
                            bioType = .none
                            break
                        }
                    }
                    semaphore.signal()
                }
                if semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
                    print("Timed out.")
                }
            }
            
            return bioType
        }
    }
    
    
    func getCurrentDomainPolictyId() -> String? {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            if let domainState = context.evaluatedPolicyDomainState {
                
                let bData = domainState.base64EncodedData()
                if let decodedString = String(data: bData, encoding: .utf8) {
                    return decodedString
                }
            }
        }
        return nil
    }
    
    func resetAuthentication() {
        self.context = LAContext()
    }
    
    func authenticateUser(oldDomainStateId:String,
                          username:String,
                          bioType: BiometricType,
                          isRegister: Bool = true,
                          completion: @escaping (_ errorMsg: String?, _ isCancelled: Bool, _ authFailed: Bool, _ fallbackPass: Bool) -> Void) {
        
        if let curDomainPolicy = getCurrentDomainPolictyId() {
            if curDomainPolicy != oldDomainStateId {
                completion(StringConstants.StatusMessages.TOUCH_ID_CHANGE_DETECTION_MSG, false, false, false)
                return
            }
        }
        else {
            completion("Face ID/Touch ID is not available.", false, false, false)
            return
        }
        
        let authMessage = isRegister ? "Register biometric authentication to reduce typing for '\(username)'" : "Sign In to your Clearthread account for '\(username)'"
        let policyAuthType: LAPolicy = .deviceOwnerAuthenticationWithBiometrics // (bioType == .biometryLockout) ? .deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
        if self.context.canEvaluatePolicy(policyAuthType, error: nil) {
            self.context.evaluatePolicy(policyAuthType, localizedReason: authMessage) { (success, evaluateError) in
                if success {
                    DispatchQueue.main.async {
                        completion(nil, false, false, false)
                    }
                } else {
                    var isCancelled = false
                    var authFailed = false
                    var fallbackPass = false
                    let message = self.getAuthErrorMessage(evaluateError, &authFailed, &isCancelled, &fallbackPass, isRegistered: isRegister)
                    completion(message, isCancelled, authFailed, fallbackPass)
                }
            }
        }
    }
    
    
    fileprivate func getAuthErrorMessage(_ evaluateError: Error?, _ authFailed: inout Bool, _ isCancelled: inout Bool, _ fallbackPass: inout Bool, isRegistered: Bool) -> String {
        if #available(iOS 11.0, *) {
            switch evaluateError {
            case LAError.biometryNotAvailable?:
                return "Face ID/Touch ID is not available. Please check your settings and try again later."
            case LAError.biometryNotEnrolled?:
                return "Face ID/Touch ID is not set up."
            case LAError.biometryLockout?:
                return isRegistered ? "Face ID/Touch ID is locked. Please try next time.": "Face ID/Touch ID is locked. \nPlease use your UserId and Password for login"
            case LAError.authenticationFailed?:
                authFailed = true
                return "There was a problem verifying your identity."
            case LAError.userCancel?:
                isCancelled = true
                return "Authentication was canceled by user."
                // Fallback button was pressed and an extra login step should be implemented for iOS 8 users.
            // By the other hand, iOS 9+ users will use the pasccode verification implemented by the own system.
            case LAError.userFallback?:
                fallbackPass = true
                return "The user tapped the fallback button"
            case LAError.systemCancel?:
                isCancelled = true
                return "Authentication was canceled by system."
            case LAError.passcodeNotSet?:
                return "Passcode is not set on the device."
            case LAError.touchIDNotAvailable?:
                return "Touch ID is not available on the device. Please check your settings and try again later."
            case LAError.touchIDNotEnrolled?:
                return "Touch ID has no enrolled fingers."

            // iOS 9+ functions
            case LAError.touchIDLockout?:
                return "There were too many failed Touch ID attempts and Touch ID is now locked."
            case LAError.appCancel?:
                return "Authentication was canceled by application."
            case LAError.invalidContext?:
                return "LAContext passed to this call has been previously invalidated."
            default:
                return "Touch ID may not be configured"
            }
        }
        else {
            switch evaluateError {
            case LAError.authenticationFailed?:
                authFailed = true
                return "There was a problem verifying your identity."
            case LAError.userCancel?:
                isCancelled = true
                return "Authentication was canceled by user."
                // Fallback button was pressed and an extra login step should be implemented for iOS 8 users.
            // By the other hand, iOS 9+ users will use the pasccode verification implemented by the own system.
            case LAError.userFallback?:
                fallbackPass = true
                return "The user tapped the fallback button"
            case LAError.systemCancel?:
                isCancelled = true
                return "Authentication was canceled by system."
            case LAError.passcodeNotSet?:
                return "Passcode is not set on the device."
            case LAError.touchIDNotAvailable?:
                return "Touch ID is not available on the device."
            case LAError.touchIDNotEnrolled?:
                return "Touch ID has no enrolled fingers."
            // iOS 9+ functions
            case LAError.touchIDLockout?:
                return "There were too many failed Touch ID attempts and Touch ID is now locked."
            case LAError.appCancel?:
                return "Authentication was canceled by application."
            case LAError.invalidContext?:
                return "LAContext passed to this call has been previously invalidated."
            // MARK: IMPORTANT: There are more error states, take a look into the LAError struct
            default:
                return "Touch ID may not be configured"
            }
        }
    }
}
