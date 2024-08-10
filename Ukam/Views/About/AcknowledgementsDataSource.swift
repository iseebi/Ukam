//
//  AcknowledgementsDataSource.swift
//  Ukam
//
//  Created by Nobuhiro Ito on 2024/08/10.
//

import Foundation

struct Acknowledgement: Decodable {
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case body = "FooterText"
    }
    
    let title: String
    let body: String
}

protocol AcknowledgementsDataSource {
    var acknowledgements: [Acknowledgement] { get }
}

struct BundleAcknowledgementsDataSource: AcknowledgementsDataSource {
    struct AcknowledgementsContainer: Decodable {
        enum CodingKeys: String, CodingKey {
            case acknowledgements = "PreferenceSpecifiers"
        }
        
        let acknowledgements: [Acknowledgement]
    }
    
    let acknowledgements: [Acknowledgement]
    
    init() {
        if let path = Bundle.main.path(forResource: "com.mono0926.LicensePlist.Output/Acknowledgements", ofType: "plist"),
           let data = FileManager.default.contents(atPath: path),
           let acknowledgements = try? PropertyListDecoder().decode(AcknowledgementsContainer.self, from: data) {
            self.acknowledgements = acknowledgements.acknowledgements
        } else {
            self.acknowledgements = []
        }
        
    }
}
