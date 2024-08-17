//
//  WindowsViewDataSource.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import Cocoa

protocol WindowsViewDataSourceDelegate {
    func windowsViewDataSource(_ dataSource: WindowsViewDataSource, didRequestedScreenCaptureFor window: CGWindowLike, resultHandler: @escaping (NSImage?) -> Void)
}

class WindowsViewDataSource: ObservableObject {
    class WindowItem: ObservableObject, Identifiable, Equatable, Hashable {
        fileprivate(set) var window: CGWindowLike {
            didSet {
                name = window.name ?? ""
                ownerName = window.ownerName ?? ""
            }
        }
        
        var id = UUID()
        @Published var name: String
        @Published var ownerName: String
        @Published var icon: NSImage? = nil
        @Published var screenshot: NSImage? = nil
        
        init(window: CGWindowLike) {
            self.window = window
            name = window.name ?? ""
            ownerName = window.ownerName ?? ""
        }
        
        static func == (lhs: WindowItem, rhs: WindowItem) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    @Published private(set) var items: [WindowItem]
    private var iconsForPID: [Int: NSImage] = [:]
    
    var delegate: WindowsViewDataSourceDelegate?
    
    init() {
        items = []
    }
    
    func refresh(_ newItems: [any CGWindowLike]) {
        let lastItems = items
        items = newItems.map {[weak self] newItem in
            let item = lastItems.first(where: { $0.window.number == newItem.number }) ?? WindowItem(window: newItem)
            item.window = newItem
            
            self?.attachImages(for: item)
            
            return item
        }
    }
    
    private func attachImages(for window: WindowItem) {
        guard let pid = window.window.ownerPID else { return }
        
        icon(for: pid) { image in
            window.icon = image
        }
        
        delegate?.windowsViewDataSource(self, didRequestedScreenCaptureFor: window.window, resultHandler: { image in
            window.screenshot = image
        })
    }
    
    func icon(for pid: Int, resultHandler: @escaping (NSImage?) -> Void) {
        if let icon = iconsForPID[pid] {
            resultHandler(icon)
        }
        
        let completion = { (icon: NSImage?) in
            DispatchQueue.main.async {
                if icon != nil {
                    self.iconsForPID[pid] = icon
                }
                resultHandler(icon)
            }
        }
        
        DispatchQueue.global().async {
            completion(NSRunningApplication(processIdentifier: pid_t(pid))?.icon)
        }
    }
}
