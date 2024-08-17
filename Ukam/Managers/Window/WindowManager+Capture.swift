//
//  WindowManager+Capture.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/17.
//

import Cocoa
import ScreenCaptureKit

extension WindowManager {
    func captureImage(_ window: CGWindow, requestedSize: CGSize, contentHandler: @escaping (NSImage?) -> Void) {
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
}
