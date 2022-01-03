//
//  Address.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

struct Address: Codable {
    let type: ContentType
    let address: String
    let availability: Double
}
