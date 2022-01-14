//
//  StaticDataProxy.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public class StaticDataProxy: PaginatedKeyValueDataProxy {

    public let kvs: [KeyValue]
    public let count: Int

    public init() {
        self.kvs = []
        self.count = 0
    }

    init(with kvs: [KeyValue]) {
        self.kvs = kvs
        self.count = kvs.count
    }

    public func keyValueBy(index: Int, late: @escaping (Int, KeyValue) -> Void) -> KeyValue? {
        return self.kvs[index]
    }

    public func keyValueBy(index: Int) -> KeyValue? {
        if self.kvs.isEmpty {
            return nil
        } else {
            return self.kvs[index]
        }
    }

    public func prefetchUpTo(index: Int) {
        /* noop */
    }
}
