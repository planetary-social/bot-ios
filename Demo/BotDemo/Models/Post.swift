//
//  Post.swift
//  BotDemo
//
//  Created by Martin Dutra on 30/12/21.
//

import Foundation
import Bot

struct Post: Hashable, Codable, Identifiable {

    var id: String
    var author: String
    var content: String

    init(id: String, author: String, content: String) {
        self.id = id
        self.author = author
        self.content = content
    }

    init(keyValue: KeyValue) {
        guard keyValue.value.content.isPost else {
            fatalError("Only Posts are allowed here")
        }
        self.id = keyValue.key
        self.author = keyValue.value.author
        self.content = keyValue.value.content.post?.text ?? ""
    }

}
