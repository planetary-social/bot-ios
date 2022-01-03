//
//  Vote.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

/// Unlike other content models, the Vote model is actually
/// a child of Content as opposed to a flavor of it.  As such,
/// it requires special decoding via the ContentVote model.
struct Vote: Codable {
    let link: String
    let value: Int
    let expression: String?
}
