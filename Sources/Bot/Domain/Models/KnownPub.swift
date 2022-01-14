//
//  KnownPub.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

public struct KnownPub {
    public let AddressID: Int64

    public let ForFeed: Identifier
    public let Address: String // multiserver

    public let InUse: Bool
    public let WorkedLast: String
    public let LastError: String
    public let redeemed: Date?

}

extension KnownPub: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.AddressID)
    }

}
