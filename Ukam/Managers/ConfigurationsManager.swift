//
//  ConfigurationsManager.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/18.
//

import Cocoa
import ServiceManagement

class ConfigurationsManager {
    private(set) var launchAtLogin: Bool
    
    init() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
    
    func setLaunchAtLogin(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
