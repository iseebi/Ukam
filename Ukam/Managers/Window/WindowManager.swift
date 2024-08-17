//
//  WindowManager.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Cocoa
import ScreenCaptureKit

class WindowManager {
    func enumerateVisibles() -> [CGWindow] {
        return enumerate().filter { $0.isVisible }
    }
    
    func enumerate() -> [CGWindow] {
        //find all the windows (CGWindows)
        let options = CGWindowListOption(arrayLiteral: CGWindowListOption.optionOnScreenOnly)
        guard let results = CGWindowListCopyWindowInfo(options, CGWindowID(0)),
              let windowList = results as NSArray? as? [[String: AnyObject]]
        else { return [] }
        
        return windowList.map { CGWindow(rawData: $0) }
    }
    
    func activate(_ window: CGWindow){
        activateWindowApp(window)
        windowAXUIElementContext(window) { element in
            AXUIElementSetAttributeValue(element, kAXFocusedAttribute as CFString, kCFBooleanTrue)
            AXUIElementPerformAction(element, kAXRaiseAction as CFString)
        }
    }
    
    func moveWindowIfNeeded(_ window: CGWindow) {
        guard let screen = NSScreen.main else { return }
        guard !NSIntersectsRect(window.bounds, screen.visibleFrame) else { return }
        var newRect = NSRect(origin: screen.visibleFrame.origin, size: window.bounds.size)
        if ( screen.visibleFrame.width < window.bounds.width) {
            newRect.size.width = screen.visibleFrame.width
        }
        if ( screen.visibleFrame.height < window.bounds.height) {
            newRect.size.height = screen.visibleFrame.height
        }
        
        // 上下左右中央にする
        newRect.origin.x += (screen.visibleFrame.width - newRect.width) / 2
        newRect.origin.y += (screen.visibleFrame.height - newRect.height) / 2
        
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
    
    private func activateWindowApp(_ window: CGWindow) {
        guard let pid = window.ownerPID,
              let runningApp = NSRunningApplication(processIdentifier: pid_t(pid))
        else { return }
        runningApp.activate(options: [.activateAllWindows])
    }
}

private func aspectFitSize(originalSize: CGSize, drawableSize: CGSize) -> CGSize {
    let originalAspectRatio = originalSize.width / originalSize.height
    let drawableAspectRatio = drawableSize.width / drawableSize.height
    
    var scaledSize: CGSize
    
    if originalAspectRatio > drawableAspectRatio {
        // Width is the limiting factor
        scaledSize = CGSize(width: drawableSize.width, height: drawableSize.width / originalAspectRatio)
    } else {
        // Height is the limiting factor
        scaledSize = CGSize(width: drawableSize.height * originalAspectRatio, height: drawableSize.height)
    }
    
    return scaledSize
}
