//
//  About.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

/// It's important to note that the About model is not specifically
/// referring to human profiles.  Instead if is metadata about a specific
/// Identifier.  A good example is the hashtag feature.  A Tag model is
/// published to generate a Identifier, but without a name.  So, an About
/// is published referencing the tag identifier and supplying a name.
public struct About {

    public let about: String
    public let description: String?
    public let image: Image?
    public let name: String?
    public let shortcode: String?
    public let type: ContentType
    public let publicWebHosting: Bool?

    init() {
        self.init(about: String.null)
    }

    init(about: String) {
        self.type = .about
        self.about = about
        self.description = nil
        self.image = nil
        self.name = nil
        self.shortcode = nil
        self.publicWebHosting = nil
    }

    init(about: String, name: String) {
        self.type = .about
        self.about = about
        self.description = nil
        self.image = nil
        self.name = name
        self.shortcode = nil
        self.publicWebHosting = nil
    }

    init(about: String, descr: String) {
        self.type = .about
        self.about = about
        self.description = descr
        self.name = nil
        self.image = nil
        self.shortcode = nil
        self.publicWebHosting = nil
    }

    init(about: String, publicWebHosting: Bool) {
        self.type = .about
        self.about = about
        self.description = nil
        self.name = nil
        self.image = nil
        self.shortcode = nil
        self.publicWebHosting = publicWebHosting
    }

    init(about: String, image: String) {
        self.type = .about
        self.about = about
        self.description = nil
        self.image = Image(link: image)
        self.name = nil
        self.shortcode = nil
        self.publicWebHosting = nil
    }

    init(about: String, name: String?, description: String?, imageLink: String?, publicWebHosting: Bool? = nil) {
        self.type = .about
        self.about = about
        self.description = description
        self.image = Image(link: imageLink)
        self.name = name
        self.shortcode = nil
        self.publicWebHosting = publicWebHosting
    }

    init(identity: String, name: String?, description: String?, image: Image?, publicWebHosting: Bool?) {
        self.type = .about
        self.about = identity
        self.description = description
        self.image = image
        self.name = name
        self.shortcode = nil
        self.publicWebHosting = publicWebHosting
    }

    func mutatedCopy(identity: String? = nil,
                     name: String? = nil,
                     description: String? = nil,
                     image: Image? = nil,
                     publicWebHosting: Bool? = nil) -> About
    {
        return About(identity: identity ?? self.identity,
                     name: name ?? self.name,
                     description: description ?? self.description,
                     image: image ?? self.image,
                     publicWebHosting: publicWebHosting ?? self.publicWebHosting)
    }
}

extension About: ContentCodable {

    enum CodingKeys: String, CodingKey {
        case about
        case description
        case image
        case name
        case shortcode
        case type
        case publicWebHosting
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        description = try? values.decode(String.self, forKey: .description)
        about = try values.decode(String.self, forKey: .about)
        image = About.decodeImage(from: values)
        name = try? values.decode(String.self, forKey: .name)
        shortcode = try? values.decode(String.self, forKey: .shortcode)
        type = try values.decode(ContentType.self, forKey: .type)
        publicWebHosting = try? values.decode(Bool.self, forKey: .publicWebHosting)
    }

    private static func decodeImage(from values: KeyedDecodingContainer<About.CodingKeys>) -> Image? {
        if let identifier = try? values.decode(String.self, forKey: .image) {
            return Image(link: identifier)
        } else {
            return try? values.decode(Image.self, forKey: .image)
        }
    }

}

extension About {

    var identity: String {
        return self.about
    }

    var nameOrIdentity: String {
        return self.name?.trimmedForSingleLine ?? self.identity
    }

    // TODO this is not performant, need to cache md results
    var attributedDescription: NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: NSAttributedString())
    }

    var mention: Mention {
        let mention = Mention(link: self.identity, name: self.nameOrIdentity)
        return mention
    }

    func contains(_ string: String) -> Bool {
        if let name = self.name, name.localizedCaseInsensitiveContains(string) { return true }
        if let name = self.name?.withoutSpaces, name.localizedCaseInsensitiveContains(string) { return true }
        if let code = self.shortcode, code.localizedCaseInsensitiveContains(string) { return true }
        return false
    }
}

extension About: Comparable {

    public static func < (lhs: About, rhs: About) -> Bool {
        if let lhs = lhs.name, let rhs = rhs.name { return lhs.compare(rhs, options: .caseInsensitive) == .orderedAscending }
        if lhs.name == nil, rhs.name == nil {
            return lhs.identity < rhs.identity
        }
        return rhs.name == nil
    }

    public static func == (lhs: About, rhs: About) -> Bool {
        if let lhs = lhs.name, let rhs = rhs.name { return lhs.compare(rhs) == .orderedSame }
        return lhs.identity == rhs.identity
    }
}

extension About: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identity)
    }
    
}
