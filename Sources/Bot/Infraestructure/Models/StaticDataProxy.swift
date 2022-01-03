//
//  StaticDataProxy.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

class StaticDataProxy: PaginatedKeyValueDataProxy {
    let kvs: [KeyValue]
    let count: Int

    init() {
        self.kvs = []
        self.count = 0
    }

    init(with kvs: [KeyValue]) {
        self.kvs = kvs
        self.count = kvs.count
    }

    func keyValueBy(index: Int, late: @escaping (Int, KeyValue) -> Void) -> KeyValue? {
        return self.kvs[index]
    }

    func keyValueBy(index: Int) -> KeyValue? {
        if self.kvs.isEmpty {
            return nil
        } else {
            return self.kvs[index]
        }
    }

    func prefetchUpTo(index: Int) {
        /* noop */
    }
}
