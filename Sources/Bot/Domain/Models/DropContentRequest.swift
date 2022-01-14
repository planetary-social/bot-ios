//
//  DropContentRequest.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public class DropContentRequest: ContentCodable {

    public let type: ContentType
    public let sequence: UInt           // the sequence number on the authors feed
    public let hash: String             // the has of the message, as a confirmation

    public init(sequence: UInt, hash: String) {
        self.type = .dropContentRequest
        self.sequence = sequence
        self.hash = hash
    }

    enum CodingKeys: String, CodingKey {
        case type
        case sequence
        case hash
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try values.decode(ContentType.self, forKey: .type)
        self.sequence = try values.decode(UInt.self, forKey: .sequence)
        self.hash = try values.decode(String.self, forKey: .hash)
    }
}
