//
//  AcknowledgementsView.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/10.
//

import SwiftUI

struct AcknowledgementsItem: View {
    var acknowledgement: Acknowledgement
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(acknowledgement.title).font(.headline)
            Text(acknowledgement.body).font(.body)
        }
    }
}

struct AcknowledgementsView: View {
    var dataSource: AcknowledgementsDataSource
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(spacing: LayoutConstants.padding * 2) {
                    ForEach(dataSource.acknowledgements, id: \.title) { acknowledgement in
                        AcknowledgementsItem(acknowledgement: acknowledgement)
                    }
                }
            }
            VStack(alignment: .trailing) {
                Button(R.string.localizable.acknowledgements_view_close()) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: LayoutConstants.acknowledgementsViewWidth, height: LayoutConstants.acknowledgementsViewHeight)
        .padding(LayoutConstants.padding * 2)
    }
}

struct PreviewAcknowledgementsDataSource: AcknowledgementsDataSource {
    var acknowledgements: [Acknowledgement] = [
        Acknowledgement(title: "Title", body: "Body"),
        Acknowledgement(title: "Title", body: "Body")
    ]
}

#Preview {
    AcknowledgementsView(dataSource: PreviewAcknowledgementsDataSource())
}
