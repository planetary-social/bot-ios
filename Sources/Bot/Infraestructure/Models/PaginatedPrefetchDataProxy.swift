//
//  PaginatedPrefetchDataProxy.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation
import Logger

typealias PrefetchCompletion = (Int, KeyValue) -> Void

class PaginatedPrefetchDataProxy: PaginatedKeyValueDataProxy {
    private let backgroundQueue = DispatchQueue(label: "planetary.view.prefetches") // simple, serial queue

    // store _late_ completions for when background finishes
    private let inflightSema = DispatchSemaphore(value: 1)
    private var inflight: [Int: [PrefetchCompletion]] = [:]

    // total number of messages that could be viewed
    let count: Int

    private var source: KeyValueSource
    private var msgs: [KeyValue] = []

    init(with src: KeyValueSource) throws {
        self.source = src
        self.count = self.source.total
        self.msgs = try self.source.retreive(limit: 2, offset: 0)
        self.lastPrefetch = self.msgs.count
    }

    func keyValueBy(index: Int) -> KeyValue? {
        if index >= self.count { return nil }
        guard index < self.msgs.count else { return nil }
        return self.msgs[index]
    }

    // we don't plan to spoort growing the backing list beyond it's initialisation
    func keyValueBy(index: Int, late: @escaping PrefetchCompletion) -> KeyValue? {
        if index >= self.count { fatalError("FeedDataProxy #\(index) out-of-bounds") }
        if index > self.msgs.count-1 {
            self.inflightSema.wait()
            var forIdx = self.inflight[index] ?? []
            forIdx.append(late)
            self.inflight[index] = forIdx // ?? needed?
            self.inflightSema.signal()
            return nil
        }
        return self.msgs[index]
    }

    // TODO: need to track the last range we fired a prefetch for
    // so that we can execute the next one for the correct window
    // if the user manages to trigger one while it is in flight
    // otherwise we get duplicated posts in the view

    private var lastPrefetch: Int

    func prefetchUpTo(index: Int) {
        // TODO: i think this might race without an extra lock...?
        guard index < self.count && index >= 0 else { fatalError("FeedDataProxy prefetch #\(index) out-of-bounds") }
        guard index > self.msgs.count-1 else { return }

        self.backgroundQueue.asyncDeduped(target: self, after: 0.125) { [weak self] in
            guard let proxy = self else { return }

            // how many messages do we need?
            // +1 because we want fetch up to that index, not message count
            var diff = 1+index - proxy.lastPrefetch
            if diff < 10 { // don't just do a little work
                diff = 25 // do a little extra
            }
            guard diff > 0 else { return }

            print("pre-fetching \(diff) messages current:\(proxy.lastPrefetch)")
            guard let moreMessages = try? proxy.source.retreive(limit: diff, offset: proxy.lastPrefetch) else {
                Logger.shared.unexpected(.botError, "failed to prefetch messages")
                return
            }
            // track the window so the next prefetch starts from where this ends
            proxy.lastPrefetch += diff

            // add new messages
            proxy.inflightSema.wait()
            proxy.msgs.append(contentsOf: moreMessages)
            let newCount = proxy.msgs.count

            // notify calls to keyValueBy that happend to soon
            for (idx, lateCompletions) in proxy.inflight {
                // handle calls to keyValueBy() for data right after the prefetch window
                if idx > newCount-1 {
                    proxy.prefetchUpTo(index: idx)
                    print("WARNING: prefetching again for \(idx)!")
                    continue
                }
                let kv = proxy.msgs[idx]
                DispatchQueue.main.async { // update on main-thread or UI might get confused
                    for com in lateCompletions { com(idx, kv) }
                }
                proxy.inflight.removeValue(forKey: idx)
            }
            if moreMessages.count == 0 {
                print("expected to prefetch(\(diff):\(proxy.lastPrefetch-diff)) more messages but got none - clearning inflight")
                proxy.inflight = [:]
            }
            proxy.inflightSema.signal()
        }
    }
}
