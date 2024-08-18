//
//  AppDelegate.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var menuManager: MenuManager!
    var windowManager: WindowManager!
    var permissionsManager: PermissionsManager!
    var configurationsManager: ConfigurationsManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        permissionsManager = PermissionsManager()
        windowManager = WindowManager()
        configurationsManager = ConfigurationsManager()
        menuManager = MenuManager(
            windowManager: windowManager,
            permissionsManager: permissionsManager,
            configurationsManager: configurationsManager)
        
        if !permissionsManager.isPermitted {
            permissionsManager.showPermissionsWindow()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

