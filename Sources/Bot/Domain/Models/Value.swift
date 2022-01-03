//
//  Value.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

struct Value: Codable {
    let author: String
    let content: Content
    let hash: String
    let previous: String?   // TODO? only if seq == 1 but external sbot handles this currently
    let sequence: Int
    let signature: String
    let timestamp: Float64 // claimed user time
}
