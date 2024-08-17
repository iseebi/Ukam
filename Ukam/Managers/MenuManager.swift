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
    let permissionsManager: PermissionsManager
    
    let statusBarMenu = NSMenu(title: "Status Menu")
    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = windowsViewController
        popover.behavior = .transient
        return popover
    }()
    
    private var aboutWindow: NSWindow?

    init(windowManager: WindowManager, permissionsManager: PermissionsManager) {
        self.windowManager = windowManager
        self.permissionsManager = permissionsManager
        windowsViewController = WindowsViewController(windowManager: windowManager)
        
        super.init()
        
        if let button = statusBarItem.button {
            button.image = NSImage(
                systemSymbolName: "star",
                accessibilityDescription: R.string.localizable.app_name()
            )
            button.target = self
            button.action = #selector(statusBarItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        statusBarMenu.autoenablesItems = true
        statusBarMenu.addItem(
            withTitle: R.string.localizable.status_menu_about(),
            action: #selector(MenuManager.showAbout),
            keyEquivalent: "").target = self
        statusBarMenu.addItem(
            withTitle: R.string.localizable.status_menu_exit(),
            action: #selector(MenuManager.exitApp),
            keyEquivalent: "").target = self
        
        windowsViewController.delegate = self
    }
    
    @objc func showAbout() {
        let aboutWindow = self.aboutWindow ?? {
            let newWindow = AboutViewController.createWindow()
            newWindow.delegate = self
            self.aboutWindow = newWindow
            return newWindow
        }()
        aboutWindow.makeKeyAndOrderFront(nil)
    }

    @objc func exitApp() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func statusBarItemClicked(_ sender: NSStatusItem) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == NSEvent.EventType.rightMouseUp {
            showContextMenu()
        } else {
            processPrimaryAction()
        }
    }
    
    func processPrimaryAction() {
        guard let button = statusBarItem.button else { return }
        
        guard permissionsManager.isPermitted else {
            permissionsManager.showPermissionsWindow()
            return
        }
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        popover.contentViewController?.view.window?.makeKey()
    }
    
    func showContextMenu() {
        guard let button = statusBarItem.button else { return }
        
        statusBarItem.menu = statusBarMenu
        button.performClick(nil) // メニューを表示するためのハック
        statusBarItem.menu = nil // メニューを再度nilに戻す
    }
}

extension MenuManager: WindowsViewControllerDelegate {
    func windowsViewController(_ viewController: WindowsViewController, didSelectWindow window: CGWindowLike) {
        popover.close()
    }
}

extension MenuManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow
        else { return }
        
        if window == aboutWindow {
            aboutWindow = nil
        }
    }
}
