//
//  WindowManager+AXUIElement.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/17.
//

import Foundation

func lookupWindowID(_ uiElement: AXUIElement) -> CGWindowID? {
    var windowId: CGWindowID = 0
    if _AXUIElementGetWindow(uiElement, &windowId) != .success {
        return nil
    }
    return windowId
}

func appAXUIElementContext(_ window: CGWindow, handler: (AXUIElement) -> Void) {
    guard let pid = window.ownerPID else { return }
    let appElement = AXUIElementCreateApplication(pid_t(pid))
    handler(appElement)
}

func windowAXUIElementContext(_ window: CGWindow, handler: (AXUIElement) -> Void) {
    appAXUIElementContext(window) { appElement in
        var arrayRef: CFArray?
        guard AXUIElementCopyAttributeValues(appElement, kAXWindowsAttribute as CFString, 0, 9999, &arrayRef) == .success,
              let elements = arrayRef as? [AXUIElement]
        else { return }
        for element in elements {
            guard let axWindowID = lookupWindowID(element),
                  let modelWindowID = window.number,
                  axWindowID == modelWindowID
            else { continue }
            
            handler(element)
            break
        }
    }
}
