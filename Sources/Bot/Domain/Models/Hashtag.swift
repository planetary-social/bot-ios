//
//  Hashtag.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

/// This is not a direct SSB model, but is rather a view model that contains a
/// a name from the Bot and the view database.
/// Checkout Bot+Hashtag to see how a hashtag is created from String name
/// and returned as a Hashtag model.
public struct Hashtag: Codable {

    // name is raw unadorned characters after #
    public let name: String
    public let count: Int64
    public let timestamp: Float64 // received time

    // string is # prefixed name
    public var string: String {
        return "#\(self.name)"
    }

    public static func named(_ name: String) -> Hashtag {
        return Hashtag(name: name.withoutHashPrefix)
    }

    public init(name: String) {
        self.name = name
        self.count = 0
        self.timestamp = 0
    }

    public init(name: String, count: Int64) {
        self.name = name
        self.count = count
        self.timestamp = 0
    }

    public init(name: String, count: Int64, timestamp: Float64) {
        self.name = name
        self.count = count
        self.timestamp = timestamp
    }

    public init(name: String, timestamp: Float64) {
        self.name = name
        self.count = 0
        self.timestamp = timestamp
    }

    public init(from decoder: Decoder) throws {
        self.name = try decoder.singleValueContainer().decode(String.self)
        self.count = 0
        self.timestamp = 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.name)
    }

    public func timeAgo() -> String {
        var relativeDate = ""
        if #available(iOS 13.0, *) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full

            let date = Date(timeIntervalSince1970: TimeInterval(self.timestamp) / 1000)
            relativeDate = formatter.localizedString(for: date, relativeTo: Date())

        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM yyyy HH:mm:ss"

            let date = Date(timeIntervalSince1970: TimeInterval(self.timestamp) / 1000)
            relativeDate = formatter.string(from: date)
        }
        return relativeDate
    }

}

extension Hashtag: Equatable {

    public static func == (lhs: Hashtag, rhs: Hashtag) -> Bool {
        return lhs.name == rhs.name
    }

}

public typealias Hashtags = [Hashtag]

public extension Hashtags {

    func names() -> [String] {
        return self.map { $0.name }
    }
}

public extension Mentions {
    func asHashtags() -> [Hashtag] {
        return self.filter {
            return $0.link.hasPrefix("#")
        }.map {
            return Hashtag(name: String($0.link.dropFirst()))
        }
    }
}

