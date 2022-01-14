//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public enum Sigil: String, Codable {
    case blob = "&"
    case feed = "@"     // identity is also @
    case message = "%"  // link is also %
    case unsupported
}
