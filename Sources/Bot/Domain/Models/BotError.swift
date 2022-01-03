//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

enum BotError: Error {
    case alreadyLoggedIn
    case blobInvalidIdentifier
    case blobUnsupportedFormat
    case blobUnavailable
    case blobMaximumSizeExceeded
    case encodeFailure
    case invalidIdentity
    case notLoggedIn
    case notEnoughMessagesInRepo
}
