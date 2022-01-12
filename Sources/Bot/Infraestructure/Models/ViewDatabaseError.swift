//
//  ViewDatabaseError.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

enum ViewDatabaseError: Error {

    case notOpen
    case alreadyOpen
    case unknownMessage(MessageIdentifier)
    case unknownAuthor(Identifier)
    case unknownReferenceID(Int64)
    case unexpectedContentType(String)
    case unknownTable(ViewDatabaseTableNames)
    case unhandledContentType(ContentType)
    case messageConstraintViolation(Identity, String)

}

extension ViewDatabaseError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .notOpen:
            return "Not open"
        case .alreadyOpen:
            return "Already open"
        case .unknownMessage(let messageIdentifier):
            return "Unknown message: \(messageIdentifier)"
        case .unknownAuthor(let identifier):
            return "Unknown author: \(identifier)"
        case .unknownReferenceID(let referenceId):
            return "Unknown reference id: \(referenceId)"
        case .unexpectedContentType(let contentType):
            return "Unexpected content type: \(contentType)"
        case .unknownTable(let table):
            return "Unknown table: \(table)"
        case .unhandledContentType(let contentType):
            return "Unhandled content type: \(contentType)"
        case .messageConstraintViolation(let identity, let message):
            return "Message constraint violation: \(identity)"
        }
    }

}
