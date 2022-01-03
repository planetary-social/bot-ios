//
//  DropContentRequest.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

class DropContentRequest: ContentCodable {
    let type: ContentType

    let sequence: UInt           // the sequence number on the authors feed
    let hash: String             // the has of the message, as a confirmation

    init(sequence: UInt, hash: String) {
        self.type = .dropContentRequest
        self.sequence = sequence
        self.hash = hash
    }

    enum CodingKeys: String, CodingKey {
        case type
        case sequence
        case hash
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try values.decode(ContentType.self, forKey: .type)
        self.sequence = try values.decode(UInt.self, forKey: .sequence)
        self.hash = try values.decode(String.self, forKey: .hash)
    }
}
