//
//  WindowManager.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Cocoa
import ScreenCaptureKit

class WindowManager {
    let cgWindowOperations = CGWindowOperations()
    let skyLightOperations = SkyLightOperations()
    
    func enumerateVisibles() -> [UkamWindow] {
        let monitors = skyLightOperations.enumerateMonitors()
        let slsWindows = monitors.flatMap { monitor in
            monitor.spaces.filter{
                // フルスクリーンアプリには対応していない
                $0.type != .fullscreenApp
            }.flatMap { space in
                skyLightOperations.enumerateWindows(in: space).map { window in
                    (window, space, monitor, monitor.currentSpace.managedSpaceID == space.managedSpaceID)
                }
            }
        }
        
        let allCGWindows = cgWindowOperations.enumerateWindows()
        let menuBarWindow = allCGWindows.first { $0.name == "Menubar" }
        let cgWindows = allCGWindows.filter {
            // メニューバーよりも上にあるウィンドウは対象外(StatusItemなど)
            if let memuBarLayer = menuBarWindow?.windowLayer, $0.windowLayer >= memuBarLayer { return false }
            // 表示対象になっているウィンドウのみが対象
            if !$0.isVisible { return false }
            return true
        }
        let cgWindowDict = Dictionary(uniqueKeysWithValues: cgWindows.map { ($0.id, $0) })
        
        return slsWindows.compactMap { slsWindow, space, monitor, isCurrentSpace in
            guard let cgWindow = cgWindowDict[Int(slsWindow.id)] else { return nil }
            return UkamWindow(skyLightWindow: slsWindow, cgWindow: cgWindow, monitorID: monitor.id, spaceID: space.id)
        }
    }
    
    func activate(_ window: UkamWindow){
        guard  let slsWindow = window.skyLightWindow as? SLSWindow,
               let cgWindow = window.cgWindow as? CGWindow
        else { return }
        
        // 他のデスクトップにいるウィンドウの場合は、現在のディスプレイスペースに移動させる
        if !cgWindow.isOnScreen {
            skyLightOperations.moveWindowToCurrentSpace(slsWindow)
        }
        
        // 指定されたウィンドウが現在のスクリーンの範囲内にいない場合は、移動させる
        cgWindowOperations.moveWindowIfNeeded(cgWindow)
        
        // ウィンドウをアクティブにする
        cgWindowOperations.activate(cgWindow)
    }
    
    func imagesForWindows(_ windows: [UkamWindow], requestedSize: CGSize, completionHandler: @escaping (([(UkamWindowLike.ID, NSImage)]) -> Void)) {
        #if USE_SCREEN_CAPTURE_KIT
        let op = self.cgWindowOperations
        let paramWindows = windows.compactMap({ $0.cgWindow as? CGWindow })
        #else
        let op = self.skyLightOperations
        let paramWindows = windows.compactMap({ $0.skyLightWindow as? SLSWindow })
        #endif
        
        DispatchQueue.global().async {
            op.imagesForWindows(paramWindows, requestedSize: requestedSize) { images in
                let results = paramWindows.enumerated().compactMap { (index, window) -> (UkamWindowLike.ID, NSImage)? in
                    guard let image = images[index] else { return nil }
                    return (window.id, image)
                }
                DispatchQueue.main.async {
                    completionHandler(results)
                }
            }
        }
    }
}
