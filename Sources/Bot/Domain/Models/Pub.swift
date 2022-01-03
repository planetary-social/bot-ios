//
//  File.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

struct Pub: ContentCodable {
    let type: ContentType

    struct Address: Codable {
        let key: String
        let host: String
        let port: UInt

        var multipeer: String {
            return "net:\(self.host):\(self.port)~shs:\(self.key.id)"
        }

        func toPeer() -> Peer {
            return Peer(tcpAddr: "\(self.host):\(self.port)", pubKey: self.key)
        }
    }

    let address: Pub.Address
}


