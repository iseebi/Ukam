//
//  AboutView.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/10.
//

import SwiftUI

struct AboutView: View {
    let versionString = { () -> String in
        let marketingVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        let buildNumber = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""
        return "\(marketingVersion) (\(buildNumber))"
    }()
    
    @State private var showingSheet = false
    
    var body: some View {
        VStack(spacing: LayoutConstants.padding * 2) {
            VStack(alignment: .center) {
                Image(.imageIcon)
                Text(R.string.localizable.app_name()).font(.title)
                Text(versionString).font(.subheadline)
            Text(R.string.localizable.about_view_copyright())
                .font(.subheadline)
            }
            VStack(alignment: .trailing) {
                Button(R.string.localizable.about_view_acknowledgements()) {
                    self.showingSheet.toggle()
                }
                .sheet(isPresented: $showingSheet) {
                    AcknowledgementsView(dataSource: BundleAcknowledgementsDataSource())
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: LayoutConstants.aboutViewWidth)
        .padding(LayoutConstants.padding * 2)
    }
}

#Preview {
    AboutView()
}
