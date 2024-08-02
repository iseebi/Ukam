//
//  WindowsViewController.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import Cocoa
import SwiftUI

class WindowsViewController: NSViewController {
    private let windowManager: WindowManager
    private var hostingView: NSHostingView<WindowsView>!
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hostingView = NSHostingView(rootView: WindowsView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: hostingView.topAnchor),
            view.leadingAnchor.constraint(equalTo: hostingView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: hostingView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: hostingView.trailingAnchor),
        ])
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        print("viewWillAppear")
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        print("viewDidDisappear")
    }
}

