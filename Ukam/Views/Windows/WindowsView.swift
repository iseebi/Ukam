//
//  WindowsView.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import SwiftUI

protocol WindowsViewDelegate {
    func didSelectWindow(_ window: UkamWindowLike)
}

struct WindowsView: View {
    @StateObject fileprivate var dataSource: WindowsViewDataSource
    @State private var position: Int?
    
    var delegate: WindowsViewDelegate?
    
    init(dataSource: WindowsViewDataSource = WindowsViewDataSource()) {
        _dataSource = StateObject(wrappedValue: dataSource)
    }
    
    var body: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(dataSource.items, id: \.self) { item in
                    WindowItemView(item: item).onTapGesture {
                        delegate?.didSelectWindow(item.window)
                    }
                }
            }
            .frame(minWidth: LayoutConstants.windowsFrameWidth)
            .padding(LayoutConstants.padding)
        }
        .scrollPosition(id: $position)
    }
    
    func moveToTop() {
        position = 0
    }
}

#Preview {
    let ds = WindowsViewDataSource()
    ds.refresh([
        WindowMock(id: 1, name: "Window 1"),
        WindowMock(id: 2, name: "Window 2"),
        WindowMock(id: 3, name: "Window 3"),
        WindowMock(id: 4, name: "Window 4"),
        WindowMock(id: 5, name: "Window 5"),
        WindowMock(id: 6, name: "Window 6"),
        WindowMock(id: 7, name: "Window 7"),
        WindowMock(id: 8, name: "Window 8"),
        WindowMock(id: 9, name: "Window 9"),
        WindowMock(id: 10, name: "Window 10"),
        WindowMock(id: 11, name: "Window 11"),
        WindowMock(id: 12, name: "Window 12"),
        WindowMock(id: 13, name: "Window 13"),
        WindowMock(id: 14, name: "Window 14"),
        WindowMock(id: 15, name: "Window 15"),
        WindowMock(id: 16, name: "Window 16"),
        WindowMock(id: 17, name: "Window 17"),
        WindowMock(id: 18, name: "Window 18"),
        WindowMock(id: 19, name: "Window 19"),
        WindowMock(id: 20, name: "Window 20"),
    ])
    return WindowsView(dataSource: ds)
}

struct WindowMock: UkamWindowLike {
    var id: UInt32
    var skyLightID: UInt32
    var ownerPID: Int
    var name: String
    var ownerName: String
    var isVisible: Bool
    var isOnScreen: Bool
    var bounds: NSRect
    
    init(id: UInt32, name: String) {
        self.id = id
        self.skyLightID = id
        self.ownerPID = 0
        self.name = name
        self.ownerName = "Owner"
        self.isVisible = true
        self.isOnScreen = true
        self.bounds = NSRect(x: 0, y: 0, width: 100, height: 100)
    }
}
