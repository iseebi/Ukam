//
//  PermissionsView.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/09.
//

import SwiftUI

struct PermissionsView: View {
    var screenCaptureButtonAction: (() -> Void)?
    var accessibilityButtonAction: (() -> Void)?
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Image(.imageIcon)
                Text("Ukam").font(.title)
            } .padding(EdgeInsets(top: 0, leading: 0, bottom: LayoutConstants.padding, trailing: 0))
            VStack(alignment: .leading, spacing: LayoutConstants.padding * 2) {
                VStack(alignment: .leading) {
                    Text("Required Permissions").font(.title2)
                    Text("Ukam requires the following permissions to work properly.")
                }
                
                VStack(alignment: .leading) {
                    Text("Screen Recording").font(.headline)
                    Text("Ukam requires screen recording permissions to enumerate windows and create screen capture for window list.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Request Access") {
                        self.screenCaptureButtonAction?()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Accessibility").font(.headline)
                    Text("Ukam requires accessibility permissions to manipulate windows.")
                    Button("Request Access") {
                        self.accessibilityButtonAction?()
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: 480)
        .padding(LayoutConstants.padding * 2)
    }
}

#Preview {
    PermissionsView()
}
