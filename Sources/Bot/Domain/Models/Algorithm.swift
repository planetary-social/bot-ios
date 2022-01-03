//
//  Algorithm.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

enum Algorithm: String, Codable {

    case sha256
    case ed25519
    case ggfeed = "ggfeed-v1"
    case ggfeedmsg = "ggmsg-v1"
    case unsupported

    init() {
        self = .unsupported
    }

    init(fromRawValue: String) {
        self = Algorithm(rawValue: fromRawValue) ?? .unsupported
    }
}
