//
//  Contact.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct Contact: ContentCodable {

    public let type: ContentType
    public let contact: String
    public let following: Bool?
    public let blocking: Bool?

    public var identity: String {
        return self.contact
    }

    public init(contact: String, following: Bool) {
        self.type = .contact
        self.contact = contact
        self.following = following
        self.blocking = false
    }

    public init(contact: String, blocking: Bool) {
        self.type = .contact
        self.contact = contact
        self.following = false
        self.blocking = blocking
    }
}

public extension Contact {

    var isFollowing: Bool {
        return self.following ?? false
    }

    var isBlocking: Bool {
        return self.blocking ?? false
    }

    var isValid: Bool {
        return self.following != nil || self.blocking != nil
    }
}
