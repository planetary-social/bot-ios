//
//  FeedKeyValueSource.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

class FeedKeyValueSource: KeyValueSource {
    let view: ViewDatabase
    let feed: FeedIdentifier

    let total: Int

    init?(with vdb: ViewDatabase, feed: FeedIdentifier) throws {
        self.view = vdb
        //we should find a better way of handling errors than intentionally crashing.
        if feed.isValidIdentifier {
            self.feed = feed

            self.total = try self.view.stats(for: self.feed)
        }
        else {
            self.feed = feed
            self.total = 0
            print("invalid feed handle: \(feed)")
            //assertionFailure("invalid feed handle: \(feed)")
        }
    }

    func retreive(limit: Int, offset: Int) throws -> [KeyValue] {
        // TODO: timing dependant test
        /// This is a bit annoying.. The new test test136_paginate_quickly only tests the functionality
        /// if the retreival process takes a long time, we need to find a better way to simulate that.
//        usleep(500_000)
//        print("WARNING: simulate slow query...")
        return try self.view.feed(for: self.feed, limit: limit, offset: offset)
    }
}
