//
//  ConfigurationsManager.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/18.
//

import Cocoa
import ServiceManagement
import Sparkle

class ConfigurationsManager: NSObject {
    let updaterController: SPUStandardUpdaterController
    
    private(set) var launchAtLogin: Bool
    var checkForUpdatesOnLaunch: Bool {
        get {
            updaterController.updater.automaticallyChecksForUpdates
        }
        set {
            updaterController.updater.automaticallyChecksForUpdates = newValue
        }
    }
    
    override init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        launchAtLogin = SMAppService.mainApp.status == .enabled
        super.init()
    }
    
    func checkForUpdates() {
        updaterController.checkForUpdates(self)
    }
    
    func setLaunchAtLogin(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
        launchAtLogin = enabled
    }
}
