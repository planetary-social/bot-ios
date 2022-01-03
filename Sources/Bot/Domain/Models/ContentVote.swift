//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

struct ContentVote: ContentCodable {

    enum CodingKeys: String, CodingKey {
        case branch
        case root
        case recps
        case vote
        case type
    }

    let type: ContentType
    let vote: Vote

    // TODO: share recps in content?
    let recps: [RecipientElement]?

    // TODO: share tangeling with Post
    let branch: [String]?
    let root: String?

    // parse new msgs
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(ContentType.self, forKey: .type)
        vote = try values.decode(Vote.self, forKey: .vote)

        root = try? values.decode(String.self, forKey: .root)
        branch = ContentVote.decodeBranch(from: values)

        recps = try? values.decode([RecipientElement].self, forKey: .recps)
    }

    private static func decodeBranch(from values: KeyedDecodingContainer<ContentVote.CodingKeys>) -> [String]? {
        if let branch = try? values.decode(String.self, forKey: .branch) {
            return [branch]
        } else {
            return try? values.decode([String].self, forKey: .branch)
        }
    }

    // create/publish
    init(link: String, value: Int) {
        self.type = .vote

        let exp: String
        if value == 1 {
            exp = "❤️"
        } else {
            exp = "💔"
        }
        self.vote = Vote(link: link, value: value, expression: exp)

        self.root = nil
        self.branch = nil

        // TODO: constructor for PMs (should maybe also live in Content.init
        self.recps = nil
    }

    init(link: String, value: Int, root: String, branches: [String]) {
        self.type = .vote

        let exp: String
        if value == 1 {
            exp = "❤️"
        } else {
            exp = "💔"
        }
        self.vote = Vote(link: link, value: value, expression: exp)

        self.root = root
        self.branch = branches

        // TODO: constructor for PMs (should maybe also live in Content.init
        self.recps = nil
    }


    init(value: Int, root: String) {
        self.type = .vote

        let exp: String
        if value == 1 {
            exp = "❤️"
        } else {
            exp = "💔"
        }
        self.vote = Vote(link: String.null, value: value, expression: exp)
        //self.link = String.null

        self.root = root
        self.branch = nil

        // TODO: constructor for PMs (should maybe also live in Content.init
        self.recps = nil
    }

}
