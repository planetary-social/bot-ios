//
//  Bot.swift
//
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation
import UIKit    // TODO: Just for addBlob consider removing this
import SSB

public class Bot {

    public static var shared = Bot(service: BotServiceAdapter(api: SSBService()))

    var service: BotService

    init(service: BotService) {
        self.service = service
    }

    public func suspend() {
        service.suspend()
    }

    public func exit() {
        service.exit()
    }

    // MARK: Identity

    public var identity: Identity? {
        return service.identity
    }

    public func createSecret(completion: @escaping ((Secret?, Error?) -> Void)) {
        return service.createSecret(completion: completion)
    }

    // TODO: Change DataKey and Secret to something else
    public func login(network: DataKey, hmacKey: DataKey?, secret: Secret, completion: @escaping ((Error?) -> Void)) {
        return service.login(network: network, hmacKey: hmacKey, secret: secret, completion: completion)
    }

    public func logout(completion: @escaping ((Error?) -> Void)) {
        return service.logout(completion: completion)
    }

    // MARK: Sync

    // Ensure that these list of addresses are taken into consideration when establishing connections
    public func seedPubAddresses(addresses: [Pub.Address], completion: @escaping (Result<Void, Error>) -> Void) {
        service.seedPubAddresses(addresses: addresses, completion: completion)
    }

    public func knownPubs(completion: @escaping (([KnownPub], Error?) -> Void)) {
        service.knownPubs(completion: completion)
    }

    public func pubs(completion: @escaping (([Pub], Error?) -> Void)) {
        service.pubs(completion: completion)
    }

    // Sync is the bot reaching out to remote peers and gathering the latest
    // data from the network.  This only updates the local log and requires
    // calling `refresh` to ensure the view database is updated.
    public func sync(peers: [Peer], completion: @escaping ((Error?, TimeInterval, Int) -> Void)) {
        service.sync(peers: peers, completion: completion)
    }

    // This is temporary until live-streaming is deployed on the pubs
    public func syncNotifications(peers: [Peer], completion: @escaping ((Error?, TimeInterval, Int) -> Void)) {
        service.syncNotifications(peers: peers, completion: completion)
    }

    // MARK: Refresh

    // Refresh is the filling of the view database from the bot's index.  Note
    // that `sync` and `refresh` can be called at different intervals, it's just
    // that `refresh` should be called before `recent` if the newest data is desired.
    public func refresh(load: RefreshLoad, completion: @escaping ((Error?, TimeInterval) -> Void)) {
        service.refresh(load: load, completion: completion)
    }

    // MARK: Invites

    // Redeem uses the invite information and accepts it.
    // It adds the pub behind the address to the connection sheduling table and follows it.
    public func inviteRedeem(token: String, completion: @escaping ((Error?) -> Void)) {
        service.inviteRedeem(token: token, completion: completion)
    }

    // MARK: Publish

    // TODO https://app.asana.com/0/914798787098068/1114777817192216/f
    // TOOD for some lower level applications it might make sense to add Secret to publish
    // so that you can publish as multiple IDs (think groups or invites)
    // The `content` argument label is required to avoid conflicts when specialized
    // forms of `publish` are created.  For example, `publish(post)` will publish a
    // `Post` model, but then also the embedded `Hashtag` models.
    public func publish(content: ContentCodable, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
        service.publish(content: content, numberOfPublishedMessages: numberOfPublishedMessages, completion: completion)
    }

    // MARK: About

    public func about(completion: @escaping ((About?, Error?) -> Void)) {
        service.about(completion: completion)
    }

    public func about(identity: Identity, completion:  @escaping ((About?, Error?) -> Void)) {
        service.about(identity: identity, completion: completion)
    }

    public func abouts(identities: [Identity], completion:  @escaping (([About], Error?) -> Void)) {
        service.abouts(identities: identities, completion: completion)
    }

    public func abouts(completion:  @escaping (([About], Error?) -> Void)) {
        service.abouts(completion: completion)
    }

    // MARK: Contact

    public func follow(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((Contact?, Error?) -> Void)) {
        service.follow(identity, numberOfPublishedMessages: numberOfPublishedMessages, completion: completion)
    }

    public func unfollow(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((Contact?, Error?) -> Void)) {
        service.unfollow(identity, numberOfPublishedMessages: numberOfPublishedMessages, completion: completion)
    }

    public func follows(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void)) {
        service.follows(identity: identity, completion: completion)
    }

    public func followedBy(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void)) {
        service.followedBy(identity: identity, completion: completion)
    }

    public func followers(identity: Identity, completion: @escaping (([About], Error?) -> Void)) {
        service.followers(identity: identity, completion: completion)
    }

    public func followings(identity: Identity, completion: @escaping (([About], Error?) -> Void)) {
        service.followings(identity: identity, completion: completion)
    }

    public func friends(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void)) {
        service.friends(identity: identity, completion: completion)
    }

    // TODO the func names should be swapped
    public func blocks(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void)) {
        service.blocks(identity: identity, completion: completion)
    }

    public func blockedBy(identity: Identity, completion:  @escaping (([Identity], Error?) -> Void)) {
        service.blockedBy(identity: identity, completion: completion)
    }

    // MARK: Block

    public func block(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
        service.block(identity, numberOfPublishedMessages: numberOfPublishedMessages, completion: completion)
    }

    public func unblock(_ identity: Identity, numberOfPublishedMessages: UInt, completion: @escaping ((MessageIdentifier, Error?) -> Void)) {
        service.unblock(identity, numberOfPublishedMessages: numberOfPublishedMessages, completion: completion)
    }

    // MARK: Hashtags

    public func hashtags(completion: @escaping (([Hashtag], Error?) -> Void)) {
        service.hashtags(completion: completion)
    }

    public func posts(with hashtag: Hashtag, completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        service.posts(with: hashtag, completion: completion)
    }

    // MARK: Feed

    public func everyone(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        service.everyone(completion: completion)
    }

    public func keyAtEveryoneTop(completion: @escaping (MessageIdentifier?) -> Void) {
        service.keyAtEveryoneTop(completion: completion)
    }

    // your feed
    public func recent(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        service.recent(completion: completion)
    }

    public func keyAtRecentTop(completion: @escaping (MessageIdentifier?) -> Void) {
        service.keyAtRecentTop(completion: completion)
    }

    /// Returns all the messages created by the specified Identity.
    /// This is useful for showing all the posts from a particular
    /// person, like in an About screen.
    public func feed(identity: Identity, completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        service.feed(identity: identity, completion: completion)
    }

    /// Returns the thread of messages related to the specified message.  The root
    /// of the thread will be returned if it is not the specified message.
    public func thread(keyValue: KeyValue, completion: @escaping ((KeyValue?, PaginatedKeyValueDataProxy, Error?) -> Void)) {
        service.thread(keyValue: keyValue, completion: completion)
    }

    public func thread(rootKey: MessageIdentifier, completion: @escaping ((KeyValue?, PaginatedKeyValueDataProxy, Error?) -> Void)) {
        service.thread(rootKey: rootKey, completion: completion)
    }

    /// Returns all the messages in a feed that mention the active identity.
    public func mentions(completion: @escaping ((PaginatedKeyValueDataProxy, Error?) -> Void)) {
        service.mentions(completion: completion)
    }

    /// Reports (unifies mentions, replies, follows) for the active identity.
    public func reports(completion: @escaping (([Report], Error?) -> Void)) {
        service.reports(completion: completion)
    }

    // MARK: Blob publishing

    public func addBlob(data: Data, completion: @escaping ((BlobIdentifier, Error?) -> Void)) {
        service.addBlob(data: data, completion: completion)
    }

    // TODO https://app.asana.com/0/914798787098068/1122165003408766/f
    // TODO consider if this is appropriate to know about UIImage at this level
    @available(*, deprecated)
    public func addBlob(jpegOf image: UIImage, largestDimension: UInt?, completion: @escaping ((Image?, Error?) -> Void)) {
        service.addBlob(jpegOf: image, largestDimension: largestDimension, completion: completion)
    }

    // MARK: Blob loading

    public func data(for identifier: BlobIdentifier, completion: @escaping ((BlobIdentifier, Data?, Error?) -> Void)) {
        service.data(for: identifier, completion: completion)
    }

    /// Saves a file to disk in the same path it would be if fetched through the net.
    /// Useful for storing a blob fetched from an external source.
    public func store(url: URL, for identifier: BlobIdentifier, completion: @escaping ((URL?, Error?) -> Void)) {
        service.store(url: url, for: identifier, completion: completion)
    }

    public func store(data: Data, for identifier: BlobIdentifier, completion: @escaping ((URL?, Error?) -> Void)) {
        service.store(data: data, for: identifier, completion: completion)
    }

    // MARK: Statistics

    public func statistics(completion: @escaping ((Statistics) -> Void)) {
        service.statistics(completion: completion)
    }

    // TODO: Check if we can get away without this
    public func lastReceivedTimestam() throws -> Double {
        return try service.lastReceivedTimestam()
    }

    @available(*, deprecated)
    public var statistics: Statistics {
        return service.statistics
    }

    // MARK: Preloading

    public func preloadFeed(at url: URL, completion: @escaping ((Error?) -> Void)) {
        return service.preloadFeed(at: url, completion: completion)
    }

}
