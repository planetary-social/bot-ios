//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public class Post: ContentCodable {

    enum CodingKeys: String, CodingKey {
        case branch
        case mentions
        case recps
        case reply
        case root
        case text
        case type
    }

    public let branch: [Identifier]?
    public let mentions: [Mention]?
    public let recps: [RecipientElement]?
    public let reply: [Identifier: Identifier]?
    public let root: MessageIdentifier?
    public let text: String
    public let type: ContentType

    // MARK: Calculated temporal unserialized properties

    internal var _attributedString: NSMutableAttributedString?

    // MARK: Lifecycle

    /// Intended to be used when publishing a new Post from a UI.
    /// Check out NewPostViewController for an example.
    public init(attributedText: NSAttributedString, root: String? = nil, branches: [String]? = nil) {
        // required
        self.branch = branches
        self.root = root
        self.text = attributedText.string
        self.type = .post

        var mentionsFromHashtags = attributedText.string.hashtags().map {
            tag in
            return Mention(link: tag.string)
        }

        mentionsFromHashtags.append(contentsOf: attributedText.mentions())
        self.mentions = mentionsFromHashtags

        // unused
        self.recps = nil
        self.reply = nil
    }

    /// Intended to be used to create models in the view database or unit tests.
    public init(blobs: Blobs? = nil,
         branches: [String]? = nil,
         hashtags: Hashtags? = nil,
         mentions: [Mention]? = nil,
         root: String? = nil,
         text: String)
    {
        // required
        self.branch = branches
        self.root = root
        self.text = text
        self.type = .post

        var m: Mentions = []
        if let mentions = mentions {
            m = mentions
        }
        if let blobs = blobs {
            for b in blobs {
                m.append(b.asMention())
            }
        }
        if let tags = hashtags {
            for h in tags {
                m.append(Mention(link: h.string))
            }
        }
        // keep it optional
        self.mentions = m.count > 0 ? m : nil

        // unused
        self.recps = nil
        self.reply = nil
    }

    /// Intended to be used to decode a model from JSON.
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        branch = Post.decodeBranch(from: values)
        mentions = try? values.decode([Mention].self, forKey: .mentions)
        recps = try? values.decode([RecipientElement].self, forKey: .recps)
        reply = try? values.decode([String: String].self, forKey: .reply)
        root = try? values.decode(String.self, forKey: .root)
        text = try values.decode(String.self, forKey: .text)
        type = try values.decode(ContentType.self, forKey: .type)
    }

    private static func decodeBranch(from values: KeyedDecodingContainer<Post.CodingKeys>) -> [String]? {
        if let branch = try? values.decode(String.self, forKey: .branch) {
            return [branch]
        } else {
            return try? values.decode([String].self, forKey: .branch)
        }
    }

}


public extension Post {

    var isRoot: Bool {
        return self.root == nil
    }

    func doesMention(_ identity: String?) -> Bool {
        guard let identity = identity else { return false }
        return self.mentions?.contains(where: { $0.identity == identity }) ?? false
    }
}

/* TODO: there is a cleaner solution here
 tried this to get [Identity] but got the following error so I added getRecipientIdentities as a workaround
 Constrained extension must be declared on the unspecialized generic type 'Array' with constraints specified by a 'where' clause


 typealias Recipients = [RecipientElement]

 extension Recipients {
     func recipients() -> [Identity] {
        return getRecipientIdentities(self)
     }
 }
*/
// TODO: This is used by ViewDatabase only
func getRecipientIdentities(recps: [RecipientElement]) -> [String] {
    var identities: [String] = []
    for r in recps {
        switch r {
        case .string(let str):
            identities.append(str)
        case .namedKey(let nk):
            identities.append(nk.link)
        }
    }
    return identities
}
