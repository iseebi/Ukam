//
//  PermissionsViewController.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/09.
//

import Cocoa
import SwiftUI

class PermissionsViewController: NSViewController {
    private let permissionsManager: PermissionsManager
    
    private var containeredView: PermissionsView!
    
    static func createWindow(permissionsManager: PermissionsManager) -> NSWindow {
        let viewController = PermissionsViewController(permissionsManager: permissionsManager)
        let window = NSWindow(contentViewController: viewController)
        window.title = "Permissions"
        window.styleMask = [.titled, .closable]
        window.center()
        return window
    }
    
    init(permissionsManager: PermissionsManager) {
        self.permissionsManager = permissionsManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containeredView = PermissionsView()
        containeredView.screenCaptureButtonAction = { [weak self] in
            self?.permissionsManager.screenCapture.requestAccess()
        }
        containeredView.accessibilityButtonAction = { [weak self] in
            self?.permissionsManager.accessibility.requestAccess()
        }
        
        let hostingView = NSHostingView(rootView: containeredView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: hostingView.topAnchor),
            view.leadingAnchor.constraint(equalTo: hostingView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: hostingView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: hostingView.trailingAnchor),
            hostingView.heightAnchor.constraint(equalToConstant: hostingView.intrinsicContentSize.height)
        ])
    }
    
    private func updatePermissionStatus() {
        self.view.window?.close()
    }
}
