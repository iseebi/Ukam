//
//  CGWindowOperations.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/18.
//

import Cocoa
import ScreenCaptureKit

fileprivate func lookupWindowID(_ uiElement: AXUIElement) -> CGWindowID? {
    var windowId: CGWindowID = 0
    if _AXUIElementGetWindow(uiElement, &windowId) != .success {
        return nil
    }
    return windowId
}

fileprivate func appAXUIElementContext(_ window: CGWindow, handler: (AXUIElement) -> Void) {
    guard let pid = window.ownerPID else { return }
    let appElement = AXUIElementCreateApplication(pid_t(pid))
    handler(appElement)
}

fileprivate func windowAXUIElementContext(_ window: CGWindow, handler: (AXUIElement) -> Void) {
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

class CGWindowOperations {
    func enumerateWindows() -> [CGWindow] {
        //find all the windows (CGWindows)
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements)
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
    
    func imagesForWindows(_ windows: [CGWindow], requestedSize: CGSize, contentHandler: @escaping ([NSImage?]) -> Void) {
        var results = [NSImage?](repeating: nil, count: windows.count)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.ukam.screenshot.cgimage")
        
        for (index, window) in windows.enumerated() {
            group.enter()
            self.imageForWindow(window, requestedSize: requestedSize) { image in
                queue.async {
                    results[index] = image
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            contentHandler(results)
        }
    }
    
    fileprivate func imageForWindow(_ window: CGWindow, requestedSize: CGSize, contentHandler: @escaping (NSImage?) -> Void) {
        SCShareableContent.getWithCompletionHandler { shareableContent, error in
            if let error = error {
                print(error)
                contentHandler(nil)
                return
            }
            
            guard let shareableContent = shareableContent,
                  let windowID = window.number,
                  let captureWindow = shareableContent.windows.first(where: { $0.windowID == windowID }),
                  let display = shareableContent.displays.first(where: { $0.frame.contains(captureWindow.frame) })
            else {
                contentHandler(nil)
                return
            }
            
            let filter = SCContentFilter(display: display, including: [captureWindow])
            let config = SCStreamConfiguration()
            config.sourceRect = CGRect(
                origin: CGPoint(
                    x: captureWindow.frame.origin.x - display.frame.origin.x,
                    y: captureWindow.frame.origin.y - display.frame.origin.y
                ),
                size: captureWindow.frame.size
            )
            SCScreenshotManager.captureImage(contentFilter: filter, configuration: config) { image, error in
                if let error = error {
                    print(error)
                    contentHandler(nil)
                    return
                }
                
                guard let image = image else {
                    contentHandler(nil)
                    return
                }
                
                contentHandler(NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height)))
            }
        }
    }
}
