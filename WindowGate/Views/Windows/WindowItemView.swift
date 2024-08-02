//
//  WindowItemView.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import SwiftUI

struct WindowItemView: View {
    static let defaultIcon = NSImage(systemSymbolName: "star", accessibilityDescription: nil)!
    
    @ObservedObject var item: WindowsViewDataSource.WindowItem
    @State private var isHovered = false
    
    init(item: WindowsViewDataSource.WindowItem) {
        self.item = item
    }
    
    var body: some View {
        VStack {
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    // Screenshot
                    Image(systemName: "star")
                        .resizable()
                        .frame(minHeight: LayoutConstants.screenshotHeight)
                        .background(Color.gray)
                        .cornerRadius(LayoutConstants.cornerRadius)
                    // Icon
                    Image(nsImage: item.icon ?? Self.defaultIcon)
                        .resizable()
                        .frame(width: LayoutConstants.iconSize, height: LayoutConstants.iconSize)
                        .padding(LayoutConstants.iconPosition)
                }
                Text(item.name)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .help("\(item.name) - \(item.ownerName)")
            .onHover(perform: { hovering in
                isHovered = hovering
            })
            .padding(LayoutConstants.padding)
            .background(isHovered ? Color.accentColor : Color.clear)
        }
        .cornerRadius(LayoutConstants.cornerRadius)
    }
}

#Preview {
    WindowItemView(item: WindowsViewDataSource.WindowItem(window: WindowMock(id: 1, name: "Window 1"))).padding(20)
}
