//
//  PermissionsManager.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/08.
//

import Foundation

extension NSNotification.Name {
    fileprivate static let accessibilityApiChanged = NSNotification.Name(rawValue: "com.apple.accessibility.api")
    static let permissionChanged = NSNotification.Name(rawValue: "net.iseteki.ukam.permissionChanged")
}

protocol PermissionItem {
    var delegate: PermissionItemDelegate? { get set }
    var isPermitted: Bool { get }
    func requestAccess()
}

protocol PermissionItemDelegate {
    func permissionItem(_ item: PermissionItem, didUpdatePermitted isPermitted: Bool)
}

class ScreenCapturePermission: PermissionItem {
    var delegate: PermissionItemDelegate?
    
    var isPermitted: Bool {
        return CGPreflightScreenCaptureAccess()
    }
    
    func requestAccess() {
        CGRequestScreenCaptureAccess()
    }
}

class AccessibilityPermission: PermissionItem {
    var delegate: PermissionItemDelegate?
    
    init() {
        let notificationCenter = DistributedNotificationCenter.default()
        notificationCenter.addObserver(self, 
                                       selector: #selector(accessibilityPermissionChanged),
                                       name: .accessibilityApiChanged,
                                       object: nil)
    }
    
    var isPermitted: Bool {
        return AXIsProcessTrusted()
    }
    
    func requestAccess() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        AXIsProcessTrustedWithOptions(options)
    }
    
    @objc private func accessibilityPermissionChanged() {
        delegate?.permissionItem(self, didUpdatePermitted: isPermitted)
    }
}

class PermissionsManager {
    let screenCapture = ScreenCapturePermission()
    let accessibility = AccessibilityPermission()
    
    var isPermitted: Bool {
        return screenCapture.isPermitted && accessibility.isPermitted
    }
    
    init() {
        screenCapture.delegate = self
        accessibility.delegate = self
    }
}

extension PermissionsManager: PermissionItemDelegate {
    func permissionItem(_ item: PermissionItem, didUpdatePermitted isPermitted: Bool) {
        NotificationCenter.default.post(name: .permissionChanged, object: nil)
    }
}
