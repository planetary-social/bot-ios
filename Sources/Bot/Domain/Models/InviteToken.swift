//
//  InviteToken.swift
//  
//
//  Created by Martin Dutra on 11/1/22.
//

import Foundation

public class InviteToken {

    public var rawValue: String

    private(set) var feed: Identifier = Identifier.null
    private(set) var host: String = ""
    private(set) var port: UInt = 0

    var tcpAddress: String {
        return "\(host):\(port)"
    }

    var address: Pub.Address {
        return Pub.Address(key: self.feed, host: self.host, port: self.port)
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue

        // Parse Feed Identity and TCP Addreess out of the invite
        let range = NSRange(location: 0, length: rawValue.utf16.count)
        guard let regex = try? NSRegularExpression(pattern: "(.*):([0-9]*):(.*)~.*") else {
            return
        }
        do {
            let match = regex.firstMatch(in: rawValue, options: [], range: range)!
            let hostRange = Range(match.range(at: 1), in: rawValue)!
            self.host = String(rawValue[hostRange])
            let portRange = Range(match.range(at: 2), in: rawValue)!
            self.port = UInt(rawValue[portRange])!
            let feedRange = Range(match.range(at: 3), in: rawValue)!
            self.feed = String(rawValue[feedRange])
        } catch {
            return
        }
    }


}
