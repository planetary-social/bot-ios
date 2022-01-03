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

    init(post: BBot.Post) {
        self.id = post.identifier
        self.author = post.author
        self.content = post.content
    }

}
