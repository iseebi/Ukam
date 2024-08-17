//
//  WindowsViewController.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import Cocoa
import SwiftUI

protocol WindowsViewControllerDelegate: AnyObject {
    func windowsViewController(_ viewController: WindowsViewController, didSelectWindow window: CGWindowLike)
}

class WindowsViewController: NSViewController {
    var delegate: WindowsViewControllerDelegate?
    
    private let windowManager: WindowManager
    
    private var dataSoruce = WindowsViewDataSource()
    private var containeredView: WindowsView!
    
    private var windows: [CGWindow] = []
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containeredView = WindowsView(dataSource: dataSoruce)
        dataSoruce.delegate = self
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
        windows = windowManager.enumerateVisibles()
        dataSoruce.refresh(windows)
        containeredView.moveToTop()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
}

extension WindowsViewController: WindowsViewDataSourceDelegate {
    func windowsViewDataSource(_ dataSource: WindowsViewDataSource, didRequestedScreenCaptureFor window: CGWindowLike, resultHandler: @escaping (NSImage?) -> Void) {
        guard let rawWindow = windows.first(where: { $0.number == window.number }) else { return }
        windowManager.captureImage(rawWindow, requestedSize: CGSize(width: LayoutConstants.screenshotWidth, height: LayoutConstants.screenshotHeight)) { image in
            resultHandler(image)
        }
    }
}

extension WindowsViewController: WindowsViewDelegate {
    func didSelectWindow(_ window: CGWindowLike) {
        guard let rawWindow = windows.first(where: { $0.number == window.number }) else { return }
        windowManager.moveWindowIfNeeded(rawWindow)
        windowManager.activate(rawWindow)
        delegate?.windowsViewController(self, didSelectWindow: rawWindow);
    }
}
