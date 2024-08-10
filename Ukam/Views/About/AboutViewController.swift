//
//  AboutViewController.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/10.
//

import Cocoa
import SwiftUI

class AboutViewController: NSViewController {
    private var containeredView: AboutView!
    
    static func createWindow() -> NSWindow {
        let viewController = AboutViewController()
        let window = NSWindow(contentViewController: viewController)
        window.title = R.string.localizable.about_view_title()
        window.styleMask = [.titled, .closable]
        window.center()
        return window
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containeredView = AboutView()
        
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
}
