//
//  KeyValueBuilder.swift
//  
//
//  Created by Martin Dutra on 28/12/21.
//

import Foundation
import Moderator

class KeyValueBuilder {

    func build(post: Moderator.Post) -> KeyValue {
        let author = post.authorNick ?? "Unknown"
        let timestamp = Double(post.perceivedTimestamp) / 1000.0
        let payload = String(data: post.payload, encoding: .utf8) ?? ""
        let attributedText = NSAttributedString(string: payload)
        let content = Post(attributedText: attributedText, root: nil, branches: nil)
        let c = Content(from: content)
        let value = Value(author: author,
                          content: c,
                          hash: "noop",
                          previous: nil,
                          sequence: 0,
                          signature: "noop",
                          timestamp: timestamp)
        if let key = post.key {
            return KeyValue(key: key.reduce("", {$0 + String(format: "%02X", $1)}),
                            value: value,
                            timestamp: timestamp)
        } else {
            return KeyValue(key: timestamp.description, value: value, timestamp: timestamp)
        }

    }
    
}
