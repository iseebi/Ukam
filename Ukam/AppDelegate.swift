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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        windowManager = WindowManager()
        menuManager = MenuManager(windowManager: windowManager)
        CGRequestScreenCaptureAccess()
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        AXIsProcessTrustedWithOptions(options)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

