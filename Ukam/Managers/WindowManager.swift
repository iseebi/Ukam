//
//  WindowManager.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Cocoa
import ScreenCaptureKit

func lookupWindowID(_ uiElement: AXUIElement) -> CGWindowID? {
    var windowId: CGWindowID = 0
    if _AXUIElementGetWindow(uiElement, &windowId) != .success {
        return nil
    }
    return windowId
}

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
            guard let axWindowID = lookupWindowID(element),
                  let modelWindowID = window.number,
                  axWindowID == modelWindowID
            else { continue }
            
            handler(element)
            break
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
    
    func captureImage(_ window: Window, requestedSize: CGSize, contentHandler: @escaping (NSImage?) -> Void) {
        let completion = { (image: NSImage?) in
            DispatchQueue.main.async {
                contentHandler(image)
            }
        }
        
        DispatchQueue.global().async {
            SCShareableContent.getWithCompletionHandler { shareableContent, error in
                if let error = error {
                    print(error)
                    completion(nil)
                    return
                }
                
                guard let shareableContent = shareableContent,
                      let windowID = window.number,
                      let captureWindow = shareableContent.windows.first(where: { $0.windowID == windowID }),
                      let display = shareableContent.displays.first(where: { $0.frame.contains(captureWindow.frame) })
                else {
                    completion(nil)
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
                        completion(nil)
                        return
                    }
                    
                    guard let image = image else {
                        completion(nil)
                        return
                    }
                    
                    completion(NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height)))
                }
            }
        }
    }
    
    private func activateWindowApp(_ window: Window) {
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
