//
//  WindowManager.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Cocoa

func appAXUIElementContext(_ window: Window, handler: (AXUIElement) -> Void) {
    guard let pid = window.ownerPID else { return }
    let appElement = AXUIElementCreateApplication(pid_t(pid))
    handler(appElement)
}

func windowAXUIElementContext(_ window: Window, handler: (AXUIElement) -> Void) {
    appAXUIElementContext(window) { appElement in
        var arrayRef: CFArray?
        AXUIElementCopyAttributeValues(appElement, kAXWindowsAttribute as CFString, 0, 9999, &arrayRef)
        guard let elements = arrayRef as? [AXUIElement] else { return }
        for element in elements {
            var windowId: CGWindowID = 0
            _AXUIElementGetWindow(element, &windowId)
            if windowId == window.number ?? 0 {
                handler(element)
                break
            }
        }
    }
}

class WindowManager {
    func enumerateVisibles() -> [Window] {
        return enumerate().filter { $0.isVisible }
    }
    
    func enumerate() -> [Window] {
        //find all the windows (CGWindows)
        let options = CGWindowListOption(arrayLiteral: CGWindowListOption.optionOnScreenOnly)
        guard let results = CGWindowListCopyWindowInfo(options, CGWindowID(0)),
              let windowList = results as NSArray? as? [[String: AnyObject]]
        else { return [] }
        
        return windowList.map { Window(rawData: $0) }
    }
    
    func activate(_ window: Window){
        activateWindowApp(window)
        windowAXUIElementContext(window) { element in
            AXUIElementSetAttributeValue(element, kAXFocusedAttribute as CFString, kCFBooleanTrue)
            AXUIElementPerformAction(element, kAXRaiseAction as CFString)
        }
    }
    
    func moveWindowIfNeeded(_ window: Window) {
        guard let screen = NSScreen.main else { return }
        print(window.bounds)
        guard !NSIntersectsRect(window.bounds, screen.visibleFrame) else { return }
        var newRect = NSRect(origin: screen.visibleFrame.origin, size: window.bounds.size)
        if ( screen.visibleFrame.width < window.bounds.width) {
            newRect.size.width = screen.visibleFrame.width
        }
        if ( screen.visibleFrame.height < window.bounds.height) {
            newRect.size.height = screen.visibleFrame.height
        }
        windowAXUIElementContext(window) { element in
            if let originValue = AXValueCreate(AXValueType.cgPoint, &newRect.origin),
               let sizeValue = AXValueCreate(AXValueType.cgSize, &newRect.size) {
                AXUIElementSetAttributeValue(
                    element, kAXPositionAttribute as CFString, originValue)
                AXUIElementSetAttributeValue(
                    element, kAXSizeAttribute as CFString, sizeValue)
            }
        }
    }
    
    private func activateWindowApp(_ window: Window) {
        guard let pid = window.ownerPID,
              let runningApp = NSRunningApplication(processIdentifier: pid_t(pid))
        else { return }
        runningApp.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
    }
}
