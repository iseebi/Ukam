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
                        .frame(minHeight: 100)
                        .background(Color.gray)
                        .cornerRadius(8)
                    // Icon
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .opacity(item.alpha)
                        .padding(4)
                }
                Text(item.name ?? "(Unknown)")
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .help("\(item.name ?? "") - \(item.ownerName ?? "")")
            .onHover(perform: { hovering in
                isHovered = hovering
            })
            .padding(10)
            .background(isHovered ? Color.accentColor : Color.clear)
        }
        .cornerRadius(8)
    }
}

#Preview {
    WindowItemView(item: AnyWindowLike(base: WindowMock(id: 1, name: "Window 1"))).padding(20)
}
