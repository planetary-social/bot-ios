//
//  Statistics.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

public struct Statistics {

    public var lastSyncDate: Date?
    public var lastSyncDuration: TimeInterval = 0

    public var lastRefreshDate: Date?
    public var lastRefreshDuration: TimeInterval = 0

    public var repo = RepoStatistics()
    public var peer = PeerStatistics()
    public var db = DatabaseStatistics()
}

public struct RepoStatistics {

    /// Path to the repo
    public let path: String

    /// Number of feeds in the repo
    public let feedCount: Int

    /// Total number of messages
    public let messageCount: Int

    /// Number of messages published by the user
    public let numberOfPublishedMessages: Int

    /// Last message in the repo
    public let lastHash: String

    init(path: String? = nil,
         feedCount: Int = -1,
         messageCount: Int = 0,
         numberOfPublishedMessages: Int = 0,
         lastHash: String = "") {
        self.path = path ?? "unknown"
        self.feedCount = feedCount
        self.messageCount = messageCount
        self.numberOfPublishedMessages = numberOfPublishedMessages
        self.lastHash = lastHash
    }
}

public struct DatabaseStatistics {

    public let lastReceivedMessage: Int

    init(lastReceivedMessage: Int = -2) {
        self.lastReceivedMessage = lastReceivedMessage
    }

}

public struct PeerStatistics {

    public let count: Int
    public let connectionCount: UInt

    // name, identifier
    public let identities: [(String, String)]

    // IP, Identifier
    public let currentOpen: [(String, String)]

    init(count: Int? = 0,
         connectionCount: UInt? = 0,
         identities: [(String, String)]? = [],
         open: [(String, String)]? = [])
    {
        self.count = count ?? 0
        self.connectionCount = connectionCount ?? 0
        self.identities = identities ?? []
        self.currentOpen = open ?? []
    }
}
