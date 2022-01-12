//
//  PaginatedKeyValueDataProxy.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public protocol PaginatedKeyValueDataProxy {
    // the total number of messages in the view
    // TODO: needs to be invalidated by insertLoop (maybe through notification center?)
    var count: Int { get }

    // late get's called with the KeyValue if prefetch didn't finish in time
    func keyValueBy(index: Int, late: @escaping (Int, KeyValue) -> Void) -> KeyValue?

    // TODO: i'm unable to make the above late: optional
    func keyValueBy(index: Int) -> KeyValue?

    // notify the proxy to fetch more messages (up to and including index)
    func prefetchUpTo(index: Int) -> Void
}
