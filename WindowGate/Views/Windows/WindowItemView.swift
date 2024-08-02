//
//  WindowItemView.swift
//  WindowGate
//
//  Created by Nobuhiro Ito on 2024/08/02.
//

import SwiftUI

struct WindowItemView: View {
    let item: AnyWindowLike
    @State private var isHovered = false
    
    init(item: AnyWindowLike) {
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
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: LayoutConstants.iconSize, height: LayoutConstants.iconSize)
                        .opacity(item.alpha)
                        .padding(LayoutConstants.iconPosition)
                }
                Text(item.name ?? "(Unknown)")
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .help("\(item.name ?? "") - \(item.ownerName ?? "")")
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
    WindowItemView(item: AnyWindowLike(base: WindowMock(id: 1, name: "Window 1"))).padding(20)
}
