//
//  PostBuilder.swift
//  
//
//  Created by Martin Dutra on 28/12/21.
//

import Foundation

class PostBuilder {

    func build(keyValue: KeyValue) -> BBot.Post {
        return BBot.Post(identifier: keyValue.key,
                         author: keyValue.value.author,
                         date: Date(timeIntervalSince1970: keyValue.timestamp),
                         content: keyValue.value.content.post?.text ?? "")
    }

}
