//
//  WindowsViewDataSource.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import Foundation

class WindowsViewDataSource: ObservableObject {
    @Published private(set) var items: [AnyWindowLike]
    
    init() {
        items = []
    }
    
    func refresh(_ newItems: [any WindowLike]) {
        items = newItems.map { AnyWindowLike(base: $0) }
    }
}
