//
//  SSBService.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation
import UIKit
import SSB
import Logger
import Monitor
import Blocked

class SSBService: APIService {

    var queue: DispatchQueue
    var database: ViewDatabase
    var ssb: SSB

    init() {
        self.database = ViewDatabase()
        self.queue = DispatchQueue(label: "GoBot",
                                   qos: .utility,
                                   attributes: .concurrent,
                                   autoreleaseFrequency: .workItem,
                                   target: nil)
        self.ssb = SSB(queue: queue)
    }

    var currentRepoPath: String = "/tmp/FBTT/unset"

    var name: String = "GoBot"

    var version: String {
        return ssb.version
    }

    var isRunning: Bool {
        return ssb.isRunning
    }

    func createSecret() throws -> Secret? {
        return try ssb.createSecret()
    }

    func login(network: DataKey, hmacKey: DataKey?, secret: Secret, pathPrefix: String, servicePubs: [Identity]) -> Error? {
        ssb.didUpdateBearerToken = { token, expires in
            Blocked.shared.updateToken(token, expires: expires)
        }
        ssb.didReceiveBlobHandler = { key in
            NotificationCenter.default.postDidLoadBlob(identifier: key.rawValue)
        }
        let worked = ssb.start(network: network,
                               hmacKey: hmacKey,
                               secret: secret,
                               path: pathPrefix,
                               schemaVersion: ViewDatabase.schemaVersion,
                               servicePubs: servicePubs.map{Key($0)})
        if worked {
            ssb.replicate(feed: Key(secret.identity))
            for pub in servicePubs {
                ssb.replicate(feed: Key(pub))
            }
            return nil
        } else {
            return SSBError.unexpectedFault("failed to start")
        }
    }

    func logout() -> Bool {
        guard ssb.isRunning else {
            Logger.shared.info("[GoBot] wanted to logout but bot not running")
            return false
        }
        if !ssb.stop() {
            Logger.shared.fatal(.botError, "stoping GoSbot failed.")
            return false
        }
        return true
    }

    func openConnections() -> UInt {
        return ssb.openConnections
    }

    func openConnectionList() -> [(String, Identity)] {
        return ssb.openConnectionList().map { ($0.0, $0.1.rawValue) }
    }

    func disconnectAll() {
        ssb.disconnectAll()
    }

    func dial(from peers: [Peer], atLeast: Int, tries: Int) -> Bool {
        let wanted = min(peers.count, atLeast) // how many connections are we shooting for?
        var hasWorked :Int = 0
        var tried: Int = tries
        while hasWorked < wanted && tried > 0 {
            if self.dialAnyone(from: peers) {
                hasWorked += 1
            }
            tried -= 1
        }
        if hasWorked != wanted {
            Logger.shared.unexpected(.botError, "failed to make peer connection(s)")
            return false
        }
        return true
    }

    func dialSomePeers(from peers: [Peer]) -> Bool {
        // only make connections if we dont have any
        guard ssb.openConnections < 3 else {
            return true
        }
        _ = ssb.connectPeers(count: 2)
        guard peers.count > 0 else {
            Logger.shared.debug("User doesn't have redeemed pubs")
            return true
        }
        self.dial(from: peers, atLeast: 1, tries: 10)
        return true
    }

    func dialOne(peer: Peer) -> Bool {
        Logger.shared.debug("Dialing \(peer.key.rawValue)")
        let worked = ssb.connect(peer: peer)

        if !worked {
            Logger.shared.unexpected(.botError, "muxrpc connect to \(peer) failed")
        }
        return worked
    }

    private func dialAnyone(from peers: [Peer]) -> Bool {
        guard let peer = peers.randomElement() else {
            Logger.shared.unexpected(.botError, "no peers in sheduler table")
            return false
        }
        return self.dialOne(peer: peer)
    }

    func dialForNotifications(from peers: [Peer]) -> Bool {
        if let peer = peers.randomElement() {
            return dialOne(peer: peer)
        } else {
            return false
        }
    }

    func numberOfMessages() throws -> UInt {
        let repoStatus = try ssb.statistics()
        return repoStatus.messages
    }

    func repoStatistics(numberOfPublishedMessages: Int) -> RepoStatistics {
        let repoStatus = try? ssb.statistics()
        var fc: Int = -1
        if let feedCount = repoStatus?.feeds { fc = Int(feedCount) }
        var mc: Int = -1
        if let msgs = repoStatus?.messages { mc = Int(msgs) }
        return RepoStatistics(path: currentRepoPath,
                              feedCount: fc,
                              messageCount: mc,
                              numberOfPublishedMessages: numberOfPublishedMessages,
                              lastHash: repoStatus?.lastHash ?? "")
    }

    func peerStatistics() -> PeerStatistics {
        let connectionCount = openConnections()
        let openConnections = openConnectionList()

        return PeerStatistics(count: openConnections.count,
                              connectionCount: connectionCount,
                              identities: openConnections,
                              open: openConnections)
    }

    func fsckAndRepair() -> (Bool, HealReport?) {
        // disable sync during fsck check and cleanup
        // new message kill the performance of this process
        ssb.disconnectAll()

        // TODO: disable network listener to stop local connections
        // would be better then a polling timer but this suffices as a bug fix
        let dcTimer = RepeatingTimer(interval: 5, completion: { [ssb] in
            ssb.disconnectAll()
        })
        dcTimer.start()

        defer {
            dcTimer.stop()
        }

        NotificationCenter.default.postDidStartFSCKRepair()
        defer {
            NotificationCenter.default.postDidFinishFSCKRepair()
        }

        ssb.didUpdateFSCKRepair = { percent, remainingTime in
            NotificationCenter.default.postDidUpdateFSCKRepair(percent: percent,
                                                               remaining: remainingTime)
        }

        let fsckResult = ssb.fsck(mode: .sequences)

        guard !fsckResult else {
            Logger.shared.unexpected(.botError, "repair was triggered but repo fsck says it's fine")
            return (true, nil)
        }

        do {
            let report = try ssb.heal()
            return (true, report)
        } catch {
            Logger.shared.optional(error, nil)
            Monitor.shared.reportIfNeeded(error: error)
            return (false, nil)
        }
    }

    func status() throws -> Status {
        return try ssb.status()
    }

    func block(feed: FeedIdentifier) {
        ssb.block(feed: Key(feed))
    }

    func unblock(feed: FeedIdentifier) {
        ssb.unblock(feed: Key(feed))
    }

    func replicate(feed: FeedIdentifier) {
        ssb.replicate(feed: Key(feed))
    }

    func dontReplicate(feed: FeedIdentifier) {
        ssb.dontReplicate(feed: Key(feed))
    }

    func nullContent(author: Identity, sequence: UInt) throws {
        try ssb.nullContent(author: Key(author), sequence: sequence)
    }

    func nullFeed(author: Identity) throws {
        ssb.nullFeed(author: Key(author))
    }

    func blobsAdd(data: Data, completion: @escaping ((BlobIdentifier, Error?) -> Void)) {
        do {
            let key = try ssb.addBlob(data: data)
            completion(key.rawValue, nil)
        } catch {
            completion("", SSBError.unexpectedFault("blobsAdd failed"))
        }
    }

    func blobFileURL(ref: BlobIdentifier) throws -> URL {
        return try ssb.blobFileURL(ref: Key(ref))
    }

    func blobGet(ref: BlobIdentifier) throws -> Data {
        if let data = try ssb.blobGet(ref: Key(ref)) {
            return data
        } else {
            throw BotError.blobUnavailable
        }
    }

    func blobsWant(ref: BlobIdentifier) throws {
        ssb.blobsWant(ref: Key(ref))
    }

    func getFeedList(completion: @escaping (([Identity : Int], Error?) -> Void)) {
        do {
            let feedList = try ssb.getFeedList()
            var ret: [Identity: Int] = [:]
            feedList.forEach { (key: Key, value: Int) in
                ret[key.rawValue] = value
            }
            completion(ret, nil)
        } catch {
            completion([:], error)
        }
    }

    func getReceiveLog(startSeq: Int64, limit: Int) throws -> [KeyValue] {
        return try ssb.getReceiveLog(startSeq: startSeq, limit: limit)
    }

    func getPrivateLog(startSeq: Int64, limit: Int) throws -> [KeyValue] {
        return try ssb.getPrivateLog(startSeq: startSeq, limit: limit)
    }

    func publish(content: ContentCodable, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
        do {
            let cData = try content.encodeToData()
            let contentStr = String(data: cData, encoding: .utf8) ?? "]},invalid]-warning:invalid content"
            let key = try ssb.publish(content: contentStr)
            if let newRef = key?.rawValue {
                completion(newRef, nil)
            } else {
                completion("", SSBError.unexpectedFault("publish: failed to write content"))
            }
        } catch {
            completion("", SSBError.duringProcessing("publish: failed to write content", error))
        }
    }

    func redeem(inviteToken: InviteToken) -> Bool {
        return ssb.acceptInvite(token: inviteToken.rawValue)
    }

    func repair() -> Bool {
        return ssb.dropIndexData()
    }

}
