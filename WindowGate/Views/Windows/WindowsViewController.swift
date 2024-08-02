//
//  WindowsViewController.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import Cocoa
import SwiftUI

protocol WindowsViewControllerDelegate: AnyObject {
    func windowsViewController(_ viewController: WindowsViewController, didSelectWindow window: WindowLike)
}

class WindowsViewController: NSViewController {
    var delegate: WindowsViewControllerDelegate?
    
    private let windowManager: WindowManager
    
    private var dataSoruce = WindowsViewDataSource()
    private var containeredView: WindowsView!
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containeredView = WindowsView(dataSource: self.dataSoruce)
        containeredView.delegate = self
        
        let hostingView = NSHostingView(rootView: containeredView)
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
        dataSoruce.refresh(windowManager.enumerateVisibles())
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        print("viewDidDisappear")
    }
}

extension WindowsViewController: WindowsViewDelegate {
    func didSelectWindow(_ window: WindowLike) {
        print("Selected window: \(window)")
        delegate?.windowsViewController(self, didSelectWindow: window);
    }
}
