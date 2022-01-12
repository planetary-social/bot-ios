//
//  SSBError.swift
//  
//
//  Created by Martin Dutra on 5/1/22.
//

import Foundation

enum SSBError: Error {
    case alreadyStarted
    case duringProcessing(String, Error)
    case unexpectedFault(String)
}

extension SSBError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .alreadyStarted:
            return "Already started"
        case .duringProcessing(let string, let error):
            return "\(string): \(error.localizedDescription)"
        case .unexpectedFault(let string):
            return "Unexpected fault: \(string)"
        }
    }

}
