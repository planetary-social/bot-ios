//
//  File.swift
//  
//
//  Created by Martin Dutra on 29/12/21.
//

import Foundation

public extension BBot {

    struct Post {
        public let identifier: String
        public let author: String
        public let date: Date
        public let content: String

        public init(identifier: String, author: String, date: Date, content: String) {
            self.identifier = identifier
            self.author = author
            self.date = date
            self.content = content
        }
    }
    
}
