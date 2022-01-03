//
//  Image.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

struct Image: Codable {

    let height: Int?

    /// Blob identifier
    let link: String
    
    let size: Int?
    let type: String?    // mime type enum?
    let width: Int?

    var identifier: String {
        return self.link
    }
}

extension Image {

    init(link: String) {
        self.height = nil
        self.link = link
        self.size = nil
        self.type = nil
        self.width = nil
    }

    init?(link: String?) {
        guard let link = link else { return nil }
        self.init(link: link)
    }
}
