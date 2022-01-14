//
//  Pub.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct Pub: ContentCodable {

    public let type: ContentType

    public struct Address: Codable {

        public let key: String
        public let host: String
        public let port: UInt

        public init(key: String, host: String, port: UInt) {
            self.key = key
            self.host = host
            self.port = port
        }

        public var multipeer: String {
            return "net:\(self.host):\(self.port)~shs:\(self.key.id)"
        }

//        func toPeer() -> Peer {
//            return Peer(tcpAddr: "\(self.host):\(self.port)", pubKey: self.key)
//        }
    }

    public let address: Pub.Address

    public init(type: ContentType, address: Pub.Address) {
       self.type = type
       self.address = address
    }

}


