//
//  WindowsViewController.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import Cocoa
import SwiftUI

protocol WindowsViewControllerDelegate: AnyObject {
    func windowsViewController(_ viewController: WindowsViewController, didSelectWindow window: UkamWindowLike)
}

class WindowsViewController: NSViewController {
    var delegate: WindowsViewControllerDelegate?
    
    private let windowManager: WindowManager
    
    private var dataSoruce = WindowsViewDataSource()
    private var containeredView: WindowsView!
    
    private var windows: [UkamWindow] = []
    
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
    func windowsViewDataSource(_ dataSource: WindowsViewDataSource, didRequestedScreenCaptureFor windows: [UkamWindowLike], resultHandler: @escaping ([(UInt32, NSImage)]) -> Void) {
        let windows = windows.compactMap { $0 as? UkamWindow }
        let requestedSize = CGSize(width: LayoutConstants.screenshotWidth, height: LayoutConstants.screenshotHeight)
        windowManager.imagesForWindows(windows, requestedSize: requestedSize) { images in
            resultHandler(images)
        }
    }
}

extension WindowsViewController: WindowsViewDelegate {
    func didSelectWindow(_ window: UkamWindowLike) {
        guard let rawWindow = windows.first(where: { $0.id == window.id }) else { return }
        windowManager.activate(rawWindow)
        delegate?.windowsViewController(self, didSelectWindow: rawWindow);
    }
}
