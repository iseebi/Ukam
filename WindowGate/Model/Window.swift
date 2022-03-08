//
//  WindowData.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 3/6/22.
//

import Foundation

struct Window: CustomStringConvertible {
    let rawData: [String: AnyObject]
    
    var name: String? {
        get {
            return rawData[kCGWindowName as String] as? String
        }
    }
    var number: Int? {
        get {
            return rawData[kCGWindowNumber as String] as? Int
        }
    }
    var ownerName: String? {
        get {
            return rawData[kCGWindowOwnerName as String] as? String
        }
    }
    var ownerPID: Int? {
        get {
            return rawData[kCGWindowOwnerPID as String] as? Int
        }
    }
    var isOnScreen: Bool {
        get {
            return rawData[kCGWindowIsOnscreen as String] as? Bool ?? false
        }
    }
    var windowLayer: Int {
        get {
            return rawData[kCGWindowLayer as String] as? Int ?? 0
        }
    }
    var bounds: NSRect {
        get {
            guard let dict = rawData[kCGWindowBounds as String] as? NSDictionary,
                  let x = dict["X"] as? NSNumber,
                  let y = dict["Y"] as? NSNumber,
                  let width = dict["Width"] as? NSNumber,
                  let height = dict["Height"] as? NSNumber
            else { return CGRect.zero }
            
            return NSRect(x: x.doubleValue, y: y.doubleValue, width: width.doubleValue, height: height.doubleValue)
        }
    }
    var description: String {
        get {
            return "Window: \"\(name ?? "nil")\" (\(number ?? -1)) Owner: \"\(ownerName ?? "nil")\" (\(ownerPID ?? -1))"
        }
    }
}
