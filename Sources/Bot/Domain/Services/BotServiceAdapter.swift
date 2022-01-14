//
//  BotServiceAdapter.swift
//  
//
//  Created by Martin Dutra on 28/12/21.
//

import Foundation
import UIKit
import SSB
import Logger
import Analytics
import Monitor
import Blocked

class BotServiceAdapter: BotService {

    var api: APIService

    var database: ViewDatabase

    // TODO: Check if it is still needed
    private var isSyncing: Bool = false
    private var isRefreshing: Bool = false
    private var lastPublishFireTime = DispatchTime.now()
    private let refreshDelay = DispatchTimeInterval.milliseconds(125)
    private let maxBlobBytes = 1024 * 1024 * 8

    var logFileUrls: [URL] {
        let url = URL(fileURLWithPath: self.api.currentRepoPath.appending("/debug"))
        guard let urls = try? FileManager.default.contentsOfDirectory(at: url,
                                                                      includingPropertiesForKeys: [URLResourceKey.creationDateKey],
                                                                      options: .skipsHiddenFiles) else {
                                                                        return []
        }

        return urls.sorted { (lhs, rhs) -> Bool in
            let lhsCreationDate = try? lhs.resourceValues(forKeys: [.creationDateKey]).creationDate
            let rhsCreationDate = try? rhs.resourceValues(forKeys: [.creationDateKey]).creationDate
            if let lhsCreationDate = lhsCreationDate, let rhsCreationDate = rhsCreationDate {
                return lhsCreationDate.compare(rhsCreationDate) == .orderedDescending
            } else if lhsCreationDate == nil {
                return false
            } else {
                return true
            }
        }
    }

    var name: String {
        return api.name
    }

    var version: String {
        return api.version
    }

    var isRunning: Bool {
        return api.isRunning
    }

    var identity: Identity?

    // TODO: See if it is still needed
    /// IMPORTANT
    /// This cached value is for convenience only, and should reflect
    /// how caching might work for other content.  Since the bot knows
    /// about the logged in identity it follows that it could know be
    /// About as well.  However, unless publishing an About also updates
    /// this value, this is an incomplete implementation.
    /// DO NOT DO THIS FOR OTHER CONTENT!
    private var _about: About?
    var about: About? {
        if self._about == nil, let identity = self.identity {
            self._about = try? self.database.getAbout(for: identity)
        }
        return self._about
    }

    var queue: DispatchQueue

    init(api: APIService) {
        self.api = api
        self.queue = api.queue
        self.database = ViewDatabase()
    }

//    func publish(content: ContentCodable, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
//
//    }
//
//    func everyone(completion: @escaping (([KeyValue]) -> Void)) {
//        api.everyone { keyValues, _ in
//            completion(keyValues)
//        }
//    }

    func suspend() {
        queue.async { [api] in
            api.disconnectAll()
        }
    }

    func exit() {
        queue.async { [api] in
            api.disconnectAll()
        }
    }

    func createSecret(completion: @escaping ((Secret?, Error?) -> Void)) {
        queue.async { [api] in
            do {
                let secret = try api.createSecret()
                DispatchQueue.background.async {
                    completion(secret, nil)
                }

            } catch {
                DispatchQueue.background.async {
                    completion(nil, error)
                }
            }
        }
    }

    func login(network: DataKey, hmacKey: DataKey?, secret: Secret, servicePubs: [Identity], completion: @escaping ((Error?) -> Void)) {
        guard identity == nil else {
            if secret.identity == identity {
                DispatchQueue.background.async {
                    completion(nil)
                }
            } else {
                DispatchQueue.background.async {
                    completion(BotError.alreadyLoggedIn)
                }
            }
            return
        }

        // lookup Application Support folder for bot and database
        let appSupportDirs = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory,
                                                                 .userDomainMask, true)
        guard appSupportDirs.count > 0 else {
            DispatchQueue.background.async {
                completion(BotError.unexpectedFault("no support dir"))
            }
            return
        }

        let repoPrefix = appSupportDirs[0]
            .appending("/FBTT")
            .appending("/" + network.hexEncodedString())

        if !database.isOpen() {
            do {
                try database.open(path: repoPrefix, user: secret.identity)
            } catch {
                DispatchQueue.background.async {
                    completion(error)
                }
                return
            }
        } else {
            Logger.shared.unexpected(.botError, "\(#function) warning: database still open")
        }

        // spawn go-bot in the background to return early
        queue.async { [api] in
            #if DEBUG
            // used for locating the files in the simulator
            print("===> starting gobot with prefix: \(repoPrefix)")
            #endif
            let loginErr = api.login(network: network,
                                     hmacKey: hmacKey,
                                     secret: secret,
                                     pathPrefix: repoPrefix,
                                     servicePubs: servicePubs)

            defer {
                DispatchQueue.background.async {
                    completion(loginErr)
                }
            }

            guard loginErr == nil else {
                return
            }

            self.identity = secret.identity

            Blocked.shared.retrieveBlockedList { blocks, err in
                guard err == nil else {
                    Logger.shared.unexpected(.botError, "failed to get blocks: \(err)");
                    return
                } // Analitcis error instead?

                var authors: [FeedIdentifier] = []
                do {
                    authors = try self.database.updateBlockedContent(blocks)
                } catch {
                    // Analitcis error instead?
                    Logger.shared.unexpected(.botError, "viewdb failed to update blocked content: \(error)")
                }

                // add as blocked peers to bot (those dont have contact messages)
                do {
                    for a in authors {
                        try api.nullFeed(author: a)
                        api.block(feed: a)
                    }
                } catch {
                    // Analitcis error instead?
                    Logger.shared.unexpected(.botError, "failed to drop and block content: \(error)")
                }
            }
        }
    }

    func logout(completion: @escaping ((Error?) -> Void)) {
        guard identity != nil else {
            completion(BotError.notLoggedIn)
            return
        }
        if !api.logout() {
            Logger.shared.unexpected(.botError, "failed to logout")
        }
        database.close()
        identity = nil
        completion(nil)
    }

    func seedPubAddresses(addresses: [Pub.Address], completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async { [database] in
            do {
                try addresses.forEach { address throws in
                    try database.saveAddress(feed: address.key,
                                             address: address.multipeer,
                                             redeemed: nil)
                }
                DispatchQueue.background.async {
                    completion(.success(()))
                }

            } catch {
                DispatchQueue.background.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func knownPubs(completion: @escaping (([KnownPub], Error?) -> Void)) {
        queue.async { [database] in
           var err: Error? = nil
           var kps: [KnownPub] = []
           defer {
               DispatchQueue.background.async {
                   completion(kps, err)
               }
           }
           do {
               kps = try database.getAllKnownPubs()
           } catch {
               err = error
           }
        }
    }

    func pubs(completion: @escaping (([Pub], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let pubs = try database.getRedeemedPubs()
                DispatchQueue.background.async {
                    completion(pubs, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func sync(peers: [Peer], completion: @escaping ((Error?, TimeInterval, Int) -> Void)) {
        sync(shouldSyncNotificationsOnly: false, peers: peers, completion: completion)
    }

    func syncNotifications(peers: [Peer], completion: @escaping ((Error?, TimeInterval, Int) -> Void)) {
        sync(shouldSyncNotificationsOnly: true, peers: peers, completion: completion)
    }

    private func sync(shouldSyncNotificationsOnly: Bool,
                      peers: [Peer],
                      completion: @escaping ((Error?, TimeInterval, Int) -> Void)) {
        guard api.isRunning else {
            DispatchQueue.background.async {
                completion(BotError.unexpectedFault("bot not started"), 0, 0);
            }
            return
        }
        guard !isSyncing else {
            DispatchQueue.background.async {
                completion(nil, 0, 0);
            }
            return
        }

        isSyncing = true
        let elapsed = Date()

        queue.async { [api] in
            let before = (try? api.numberOfMessages()) ?? 0
            if shouldSyncNotificationsOnly {
                api.dialForNotifications(from: peers)
            } else {
                api.dialSomePeers(from: peers)
            }
            let after = (try? api.numberOfMessages()) ?? 0
            let new = Int(after) - Int(before)
            DispatchQueue.background.async {
                self.isSyncing = false
                completion(nil, -elapsed.timeIntervalSinceNow, new)
                NotificationCenter.default.postDidSync()
            }
        }
    }

    func refresh(load: RefreshLoad, completion: @escaping ((Error?, TimeInterval) -> Void)) {
        guard isRefreshing == false else {
            DispatchQueue.background.async {
                completion(nil, 0)
            }
            return
        }

        isRefreshing = true

        queue.async {
            self.updateReceive(limit: load.rawValue)
            self.isRefreshing = false
            DispatchQueue.background.async {
                NotificationCenter.default.postDidRefresh()
            }
        }
    }

    private func updateReceive(limit: Int = 15000) -> Error? {
        var current: Int64 = 0
        var diff: Int = 0

        do {
            (current, diff) = try needsViewFill()
        } catch {
            return error
        }

        guard diff > 0 else {
            // still might want to update privates
            updatePrivate()
            return nil
        }

        // TOOD: redo until diff==0
        do {
            let msgs = try api.getReceiveLog(startSeq: current+1, limit: limit)

            guard msgs.count > 0 else {
                print("warning: triggered update but got no messages from receive log")
                return nil
            }

            do {
                try database.fillMessages(msgs: msgs)

                #if DEBUG
                print("[rx log] viewdb filled with \(msgs.count) messages.")
                #endif
                
                Analytics.shared.trackBodDidUpdateDatabase(count: msgs.count,
                                                           firstTimestamp: msgs[0].timestamp,
                                                           lastTimestamp: msgs[msgs.count-1].timestamp,
                                                           lastHash: msgs[msgs.count-1].key)

                if diff < limit { // view is up2date now
                    return nil
                    // disable private messages until there is UI for it AND ADD SQLCYPHER!!!111
                    //self.updatePrivate(completion: completion)
                } else {
                    #if DEBUG
                    print("#rx log# \(diff-limit) messages left in go-ssb offset log")
                    #endif
                    return nil
                }
            } catch ViewDatabaseError.messageConstraintViolation(let author, let sqlErr) {
                let (current,
                     numberOfMessagesInRepo,
                     reportedAuthors,
                     reportedMessages,
                     err) = self.repairViewConstraints21012020(with: author, current: current)

                Analytics.shared.trackBotDidRepair(databaseError: sqlErr,
                                                   error: err?.localizedDescription,
                                                   numberOfMessagesInDB: current,
                                                   numberOfMessagesInRepo: numberOfMessagesInRepo,
                                                   reportedAuthors: reportedAuthors,
                                                   reportedMessages: reportedMessages)

                #if DEBUG
                print("[rx log] viewdb fill of aborted and repaired.")
                #endif

                return err
            } catch {
                let err = BotError.databaseError("viewDB: message filling failed", error)
                Logger.shared.optional(err)
                Monitor.shared.reportIfNeeded(error: err)
                return err
            }
        } catch {
            return error
        }
    }

    /// Should be called inside the work queue
    private func repairViewConstraints21012020(with author: Identity, current: Int64) -> (Int64, UInt, Int?, UInt32?, Error?) {
        // fields we want to include in the tracked event
        // TODO: Check if we can get away without this
        let numberOfMessagesInRepo = (try? api.numberOfMessages()) ?? 0

        // TODO: maybe make an enum for all these errors?
        let (worked, maybeReport) = api.fsckAndRepair()
        guard worked else {
            return (current, numberOfMessagesInRepo, nil, nil, BotError.unexpectedFault("[constraint violation] failed to heal gobot repository"))
        }

        guard let report = maybeReport else { // there was nothing to repair?
            return (current, numberOfMessagesInRepo, nil, nil, BotError.unexpectedFault("[constraint violation] viewdb error but nothing to repair"))
        }

        let reportedAuthors = report.Authors.count
        let reportedMessages = report.Messages

        if !report.Authors.contains(author) {
            Logger.shared.unexpected(.botError, "ViewConstraints21012020 warning: affected author not in heal report")
            // there could be others, so go on
        }

        for a in report.Authors {
            do {
                try database.delete(allFrom: a)
            } catch ViewDatabaseError.unknownAuthor(let identifier) {
                // after the viewdb schema bump, ppl that have this bug
                // only have it in the gobot after the update
                // therefore we can skip this if the viewdb is filling for the first time
                guard current == -1 else {
                    return (current,
                            numberOfMessagesInRepo,
                            reportedAuthors,
                            reportedMessages,
                            BotError.databaseError("[constraint violation] expected author from fsck report in viewdb", ViewDatabaseError.unknownAuthor(identifier)))
                }
                continue
            } catch {
                return (current,
                        numberOfMessagesInRepo,
                        reportedAuthors,
                        reportedMessages,
                        BotError.databaseError("[constraint violation] unable to drop affected feed from viewdb", error))
            }
        }

        return (current,
                numberOfMessagesInRepo,
                reportedAuthors,
                reportedMessages,
                nil)
    }

    /// Should be called inside the work queue
    private func updatePrivate() -> Error? {
        var count: Int64 = 0
        do {
            let c = try database.stats(table: .privates)
            count = Int64(c)

            // TOOD: redo until diff==0
            let msgs = try api.getPrivateLog(startSeq: count, limit: 1000)

            if msgs.count > 0 {
                try database.fillMessages(msgs: msgs, pms: true)

                print("[private log] private log filled with \(msgs.count) msgs (started at \(count))")
            }

            return nil
        } catch {
            Logger.shared.optional(error)
            return error
        }
    }

    /// Should be called inside the work queue
    /// returns (current, diff)
    private func needsViewFill() throws -> (Int64, Int) {
        var lastRxSeq: Int64 = 0
        do {
            lastRxSeq = try database.lastReceivedSeq()
        } catch {
            throw BotError.databaseError("view query failed", error)
        }

        do {
            let numberOfMessages = try api.numberOfMessages()
            if numberOfMessages == 0 {
                return (lastRxSeq, 0)
            }
            let diff = Int(Int64(numberOfMessages) - 1 - lastRxSeq)
            if diff < 0 {
                throw BotError.unexpectedFault("needsViewFill: more msgs in view then in GoBot repo: \(lastRxSeq) (diff: \(diff))")
            }

            return (lastRxSeq, diff)
        } catch {
            throw BotError.apiError("bot current failed", error)
        }
    }


    func inviteRedeem(token: String, completion: @escaping ((Error?) -> Void)) {
        let inviteToken = InviteToken(token)
        queue.async { [api, database] in
            if api.redeem(inviteToken: inviteToken) {
                do {
                    let feed = inviteToken.feed
                    let address = inviteToken.address.multipeer
                    let redeemed = Date().timeIntervalSince1970 * 1000
                    try database.saveAddress(feed: feed, address: address, redeemed: redeemed)
                } catch {
                    Monitor.shared.reportIfNeeded(error: error)
                }
                DispatchQueue.background.async {
                    completion(nil)
                }
            } else {
                DispatchQueue.background.async {
                    completion(BotError.unexpectedFault("invite did not work. Maybe try again?"))
                }
            }
        }
    }

    func about(completion: @escaping ((About?, Error?) -> Void)) {
        guard let user = identity else {
            completion(nil, BotError.notLoggedIn)
            return
        }
        about(identity: user, completion: completion)
    }

    func about(identity: Identity, completion: @escaping ((About?, Error?) -> Void)) {
        let currentIdentity = self.identity
        queue.async { [weak self, database] in
            do {
                let a = try database.getAbout(for: identity)
                DispatchQueue.background.async {
                    if a?.identity == currentIdentity {
                        self?._about = a
                    }
                    completion(a, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion(nil, error)
                }
            }
        }
    }

    func abouts(identities: [Identity], completion: @escaping (([About], Error?) -> Void)) {
        queue.async { [database] in
            var abouts: [About] = []
            for identity in identities {
                if let about = try? database.getAbout(for: identity) {
                    abouts += [about]
                }
            }
            DispatchQueue.background.async {
                completion(abouts, nil)
            }
        }
    }

    func abouts(completion: @escaping (([About], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let abouts = try database.getAbouts()
                DispatchQueue.background.async {
                    completion(abouts, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func follow(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((Contact?, Error?) -> Void)) {
        guard identity != self.identity else {
            completion(nil, BotError.unexpectedFault("Did not expect this to be the current user's Identity."))
            return
        }
        let contact = Contact(contact: identity, following: true)
        publish(content: contact, numberOfPublishedMessages: numberOfPublishedMessages) { _, error in
            let contactOrNilIfError = (error == nil ? contact : nil)
            completion(contactOrNilIfError, error)
        }
    }

    func unfollow(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((Contact?, Error?) -> Void)) {
        guard identity != self.identity else {
            completion(nil, BotError.unexpectedFault("Did not expect this to be the current user's Identity."))
            return
        }
        let contact = Contact(contact: identity, following: false)
        publish(content: contact, numberOfPublishedMessages: numberOfPublishedMessages) { _, error in
            let contactOrNilIfError = (error == nil ? contact : nil)
            completion(contactOrNilIfError, error)
        }
    }

    func follows(identity: Identity, completion: @escaping (([Identity], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let follows: [Identity] = try database.getFollows(feed: identity)
                DispatchQueue.background.async {
                    completion(follows, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func followedBy(identity: Identity, completion: @escaping (([Identity], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let follows: [Identity] = try database.followedBy(feed: identity)
                DispatchQueue.background.async {
                    completion(follows, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func followers(identity: Identity, completion: @escaping (([About], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let follows: [About] = try database.followedBy(feed: identity)
                DispatchQueue.background.async {
                    completion(follows, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func followings(identity: Identity, completion: @escaping (([About], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let follows: [About] = try database.getFollows(feed: identity)
                DispatchQueue.background.async {
                    completion(follows, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func friends(identity: Identity, completion: @escaping (([Identity], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let who = try database.getBidirectionalFollows(feed: identity)
                DispatchQueue.background.async {
                    completion(who, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func blocks(identity: Identity, completion: @escaping (([Identity], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let who = try database.getBlocks(feed: identity)
                DispatchQueue.background.async {
                    completion(who, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func blockedBy(identity: Identity, completion: @escaping (([Identity], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let who = try database.blockedBy(feed: identity)
                DispatchQueue.background.async {
                    completion(who, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func block(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
        let block = Contact(contact: identity, blocking: true)
        // TODO: Make internal publish
        publish(content: block, numberOfPublishedMessages: numberOfPublishedMessages) { [database, api] ref, err in
            if let e = err {
                DispatchQueue.background.async {
                    completion("", e)
                }
                return
            }
            do {
                try database.delete(allFrom: identity)
            } catch {
                DispatchQueue.background.async {
                    completion("", BotError.databaseError("deleting feed from view failed", error))
                }
                return
            }

            do {
                try api.nullFeed(author: identity)
            } catch {
                DispatchQueue.background.async {
                    completion("", BotError.apiError("deleting feed from bot failed", error))
                }
                return
            }

            completion(ref, nil)
            NotificationCenter.default.postDidBlockUser(identity: identity)
        }
    }

    func unblock(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
        publish(content: Contact(contact: identity, blocking: false), numberOfPublishedMessages: numberOfPublishedMessages) {
            ref, err in
            if let e = err {
                completion("", e);
                return;
            }
            completion(ref, nil)
        }
    }

    func hashtags(completion: @escaping (([Hashtag], Error?) -> Void)) {
        queue.async { [database] in
            do {
                var hashtags = try database.hashtags()
                hashtags.reverse()
                DispatchQueue.background.async {
                    completion(hashtags, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([], error)
                }
            }
        }
    }

    func posts(with hashtag: Hashtag, completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        queue.async { [database] in
            do {
                let keyValues = try database.messagesForHashtag(name: hashtag.name)
                let p = StaticDataProxy(with: keyValues)
                DispatchQueue.background.async {
                    completion(p, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion(StaticDataProxy(), error)
                }
            }
        }
    }

    func everyone(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        queue.async {
            do {
                let msgs = try self.database.paginated(onlyFollowed: false)
                DispatchQueue.background.async {
                    completion(msgs, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion(StaticDataProxy(), error)
                }
            }
        }
    }

    func keyAtEveryoneTop(completion: @escaping (MessageIdentifier?) -> Void) {
        queue.async { [database] in
            do {
                let key = try database.paginatedTop(onlyFollowed: false)
                DispatchQueue.background.async {
                    completion(key)
                }
            } catch {
                DispatchQueue.background.async {
                    completion(nil)
                }
            }
        }
    }

    func recent(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        queue.async { [database] in
            do {
                let ds = try database.paginated(onlyFollowed: true)
                DispatchQueue.background.async {
                    completion(ds, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion(StaticDataProxy(), error)
                }
            }
        }
    }

    func keyAtRecentTop(completion: @escaping (MessageIdentifier?) -> Void) {
        queue.async { [database] in
            do {
                let key = try database.paginatedTop(onlyFollowed: true)
                DispatchQueue.background.async {
                    completion(key)
                }
            } catch {
                DispatchQueue.background.async {
                    completion(nil)
                }
            }
        }
    }

    func feed(identity: Identity, completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        queue.async { [database] in
            do {
                let ds = try database.paginated(feed: identity)
                DispatchQueue.background.async {
                    completion(ds, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion(StaticDataProxy(), error)
                }
            }
        }
    }

    func thread(keyValue: KeyValue, completion: @escaping ((KeyValue?, PaginatedKeyValueDataProxy, Error?) -> Void)) {
        queue.async { [database] in
            if let rootKey = keyValue.value.content.post?.root {
                do {
                    let root = try database.get(key: rootKey)
                    let replies = try database.getRepliesTo(thread: root.key)
                    DispatchQueue.background.async {
                        completion(root, StaticDataProxy(with:replies), nil)
                    }
                } catch {
                    DispatchQueue.background.async {
                        completion(nil, StaticDataProxy(), error)
                    }
                }
            } else {
                self.internalThread(rootKey: keyValue.key, completion: completion)
            }
        }
    }

    /// Should be called inside the worked thread
    private func internalThread(rootKey: MessageIdentifier, completion: @escaping ((KeyValue?, PaginatedKeyValueDataProxy, Error?) -> Void)) {
        do {
            let root = try database.get(key: rootKey)
            let replies = try database.getRepliesTo(thread: rootKey)
            DispatchQueue.background.async {
                completion(root, StaticDataProxy(with:replies), nil)
            }
        } catch {
            DispatchQueue.background.async {
                completion(nil, StaticDataProxy(), error)
            }
        }
    }

    func thread(rootKey: MessageIdentifier, completion: @escaping ((KeyValue?, PaginatedKeyValueDataProxy, Error?) -> Void)) {
        queue.async { [weak self] in
            self?.internalThread(rootKey: rootKey, completion: completion)
        }
    }

    func mentions(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        queue.async { [database] in
            do {
                let messages = try database.mentions(limit: 1000)
                let p = StaticDataProxy(with:messages)
                DispatchQueue.background.async {
                    completion(p, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion(StaticDataProxy(), error)
                }
            }
        }
    }

    func reports(completion: @escaping (([Report], Error?) -> Void)) {
        queue.async { [database] in
            do {
                let all = try database.reports()
                DispatchQueue.background.async {
                    completion(all, nil)
                }
            } catch {
                DispatchQueue.background.async {
                    completion([],error)
                }
            }
        }
    }

    func addBlob(data: Data, completion: @escaping ((BlobIdentifier, Error?) -> Void)) {
        guard data.count <= self.maxBlobBytes else {
            DispatchQueue.background.async {
                completion(BlobIdentifier.null, BotError.blobMaximumSizeExceeded)
            }
            return
        }
        queue.async { [api] in
            api.blobsAdd(data: data) { identifier, error in
                DispatchQueue.background.async {
                    completion(identifier, error)
                }
            }
        }
    }

    func addBlob(jpegOf image: UIImage, largestDimension: UInt?, completion: @escaping ((Image?, Error?) -> Void)) {
        // convenience closure to keep code cleaner
        let completionOnMain: ((Image?, Error?) -> Void) = {
            image, error in
            DispatchQueue.background.async { completion(image, error) }
        }

        queue.async { [api] in

            // encode image or return failures
            var image: UIImage? = image
            if let dimension = largestDimension                             { image = image?.resized(toLargestDimension: CGFloat(dimension)) }
            guard let uiimage = image else                                  { completionOnMain(nil, BotError.blobUnsupportedFormat); return }
            guard let data = uiimage.jpegData(compressionQuality: 0.5) else { completionOnMain(nil, BotError.blobUnsupportedFormat); return }
            guard data.count <= self.maxBlobBytes else                      { completionOnMain(nil, BotError.blobMaximumSizeExceeded); return }

            // add to log and return Image if successful
            api.blobsAdd(data: data) {
                identifier, error in
                Monitor.shared.reportIfNeeded(error: error)
                if Logger.shared.optional(error, nil) {
                    completionOnMain(nil, error)
                    return
                }
                let image = Image(link: identifier, jpegImage: uiimage, data: data)
                completionOnMain(image, nil)
            }
        }
    }

    func data(for identifier: BlobIdentifier, completion: @escaping ((BlobIdentifier, Data?, Error?) -> Void)) {
        guard identifier.isValidIdentifier else {
            completion(identifier, nil, BotError.blobInvalidIdentifier)
            return
        }

        queue.async { [api] in
            do {
                let data = try api.blobGet(ref: identifier)
                DispatchQueue.background.async {
                    if data.isEmpty {
                        completion(identifier, nil, BotError.blobUnavailable)
                    } else {
                        completion(identifier, data, nil)
                    }
                }
            } catch {
                DispatchQueue.background.async {
                    completion(identifier, nil, error)
                }
            }
        }
    }

    func store(url: URL, for identifier: BlobIdentifier, completion: @escaping ((URL?, Error?) -> Void)) {
        queue.async { [api] in
            do {
                let repoURL = try api.blobFileURL(ref: identifier)
                try FileManager.default.createDirectory(at: repoURL.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                try FileManager.default.copyItem(at: url, to: repoURL)
                completion(repoURL, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }

    func store(data: Data, for identifier: BlobIdentifier, completion: @escaping ((URL?, Error?) -> Void)) {
        queue.async { [api] in
            let url: URL
            do {
                url = try api.blobFileURL(ref: identifier)
            } catch let error {
                DispatchQueue.background.async {
                    completion(nil, error)
                }
                return
            }
            // Use a background thread here, no need to mess with the our standard
            // queue. If a race condition arises, it is just the same file being
            // written twice.
            DispatchQueue.background.async {
                do {
                    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                    try data.write(to: url, options: .atomic)
                    completion(url, nil)
                } catch let error {
                    completion(nil, error)
                }
            }
        }
    }

    func statistics(completion: @escaping ((Statistics) -> Void)) {
        queue.async { [api, database] in
            var ownMessages = -1
            if let identity = self.identity, let omc = try? database.numberOfMessages(for: identity) {
                ownMessages = omc
            }

            var statistics = Statistics()
            
            statistics.repo = api.repoStatistics(numberOfPublishedMessages: ownMessages)

            statistics.peer = api.peerStatistics()

            let sequence = try? database.stats(table: .messagekeys)
            statistics.db = DatabaseStatistics(lastReceivedMessage: sequence ?? -3)

            DispatchQueue.background.async {
                completion(statistics)
            }
        }
    }

    // TODO: Change to completion handler
    func lastReceivedTimestam() throws -> Double {
        return Double(try database.lastReceivedTimestamp())
    }

    var statistics: Statistics {
        return Statistics()
    }

    func preloadFeed(at url: URL, completion: @escaping ((Error?) -> Void)) {
        queue.async { [database] in
            do {
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                do {
                    let msgs = try JSONDecoder().decode([KeyValue].self, from: data)

                    var lastRxSeq: Int64 = try database.minimumReceivedSeq()

                    let newMesgs = msgs.map { (msg: KeyValue) -> KeyValue in
                        lastRxSeq = lastRxSeq - 1
                        return KeyValue(key: msg.key,
                                        value: msg.value,
                                        timestamp: msg.timestamp,
                                        receivedSeq: lastRxSeq,
                                        hashedKey: msg.key.sha256hash
                        )
                    }

                    try database.fillMessages(msgs: newMesgs)

                    DispatchQueue.background.async {
                        completion(nil)
                    }
                } catch {
                    print(error) // shows error
                    print("Decoding failed")// local message
                    DispatchQueue.background.async {
                        completion(error)
                    }
                }
            } catch {
                print(error) // shows error
                print("Unable to read file")// local message
                DispatchQueue.background.async {
                    completion(error)
                }
            }
        }
    }

    /// numberOfPublishedMessages
    func publish(content: ContentCodable, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
        queue.async { [api, database, refreshDelay] in
            guard let identity = self.identity else {
                DispatchQueue.background.async {
                    completion(MessageIdentifier.null, BotError.notLoggedIn)
                }
                return
            }

            if UserDefaults.standard.bool(forKey: "prevent_feed_from_forks") {
                guard let numberOfMessagesInRepo = try? database.numberOfMessages(for: identity) else {
                    DispatchQueue.background.async {
                        completion(MessageIdentifier.null, BotError.unexpectedFault("Failed to access database"))
                    }
                    return
                }

                guard numberOfMessagesInRepo >= numberOfPublishedMessages else {
                    DispatchQueue.background.async {
                        completion(MessageIdentifier.null, BotError.notEnoughMessagesInRepo)
                    }
                    return
                }
            }

            api.publish(content: content) { [weak self] key, error in
                if let error = error {
                    DispatchQueue.background.async {
                        completion(MessageIdentifier.null, error)
                    }
                    return
                }

                // debounce refresh calls (at most one every 125ms)
                let now = DispatchTime.now()
                self?.lastPublishFireTime = now
                let refreshTime: DispatchTime = now + refreshDelay

                self?.queue.asyncAfter(deadline: refreshTime) {
                    guard let lastFireTime = self?.lastPublishFireTime else {
                        return
                    }

                    let when: DispatchTime = lastFireTime + refreshDelay
                    let now = DispatchTime.now()

                    // the call happend after the given timeout (refreshDelay)
                    if now.rawValue >= when.rawValue {
                        self?.refresh(load: .tiny) { error, _ in
                            Logger.shared.optional(error)
                            Monitor.shared.reportIfNeeded(error: error)
                            completion(key, nil)
                        }
                    } else {
                        // don't do a view refresh, just return to the caller
                        // Q: is this actually called for each asyncAfter call?
                        DispatchQueue.background.async {
                            completion(key, nil)
                        }
                    }
                }
            }
        }
    }

    func repair() -> Bool {
        return api.repair()
    }

    
}
