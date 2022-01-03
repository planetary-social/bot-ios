//
//  Blob.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

struct Blob: Codable {

    let identifier: String
    let name: String?

    struct Metadata: Codable {
        struct Dimensions: Codable {
            let width: Int
            let height: Int
        }
        let averageColorRGB: Int?
        let dimensions: Dimensions?
        let mimeType: String?
        let numberOfBytes: Int?
    }
    let metadata: Metadata?

    init(identifier: String, name: String? = nil, metadata: Metadata? = nil) {
        self.identifier = identifier
        self.name = name
        self.metadata = metadata
    }
}

typealias Blobs = [Blob]

extension Blob {
    func asMention() -> Mention {
        return Mention(link: self.identifier, name: self.name, metadata: self.metadata)
    }
}

extension Blobs {
    func asMentions() -> Mentions {
        return self.map {
            return $0.asMention()
        }
    }
}
