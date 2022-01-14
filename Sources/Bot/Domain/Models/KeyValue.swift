//
//  KeyValue.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct KeyValue {

    public let key: Identifier

    public let value: Value

    // Received time
    public let timestamp: Float64

    // optional, only needed for copy from gobot to viewdb
    // TODO: find a way to stuff this in metadata? i think this requries a custom decoder
    public let receivedSeq: Int64?
    public let hashedKey: String?

    public init(key: String, value: Value, timestamp: Float64) {
        self.key = key
        self.value = value
        self.timestamp = timestamp
        self.receivedSeq = -1
        self.hashedKey = nil
    }

    public init(key: String, value: Value, timestamp: Float64, receivedSeq: Int64, hashedKey: String) {
        self.key = key
        self.value = value
        self.timestamp = timestamp
        self.receivedSeq = receivedSeq
        self.hashedKey = hashedKey
    }

    // MARK: Metadata

    public struct Metadata {

        public struct Author {
            public var about: About?
        }

        public var author = Author()

        public struct Replies {
            public var count: Int = 0
            public var abouts: [About] = []
        }

        public var replies = Replies()

        public var isPrivate: Bool = false
    }

    public var metadata = Metadata()
}

extension KeyValue: Codable {

    enum CodingKeys: String, CodingKey {
        case key
        case value
        case timestamp
        case receivedSeq = "ReceiveLogSeq"
        case hashedKey = "HashedKey"
    }

}

extension KeyValue: Equatable {

    public static func == (lhs: KeyValue, rhs: KeyValue) -> Bool {
        return lhs.key == rhs.key
    }
}

extension KeyValue: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
    }
    
}

public extension KeyValue {

    // Convenience var to return the embedded content's type
    var contentType: ContentType {
        return self.value.content.type
    }

    // Convenience var for received time as Date
    var receivedDate: Date {
        return Date(timeIntervalSince1970: self.timestamp)
    }

    var receivedDateString: String {
        return DateFormatter.localizedString(from: self.receivedDate,
                                             dateStyle: .short,
                                             timeStyle: .short)
    }

    // Convenience var for user time as Date
    var userDate: Date {
        let ud = Date(timeIntervalSince1970: self.value.timestamp/1000)
        let now = Date(timeIntervalSinceNow: 0)
        if ud > now {
            return Date(timeIntervalSince1970: self.timestamp/1000)
        }
        return ud
    }

    var userDateString: String {
        return DateFormatter.localizedString(from: self.userDate,
                                             dateStyle: .short,
                                             timeStyle: .short)
    }
}
