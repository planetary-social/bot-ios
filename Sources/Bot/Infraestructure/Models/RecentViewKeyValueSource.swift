//
//  File.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

class RecentViewKeyValueSource: KeyValueSource {
    let view: ViewDatabase

    let total: Int

    // home or explore view?
    private let onlyFollowed: Bool

    init(with vdb: ViewDatabase, onlyFollowed: Bool = true) throws {
        self.view = vdb
        self.total = try vdb.statsForRootPosts(onlyFollowed: onlyFollowed)
        self.onlyFollowed = onlyFollowed
    }

    func retreive(limit: Int, offset: Int) throws -> [KeyValue] {
        return try self.view.recentPosts(limit: limit, offset: offset, onlyFollowed: self.onlyFollowed)
    }

    static func top(with vdb: ViewDatabase, onlyFollowed: Bool = true) throws -> MessageIdentifier? {
        return try vdb.recentIdentifiers(limit: 1, onlyFollowed: onlyFollowed).first
    }
}
