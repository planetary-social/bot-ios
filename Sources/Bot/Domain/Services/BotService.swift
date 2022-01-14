//
//  File.swift
//  
//
//  Created by Martin Dutra on 28/12/21.
//

import Foundation
import UIKit
import SSB

protocol BotService {

    var logFileUrls: [URL] { get }

    var name: String { get }

    var version: String { get }

    var isRunning: Bool { get }
    
    // MARK: AppLifecycle

    func suspend()

    func exit()

    // MARK: Identity

    var identity: Identity? {
        get
    }

    func createSecret(completion: @escaping ((Secret?, Error?) -> Void))

    // TODO: Change DataKey and Secret to something else
    func login(network: DataKey, hmacKey: DataKey?, secret: Secret, servicePubs: [Identity], completion: @escaping ((Error?) -> Void))

    func logout(completion: @escaping ((Error?) -> Void))

    // MARK: Sync

    // Ensure that these list of addresses are taken into consideration when establishing connections
    func seedPubAddresses(addresses: [Pub.Address], completion: @escaping (Result<Void, Error>) -> Void)

    func knownPubs(completion: @escaping (([KnownPub], Error?) -> Void))

    func pubs(completion: @escaping (([Pub], Error?) -> Void))

    // Sync is the bot reaching out to remote peers and gathering the latest
    // data from the network.  This only updates the local log and requires
    // calling `refresh` to ensure the view database is updated.
    func sync(peers: [Peer], completion: @escaping ((Error?, TimeInterval, Int) -> Void))

    // This is temporary until live-streaming is deployed on the pubs
    func syncNotifications(peers: [Peer], completion: @escaping ((Error?, TimeInterval, Int) -> Void))

    // MARK: Refresh

    // Refresh is the filling of the view database from the bot's index.  Note
    // that `sync` and `refresh` can be called at different intervals, it's just
    // that `refresh` should be called before `recent` if the newest data is desired.
    func refresh(load: RefreshLoad, completion: @escaping ((Error?, TimeInterval) -> Void))

    // MARK: Invites

    // Redeem uses the invite information and accepts it.
    // It adds the pub behind the address to the connection sheduling table and follows it.
    func inviteRedeem(token: String, completion: @escaping ((Error?) -> Void))

    // MARK: Publish

    // TODO https://app.asana.com/0/914798787098068/1114777817192216/f
    // TOOD for some lower level applications it might make sense to add Secret to publish
    // so that you can publish as multiple IDs (think groups or invites)
    // The `content` argument label is required to avoid conflicts when specialized
    // forms of `publish` are created.  For example, `publish(post)` will publish a
    // `Post` model, but then also the embedded `Hashtag` models.
    func publish(content: ContentCodable, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void))

    // MARK: About

    func about(completion: @escaping ((About?, Error?) -> Void))

    func about(identity: Identity, completion:  @escaping ((About?, Error?) -> Void))

    func abouts(identities: [Identity], completion:  @escaping (([About], Error?) -> Void))

    func abouts(completion:  @escaping (([About], Error?) -> Void))

    // MARK: Contact

    func follow(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((Contact?, Error?) -> Void))

    func unfollow(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((Contact?, Error?) -> Void))

    func follows(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void))

    func followedBy(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void))

    func followers(identity: Identity, completion: @escaping (([About], Error?) -> Void))

    func followings(identity: Identity, completion: @escaping (([About], Error?) -> Void))

    func friends(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void))

    // TODO the func names should be swapped
    func blocks(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void))

    func blockedBy(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void))

    // MARK: Block

    func block(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void))

    func unblock(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void))

    // MARK: Hashtags

    func hashtags(completion: @escaping (([Hashtag], Error?) -> Void))

    func posts(with hashtag: Hashtag, completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void))

    // MARK: Feed

    func everyone(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void))

    func keyAtEveryoneTop(completion: @escaping (MessageIdentifier?) -> Void)

    // your feed
    func recent(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void))

    func keyAtRecentTop(completion: @escaping (MessageIdentifier?) -> Void)

    /// Returns all the messages created by the specified Identity.
    /// This is useful for showing all the posts from a particular
    /// person, like in an About screen.
    func feed(identity: Identity, completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void))

    /// Returns the thread of messages related to the specified message.  The root
    /// of the thread will be returned if it is not the specified message.
    func thread(keyValue: KeyValue, completion: @escaping ((KeyValue?, PaginatedKeyValueDataProxy, Error?) -> Void))

    func thread(rootKey: MessageIdentifier, completion: @escaping ((KeyValue?, PaginatedKeyValueDataProxy, Error?) -> Void))

    /// Returns all the messages in a feed that mention the active identity.
    func mentions(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void))

    /// Reports (unifies mentions, replies, follows) for the active identity.
    func reports(completion: @escaping (([Report], Error?) -> Void))

    // MARK: Blob publishing

    func addBlob(data: Data, completion: @escaping ((BlobIdentifier, Error?) -> Void))

    // TODO https://app.asana.com/0/914798787098068/1122165003408766/f
    // TODO consider if this is appropriate to know about UIImage at this level
    @available(*, deprecated)
    func addBlob(jpegOf image: UIImage, largestDimension: UInt?, completion: @escaping ((Image?, Error?) -> Void))

    // MARK: Blob loading

    func data(for identifier: BlobIdentifier, completion: @escaping ((BlobIdentifier, Data?, Error?) -> Void))

    /// Saves a file to disk in the same path it would be if fetched through the net.
    /// Useful for storing a blob fetched from an external source.
    func store(url: URL, for identifier: BlobIdentifier, completion: @escaping ((URL?, Error?) -> Void))

    func store(data: Data, for identifier: BlobIdentifier, completion: @escaping ((URL?, Error?) -> Void))

    // MARK: Statistics

    func statistics(completion: @escaping ((Statistics) -> Void))

    func lastReceivedTimestam() throws -> Double

    @available(*, deprecated)
    var statistics: Statistics {
        get
    }

    // MARK: Preloading

    func preloadFeed(at url: URL, completion: @escaping ((Error?) -> Void))

    func repair() -> Bool
    
}
