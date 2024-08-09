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
                Text(R.string.localizable.app_name()).font(.title)
            } .padding(EdgeInsets(top: 0, leading: 0, bottom: LayoutConstants.padding, trailing: 0))
            VStack(alignment: .leading, spacing: LayoutConstants.padding * 2) {
                VStack(alignment: .leading) {
                    Text(R.string.localizable.permissions_view_request_permission_title()).font(.title2)
                    Text(R.string.localizable.permissions_view_request_permission_description())
                }
                
                VStack(alignment: .leading) {
                    Text(R.string.localizable.permissions_view_screen_recording_title()).font(.headline)
                    Text(R.string.localizable.permissions_view_screen_recording_description())
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(R.string.localizable.permissions_view_request_access_button()) {
                        self.screenCaptureButtonAction?()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(R.string.localizable.permissions_view_accessibility_title()).font(.headline)
                    Text(R.string.localizable.permissions_view_accessibility_description())
                        .font(.body)
                    Button(R.string.localizable.permissions_view_request_access_button()) {
                        self.accessibilityButtonAction?()
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: LayoutConstants.permissionViewWidth)
        .padding(LayoutConstants.padding * 2)
    }
}

#Preview {
    PermissionsView()
}
