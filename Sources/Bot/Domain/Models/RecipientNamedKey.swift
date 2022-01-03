//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

struct RecipientNamedKey: Codable {
    let link: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case name
        case link
    }
}
