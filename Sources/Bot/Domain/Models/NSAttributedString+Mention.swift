//
//  NSAttributedString+Mention.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation
import UIKit

public extension NSAttributedString {

    func mentions() -> Mentions {
        let results = self.mentionsWithRanges()
        let mentions = results.map { $0.0 }
        return mentions
    }

    func mentionsWithRanges() -> [(Mention, NSRange)] {
        var results: [(Mention, NSRange)] = []
        let range = NSRange(location: 0, length: self.length)
        self.enumerateAttribute(NSAttributedString.Key.link,
                                in: range,
                                options: [])
        {
            attribute, range, _ in
            if let identity = attribute as? String {
                let name = self.attributedSubstring(from: range).string
                let mention = Mention(link: identity, name: name)
                results += [(mention, range)]
            } else if let url = attribute as? URL {
                if url.scheme == "applewebdata" {
                    let name = self.attributedSubstring(from: range).string
                    let mention = Mention(link: String(url.path.dropFirst()), name: name)
                    results += [(mention, range)]
                } else {
                    let name = self.attributedSubstring(from: range).string
                    let mention = Mention(link: url.absoluteString, name: name)
                    results += [(mention, range)]
                }
            }
        }
        return results
    }

    func hasMention(before range: NSRange) -> Bool {
        let results = self.mentionsWithRanges()
        for (_, mentionRange) in results {
            if mentionRange.upperBound == range.lowerBound { return true }
        }
        return false
    }
}

public extension NSMutableAttributedString {

    convenience init(from mention: Mention) {
        let name = mention.name ?? ""
        self.init(string: name)
        let range = NSRange(location: 0, length: name.count)
        self.addAttribute(NSAttributedString.Key.link, value: mention.link, range: range)
    }

    func replaceMentionLinkAttributesWithMarkdown() {
        for (mention, range) in self.mentionsWithRanges().reversed() {
            self.replaceCharacters(in: range, with: mention.markdown)
        }
    }

    func replaceMentionLinkAttributesWithNamesOnly() {
        for (mention, range) in self.mentionsWithRanges().reversed() {
            let name = mention.name ?? ""
            self.replaceCharacters(in: range, with: name.withoutAtPrefix)
        }
    }
}

public extension Mention {

    var attributedString: NSMutableAttributedString {
        return NSMutableAttributedString(from: self)
    }
}
