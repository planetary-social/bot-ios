//
//  Content.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct Content {

    /// Used to when decoding has encountered a JSON blob
    /// that does not contain a 'type' field.
    public static let invalidJSON = "Invalid JSON"

    // required type
    // if decoding fails type = .unsupported
    // and exception will have string from decode failure
    public let type: ContentType
    public let typeString: String
    public let typeException: String?

    // supported content
    public var contentException: String?
    public var about: About?
    public var address: Address?
    public var pub: Pub?
    public var contact: Contact?
    public var dropContentRequest: DropContentRequest?
    public var post: Post?
    public var vote: ContentVote?

    public init(from post: Post) {
        self.type = .post
        self.typeString = "post"
        self.typeException = nil
        self.post = post
    }

    public init(from vote: ContentVote) {
        self.type = .vote
        self.typeString = "vote"
        self.typeException = nil
        self.vote = vote
    }

    public init(from contact: Contact) {
        self.type = .contact
        self.typeString = "contact"
        self.typeException = nil
        self.contact = contact
    }

    /// Computed property indicating if the inner model failed
    /// decoding despite having a valid `ContentType`.  This is
    /// useful in identifying content that we should be able to
    /// display, but cannot for some reason.
    public var isValid: Bool {
        return self.type != .unsupported && self.contentException == nil
    }

    /// Various validators useful to assert an expected type.
    public var isAbout: Bool   { return self.isValid && self.type == .about && self.about != nil }
    public var isAddress: Bool { return self.isValid && self.type == .address && self.address != nil }
    public var isContact: Bool { return self.isValid && self.type == .contact && self.contact != nil }
    public var isPost: Bool    { return self.isValid && self.type == .post && self.post != nil }
    public var isVote: Bool    { return self.isValid && self.type == .vote && self.vote != nil }

}

extension Content: Codable {

    /// This key can only be used for decoding.
    /// Content should never be encoded directly.
    enum CodingKeys: String, CodingKey {
        case type
    }

    /// The first responsibility of this decoder is to ensure that
    /// it never throws even when the supplied data does not contain
    /// a `type` field.  `typeString` and `typeException` will be
    /// populated with detail regarding why decoding failed.  `type`
    /// will then be set to `.unsupported` and upper layers can choose
    /// how to handle this.  If `type` is successfully decoded, then
    /// decoder will be used to supply one of the supported types.
    public init(from decoder: Decoder) throws {

        var values: KeyedDecodingContainer<Content.CodingKeys>
        var typeString = Content.invalidJSON
        var type = ContentType.unsupported
        var exception: String? = nil

        // the decoder order is important here
        // values must be done first, and non-JSON will throw it
        // typeString is next so we can capture the decode intent
        // type is last and will throw if not a known ContentType
        do {
            values = try decoder.container(keyedBy: CodingKeys.self)
            typeString = try values.decode(String.self, forKey: .type)
            type = try values.decode(ContentType.self, forKey: .type)
        } catch DecodingError.typeMismatch(_, let ctx) {
            // most likely a private message (opaque string without a type field)
            self.type = .unknown
            self.typeString = "xxx-encrypted"
            self.typeException = ctx.debugDescription
            return
        } catch DecodingError.dataCorrupted(let ctx){
            exception = ctx.debugDescription
        } catch {
            // most likely unhandled type (like git-update or npm-packages)
            exception = error.localizedDescription
        }
        // let properties can only be initialized once
        // so the results of all the trys, which can fail
        // at different spots are copied in a single pass
        self.type = type
        self.typeException = exception
        self.typeString = typeString
        self.decodeByContentType(decoder)
    }

    /// Uses the decoder to create instances based on `self.type`.
    /// If the type is `.unsupported`, then no work is done.
    /// If the type is valid, but the decoding fails, `contentException`
    /// will contain the reason why.  Ideally `type` would be updated
    /// to `.unsupported`, however that field is not mutable.
    private mutating func decodeByContentType(_ decoder: Decoder) {
        do {
            switch self.type {
                case .about: self.about = try About(from: decoder)
                case .address: self.address = try Address(from: decoder)
                case .contact: self.contact = try Contact(from: decoder)
                case .dropContentRequest: self.dropContentRequest = try DropContentRequest(from: decoder)
                case .pub: self.pub = try Pub(from: decoder)
                case .post: self.post = try Post(from: decoder)
                case .vote: self.vote = try ContentVote(from: decoder)
                default: ()
            }
        } catch {
            self.contentException = error.localizedDescription
        }
    }

}
