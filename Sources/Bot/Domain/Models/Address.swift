//
//  Address.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct Address: Codable {
    public let type: ContentType
    public let address: String
    public let availability: Double
}
