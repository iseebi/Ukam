//
//  WindowsViewDataSource.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import Cocoa

class WindowsViewDataSource: ObservableObject {
    class WindowItem: ObservableObject, Identifiable, Equatable, Hashable {
        let window: WindowLike
        
        var id: Int { window.number ?? 0 }
        var name: String { window.name ?? "" }
        var ownerName: String { window.ownerName ?? "" }
        @Published var icon: NSImage? = nil
        
        init(window: WindowLike) {
            self.window = window
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
    
    init() {
        items = []
    }
    
    func refresh(_ newItems: [any WindowLike]) {
        items = newItems.map {[weak self] in
            let item = WindowItem(window: $0)
            
            if let pid = $0.ownerPID {
                self?.icon(for: pid, resultHandler: { icon in
                    item.icon = icon
                })
            }
            
            return item
        }
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
