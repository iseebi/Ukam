//
//  WindowsViewDataSource.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import Cocoa

protocol WindowsViewDataSourceDelegate {
    func windowsViewDataSource(_ dataSource: WindowsViewDataSource, didRequestedScreenCaptureFor windows: [UkamWindowLike], resultHandler: @escaping ([(UkamWindowLike.ID, NSImage)]) -> Void)
}

class WindowsViewDataSource: ObservableObject {
    class WindowItem: ObservableObject, Identifiable, Equatable, Hashable {
        fileprivate(set) var window: UkamWindowLike {
            didSet {
                name = window.name
                ownerName = window.ownerName
            }
        }
        
        var id = UUID()
        @Published var name: String
        @Published var ownerName: String
        @Published var icon: NSImage? = nil
        @Published var screenshot: NSImage? = nil
        
        init(window: UkamWindowLike) {
            self.window = window
            name = window.name
            ownerName = window.ownerName 
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
    
    func refresh(_ newWindows: [UkamWindowLike]) {
        let lastItems = items
        items = newWindows.map {[weak self] newItem in
            let item = lastItems.first(where: { $0.window.id == newItem.id }) ?? WindowItem(window: newItem)
            item.window = newItem
            
            if item.icon == nil {
                self?.icon(for: item.window.ownerPID) { image in
                    item.icon = image
                }
            }
            
            return item
        }
        updateScreenshots()
    }
    
    private func updateScreenshots() {
        let windows = self.items.map { $0.window }
        delegate?.windowsViewDataSource(self, didRequestedScreenCaptureFor: windows, resultHandler: {[weak self] images in
            guard let self = self else { return }
            let windowImagesDict = Dictionary(uniqueKeysWithValues: images)
            self.items.forEach { item in
                item.screenshot = windowImagesDict[item.window.id]
            }
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
