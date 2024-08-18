//
//  SkyLightOperations.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/18.
//

import Cocoa

class SkyLightOperations {
    func enumerateMonitors() -> [SLSMonitor] {
        let connection = SLSMainConnectionID()
        
        let spaces = SLSCopyManagedDisplaySpaces(connection)
        defer { spaces?.release() }
        
        guard let spacesArray = spaces?.takeUnretainedValue() as? NSArray else { return [] }
        
        let monitors = spacesArray.compactMap { space -> SLSMonitor? in
            guard let space = space as? NSDictionary else { return nil }
            return SLSMonitor(rawValue: space)
        }
        
        return monitors
    }
    
    func enumerateWindows(in space: any SLSSpaceLike) -> [SLSWindow] {
        let connection = SLSMainConnectionID()
        
        let includeMinimized = false
        let options: UInt32 = includeMinimized ? 0x7 : 0x2
        let spaceList: [NSNumber] = [NSNumber(value: space.id)]
        var setTags: UInt64 = 0
        var clearTags: UInt64 = 0
        let windowListRefPtr = withUnsafeMutablePointer(to: &setTags, { setTagsPtr in
            withUnsafeMutablePointer(to: &clearTags, { clearTagsPtr in
                SLSCopyWindowsWithOptionsAndTags(connection, 0, spaceList as CFArray, options, setTagsPtr, clearTagsPtr)
            })
        })
        guard let windowListRef = windowListRefPtr?.takeUnretainedValue() else { return [] }
        defer { windowListRefPtr?.release() }
        
        let queryPtr = SLSWindowQueryWindows(connection, windowListRef, Int32(CFArrayGetCount(windowListRef)))
        guard let query = queryPtr?.takeUnretainedValue() else { return [] }
        defer { queryPtr?.release() }
        
        let iterPtr = SLSWindowQueryResultCopyWindows(query)
        guard let iter = iterPtr?.takeUnretainedValue() else { return [] }
        defer { iterPtr?.release() }
        
        var result: [SLSWindow] = []
        while SLSWindowIteratorAdvance(iter) {
            let windowID = SLSWindowIteratorGetWindowID(iter)
            let tags = SLSWindowIteratorGetTags(iter)
            let attrs = SLSWindowIteratorGetAttributes(iter)
            let parentID = SLSWindowIteratorGetParentID(iter)
            result.append(SLSWindow(id: windowID, parentID: parentID, tags: tags, attributes: attrs))
        }
                                                     
        return result
    }
    
    func enumerateSpaces(for window: SLSWindow) -> [SLSSpace] {
        let connection = SLSMainConnectionID()
        let spaceListRef = SLSCopySpacesForWindows(connection, 0x7 as Int32, [NSNumber(value: window.id)] as CFArray)
        guard let spaceList = spaceListRef?.takeUnretainedValue() as? NSArray else { return [] }
        defer { spaceListRef?.release() }
        
        let spaces = spaceList.compactMap { space -> SLSSpace? in
            guard let space = space as? NSDictionary else { return nil }
            return SLSSpace(rawValue: space)
        }
        
        return spaces
    }
    
    func imagesForWindows(_ windows: [SLSWindow], requestedSize: CGSize, contentHandler: @escaping ([NSImage?]) -> Void) {
        var results = [NSImage?](repeating: nil, count: windows.count)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.ukam.screenshot.skylight")
        
        for (index, window) in windows.enumerated() {
            group.enter()
            let image = self.captureImage(for: [window])?.first ?? nil
            queue.async {
                results[index] = image
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            contentHandler(results)
        }
 
        /*
         // インターフェイス的には複数枚返ってきそうだけど、実際は1つしか返ってこない(パラメーターが良くない？)
        guard let images = captureImage(for: windows) else {
            contentHandler([NSImage?](repeating: nil, count: windows.count))
            return
        }
        
        contentHandler(images)
         */
    }
    
    private func captureImage(for windows: [SLSWindow]) -> [NSImage?]? {
        let connection = SLSMainConnectionID()
        
        var windowIDs = windows.map { $0.id }
        let arrayRef = windowIDs.withUnsafeMutableBufferPointer { ptr in
            SLSHWCaptureWindowList(connection, ptr.baseAddress, Int32(windows.count),  (1 << 11) | (1 << 8))
        }
        guard let array = arrayRef?.takeUnretainedValue() as? NSArray else { return nil }
        defer { arrayRef?.release() }
        
        return array.map({ image -> NSImage? in
            let image = image as! CGImage
            return NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        })
    }

    func moveWindow(_ window: SLSWindow, to space: SLSSpace) {
        if ProcessInfo.processInfo.isSonoma145 {
            moveWindowSonoma145(window, to: space)
        } else {
            moveWindowOlder(window, to: space)
        }
    }
    
    private func moveWindowSonoma145(_ window: SLSWindow, to space: SLSSpace) {
        let connection = SLSMainConnectionID()
        
        guard SLSSpaceSetCompatID(connection, space.id, 0x79616265) == .success else {
            return
        }
        defer { _ = SLSSpaceSetCompatID(connection, space.id, 0x0) }
        
        var id = window.id
        guard withUnsafeMutablePointer(to: &id, { idPtr -> CGError in
            return SLSSetWindowListWorkspace(connection, idPtr, 1, 0x79616265)
        }) == .success else { return }
    }
    
    private func moveWindowOlder(_ window: SLSWindow, to space: SLSSpace) {
        let connection = SLSMainConnectionID()
        SLSMoveWindowsToManagedSpace(connection, [NSNumber(value: window.id)] as CFArray, space.id)
    }
}

extension ProcessInfo {
    fileprivate var isSonoma145: Bool {
        isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 14, minorVersion: 5, patchVersion: 0))
    }
}
