//
//  SLSWindow.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/17.
//

import Foundation

enum SLSSpaceType {
    case desktop
    case fullscreenApp
}

protocol SLSMonitorLike: Identifiable, Hashable {
    associatedtype Space: SLSSpaceLike
    
    var id: String { get }
    var currentSpace: Space { get }
    var spaces: [Space] { get }
}

struct SLSMonitor: SLSMonitorLike, CustomStringConvertible {
    let rawValue: NSDictionary
    
    var id: String {
        return rawValue.object(forKey: "Display Identifier") as? String ?? ""
    }
    
    var currentSpace: SLSSpace {
        return SLSSpace(rawValue: rawValue.object(forKey: "Current Space") as? NSDictionary ?? [:])
    }
    
    var spaces: [SLSSpace] {
        let spaces = rawValue.object(forKey: "Spaces") as? [NSDictionary] ?? []
        return spaces.map { SLSSpace(rawValue: $0) }
    }
    
    var description: String {
        return "<Monitor: \(id), currentSpace: \(currentSpace), spaces.count: \(spaces.count)>"
    }
}
    
protocol SLSSpaceLike: Identifiable, Hashable {
    var id: UInt64 { get }
    var type: SLSSpaceType { get }
    var uuid: String { get }
    var wsid: Int? { get }
    var fullscreenWindowID: UInt32? { get }
}

struct SLSSpace: SLSSpaceLike, CustomStringConvertible {
    let rawValue: NSDictionary
    
    var managedSpaceID: UInt32 { rawValue.object(forKey: "ManagedSpaceID") as? UInt32 ?? 0 }
    var id: UInt64 { rawValue.object(forKey: "id64") as? UInt64 ?? 0 }
    var typeValue: Int { rawValue.object(forKey: "type") as? Int ?? -1 }
    var uuid: String { rawValue.object(forKey: "uuid") as? String ?? "" }
    var wsid: Int? { rawValue.object(forKey: "wsid") as? Int }
    
    var type: SLSSpaceType {
        switch typeValue {
        case 4:
            return .fullscreenApp
        default:
            return .desktop
        }
    }
    
    var fullscreenWindowID: UInt32? {
        guard type == .fullscreenApp else { return nil }
        
        return rawValue.object(forKey: "fs_wid") as? UInt32
    }
    
    var description: String {
        let wsid = self.wsid != nil ? "\(self.wsid!)" : ""
        return "<Space: \(id), managedSpaceID: \(managedSpaceID), type: \(type), uuid: \(uuid), wsid: \(wsid)>"
    }
}


protocol SLSWindowLike {
    var id: UInt32 { get }
    var parentID: UInt32 { get }
    var tags: UInt64 { get }
    var attributes: UInt64 { get }
}

struct SLSWindow: SLSWindowLike {
    var id: UInt32
    var parentID: UInt32
    var tags: UInt64
    var attributes: UInt64
}
