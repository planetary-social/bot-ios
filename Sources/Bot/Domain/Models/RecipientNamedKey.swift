//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct RecipientNamedKey {

    public let link: Identity
    public let name: String

}

extension RecipientNamedKey: Codable {

    enum CodingKeys: String, CodingKey {
        case name
        case link
    }

}
