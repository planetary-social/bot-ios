//
//  APIService.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation
import SSB

protocol APIService {

    var queue: DispatchQueue { get }

    var name: String { get }
    
    var currentRepoPath: String { get }

    var version: String { get }

    var isRunning: Bool { get }

    // MARK: login / logout

    func createSecret() throws -> Secret?

    func login(network: DataKey, hmacKey: DataKey?, secret: Secret, pathPrefix: String, servicePubs: [Identity]) -> Error?

    func logout() -> Bool

    func openConnections() -> UInt

    func openConnectionList() -> [(String, Identity)]

    func disconnectAll()

    func repair() -> Bool

    // TODO: Change Peer to something else

    @discardableResult
    func dial(from peers: [Peer], atLeast: Int, tries: Int) -> Bool

    @discardableResult
    func dialSomePeers(from peers: [Peer]) -> Bool

    func dialOne(peer: Peer) -> Bool

    @discardableResult
    func dialForNotifications(from peers: [Peer]) -> Bool

    // MARK: Status / repo stats

    func numberOfMessages() throws -> UInt
    func repoStatistics(numberOfPublishedMessages: Int) -> RepoStatistics
    func peerStatistics() -> PeerStatistics

    // TODO: Change HealReport to something else
    func fsckAndRepair() -> (Bool, HealReport?)

    func status() throws -> Status

    // MARK: manual block / replicate
    func block(feed: FeedIdentifier)

    func unblock(feed: FeedIdentifier)

    // TODO: call this to fetch a feed without following it
    func replicate(feed: FeedIdentifier)

    func dontReplicate(feed: FeedIdentifier)

    // MARK: Null / Delete

    func nullContent(author: Identity, sequence: UInt) throws

    func nullFeed(author: Identity) throws

    // MARK: blobs

    func blobsAdd(data: Data, completion: @escaping ((BlobIdentifier, Error?) -> Void))

    func blobFileURL(ref: BlobIdentifier) throws -> URL

    func blobGet(ref: BlobIdentifier) throws -> Data

    func blobsWant(ref: BlobIdentifier) throws

    // retreive a list of stored feeds and their current sequence number
    func getFeedList(completion: @escaping (([Identity : Int], Error?)->Void))

    // MARK: message streams

    // aka createLogStream
    func getReceiveLog(startSeq: Int64, limit: Int) throws -> [KeyValue]

    // aka private.read
    func getPrivateLog(startSeq: Int64, limit: Int) throws -> [KeyValue]

    // MARK: Publish

    func publish(content: ContentCodable, completion: @escaping ((MessageIdentifier, Error?) -> Void))

    func redeem(inviteToken: InviteToken) -> Bool
}
