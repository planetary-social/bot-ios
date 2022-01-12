//
//  Identifier.swift
//
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

// these aliases are temporary to understand the uses
public typealias Identifier = String // TOOD: isn't this is a problem? It also pollutes NetworkKey and other strings. i tried to use hexEncodedString() on it, which is not a sigl and thus empty string
public typealias Identity = Identifier
public typealias BlobIdentifier = Identifier
public typealias FeedIdentifier = Identifier
public typealias LinkIdentifier = MessageIdentifier
public typealias MessageIdentifier = Identifier
public typealias InviteIdentifier = Identifier
