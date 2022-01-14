//
//  ModeratorService.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation
import Moderator
import UIKit
import SSB

class ModeratorService: APIService {

    var queue: DispatchQueue = DispatchQueue.background

    var currentRepoPath: String = ""

    var name: String = "Moderator"

    var version: String {
        return "0.1"
    }

    var isRunning: Bool {
        return true
    }

    private var keyValues = [KeyValue]()

    func createSecret() throws -> Secret? {
        return nil
    }

    func login(network: DataKey, hmacKey: DataKey?, secret: Secret, pathPrefix: String, servicePubs: [Identity]) -> Error? {
        Moderator.shared.everyone { posts in
            let keyValues = posts.map { post -> KeyValue in
                let builder = KeyValueBuilder()
                return builder.build(post: post)
            }
            self.keyValues = keyValues
        }
        return nil
    }

    func logout() -> Bool {
        return true
    }

    func openConnections() -> UInt {
        return 0
    }

    func openConnectionList() -> [(String, Identity)] {
        return []
    }

    func disconnectAll() {
        return
    }

    func dial(from peers: [Peer], atLeast: Int, tries: Int) -> Bool {
        return true
    }

    func dialSomePeers(from peers: [Peer]) -> Bool {
        return true
    }

    func dialOne(peer: Peer) -> Bool {
        return true
    }

    func dialForNotifications(from peers: [Peer]) -> Bool {
        return true
    }

    func fsckAndRepair() -> (Bool, HealReport?) {
        return (false, nil)
    }

    func numberOfMessages() throws -> UInt {
        return 0
    }

    func repoStatistics(numberOfPublishedMessages: Int) -> RepoStatistics {
        return RepoStatistics()
    }

    func peerStatistics() -> PeerStatistics {
        return PeerStatistics()
    }

    func status() throws -> Status {
        throw BotError.notLoggedIn
    }

    func block(feed: FeedIdentifier) {
        return
    }

    func unblock(feed: FeedIdentifier) {
        return
    }

    func replicate(feed: FeedIdentifier) {
        return
    }

    func dontReplicate(feed: FeedIdentifier) {
        return
    }

    func nullContent(author: Identity, sequence: UInt) throws {
        throw BotError.notLoggedIn
    }

    func nullFeed(author: Identity) throws {
        throw BotError.notLoggedIn
    }

    func blobsAdd(data: Data, completion: @escaping ((BlobIdentifier, Error?) -> Void)) {
        completion("", nil)
    }

    func blobFileURL(ref: BlobIdentifier) throws -> URL {
        throw BotError.notLoggedIn
    }

    func blobGet(ref: BlobIdentifier) throws -> Data {
        throw BotError.notLoggedIn
    }

    func blobsWant(ref: BlobIdentifier) throws {
        return
    }

    func getFeedList(completion: @escaping (([Identity : Int], Error?) -> Void)) {
        completion([:], nil)
    }

    func getReceiveLog(startSeq: Int64, limit: Int) throws -> [KeyValue] {
        return keyValues
    }

    func getPrivateLog(startSeq: Int64, limit: Int) throws -> [KeyValue] {
        return keyValues
    }

    func publish(content: ContentCodable, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
        completion("", nil)
    }

    func redeem(inviteToken: InviteToken) -> Bool {
        return false
    }

    func repair() -> Bool {
        return false
    }
}
