//
//  Image.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct Image: Codable {
    
    public let height: Int?

    /// Blob identifier
    public let link: String
    
    public let size: Int?
    public let type: String?    // mime type enum?
    public let width: Int?

    public init(height: Int?, link: String, size: Int?, type: String?, width: Int?) {
        self.height = height
        self.link = link
        self.size = size
        self.type = type
        self.width = width
    }

    public var identifier: String {
        return self.link
    }
}

public extension Image {

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
