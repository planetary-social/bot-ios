//
//  KnownPub.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

public struct KnownPub {
    let AddressID: Int64

    let ForFeed: Identifier
    let Address: String // multiserver

    let InUse: Bool
    let WorkedLast: String
    let LastError: String
    let redeemed: Date?

}

extension KnownPub: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.AddressID)
    }

}
