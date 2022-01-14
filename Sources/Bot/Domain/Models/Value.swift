//
//  Value.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct Value {

    public let author: Identity

    public let content: Content

    public let hash: String

    public let previous: String?   // TODO? only if seq == 1 but external sbot handles this currently

    public let sequence: Int

    public let signature: String

    public let timestamp: Float64 // claimed user time

    public init(author: Identity, content: Content, hash: String, previous: String?, sequence: Int, signature: String, timestamp: Float64) {
        self.author = author
        self.content = content
        self.hash = hash
        self.previous = previous
        self.sequence = sequence
        self.signature = signature
        self.timestamp = timestamp
    }

}

extension Value: Codable { }
