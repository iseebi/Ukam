//
//  MenuManager.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Cocoa

class MenuManager: NSObject {
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
        
        popover = NSPopover()
        popover.contentViewController = WindowsViewController(windowManager: windowManager)
        popover.behavior = .transient
        
        super.init()
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "star", accessibilityDescription: "WindowGate")
            button.target = self
            button.action = #selector(statusBarItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        statusBarMenu.delegate = self
        statusBarMenu.autoenablesItems = true
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
    
    @objc func selectedItem(_ menuItem: NSMenuItem) {
        guard let window = windows.first(where: { $0.number == menuItem.tag })
        else { return }
        windowManager.moveWindowIfNeeded(window)
        windowManager.activate(window)
    }
}

extension MenuManager: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        menu.removeAllItems()
        windows = windowManager.enumerate()
        for window in windows {
            if window.isVisible {
                let item = statusBarMenu.addItem(
                    withTitle: "\(window.name ?? "") (\(window.ownerName ?? ""))",
                    action: #selector(MenuManager.selectedItem(_:)),
                    keyEquivalent: "")
                item.target = self
                item.tag = window.number ?? -1
            }
        }
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(
            withTitle: "Exit",
            action: #selector(MenuManager.exitApp),
            keyEquivalent: "").target = self
    }
}
