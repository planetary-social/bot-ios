//
//  KeyValueSource.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

protocol KeyValueSource {
    var total: Int { get }
    func retreive(limit: Int, offset: Int) throws -> [KeyValue]
}
