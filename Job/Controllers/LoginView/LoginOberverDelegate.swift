//
//  LoginOberverDelegate.swift
//  Job V2
//
//  Created by Saleh Sultan on 5/24/19.
//  Copyright © 2019 Clearthread. All rights reserved.
//

import Foundation

@objc protocol LoginOberverDelegate {
    var templateDownloaded:Bool { get set }
    var locationDownloaded:Bool { get set }
    
    func versionUpdateRequired(manifestModel: ManifestMapping)
    func loginSuccess(isOfflineLogin: Bool)
    func startDownloadingTemplates(_ jobDLList:NSMutableArray, _ projectIdList:NSMutableArray)
    func loginFailureWithError(_ errorJson: NSDictionary?, reqStatusCode: Int)
    func noTemplateAssignedError()
    
    func increaseProgressbar()
    func verifyEULAAcceptedForUser(_ userId: String, continueBlock: @escaping () -> ())
    func eulaPanelViewControllerAcceptedEULA()
    func eulaPanelViewControllerDeclinedEULA()
    func showOlderOSWarning(continueBlock: @escaping () -> ())
    
    func registerBioAuth()
}
