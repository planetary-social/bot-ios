//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

/* code to handle both kinds of recpients:
 patchcore publishes this object instead of just the key as a string
 { link: @pubkey, name: somenick}


 handling from https://stackoverflow.com/a/49023027
*/
enum RecipientElement: Codable {
    case namedKey(RecipientNamedKey)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(RecipientNamedKey.self) {
            self = .namedKey(x)
            return
        }
        throw DecodingError.typeMismatch(RecipientElement.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RecipientElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .namedKey(let x):
            try container.encode(x.link)
        case .string(let x):
            try container.encode(x)
        }
    }
}
