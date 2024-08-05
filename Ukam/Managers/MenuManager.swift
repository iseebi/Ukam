//
//  MenuManager.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Cocoa

class MenuManager: NSObject {
    let windowsViewController: WindowsViewController
    let windowManager: WindowManager
    
    let statusBarMenu: NSMenu
    let statusBarItem: NSStatusItem
    let popover: NSPopover
    
    var windows: [Window] = []

    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        self.statusBarMenu = NSMenu(title: "Status Menu")
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        windowsViewController = WindowsViewController(windowManager: windowManager)
        
        popover = NSPopover()
        popover.contentViewController = windowsViewController
        popover.behavior = .transient
        
        super.init()
        
        windowsViewController.delegate = self
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "star", accessibilityDescription: "WindowGate")
            button.target = self
            button.action = #selector(statusBarItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        statusBarMenu.autoenablesItems = true
        statusBarMenu.addItem(
            withTitle: "Exit",
            action: #selector(MenuManager.exitApp),
            keyEquivalent: "").target = self
    }

    @objc func exitApp() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func statusBarItemClicked(_ sender: NSStatusItem) {
        guard let event = NSApp.currentEvent,
              let button = statusBarItem.button else { return }
        if event.type == NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = statusBarMenu
            button.performClick(nil) // メニューを表示するためのハック
            statusBarItem.menu = nil // メニューを再度nilに戻す
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

extension MenuManager: WindowsViewControllerDelegate {
    func windowsViewController(_ viewController: WindowsViewController, didSelectWindow window: WindowLike) {
        popover.close()
    }
}