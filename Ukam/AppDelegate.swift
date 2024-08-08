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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        permissionsManager = PermissionsManager()
        windowManager = WindowManager()
        menuManager = MenuManager(windowManager: windowManager)
        
        if !permissionsManager.isPermitted {
            let window = PermissionsViewController.createWindow(permissionsManager: permissionsManager)
            window.makeKeyAndOrderFront(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

