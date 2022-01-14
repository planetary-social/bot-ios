//
//  NotificationCenter+Bot.swift
//  
//
//  Created by Martin Dutra on 11/1/22.
//

import Foundation

extension NotificationCenter {

    func postDidBlockUser(identity: Identity) {
        post(name: Notification.Name("didBlockUser"), object: identity)
    }

    func postDidSync() {
        post(name: Notification.Name("didSync"), object: nil)
    }

    func postDidRefresh() {
        post(name: Notification.Name("didRefresh"), object: nil)
    }

    func postDidStartFSCKRepair() {
        post(name: Notification.Name("didStartFSCKRepair"), object: nil)
    }

    func postDidFinishFSCKRepair() {
        post(name: Notification.Name("didFinishFSCKRepair"), object: nil)
    }

    func postDidUpdateFSCKRepair(percent: Float64, remaining: String) {
        let status = "Database consistency check in progress.\nSorry, this will take a moment.\nTime remaining: \(remaining)"
        post(name: Notification.Name("didUpdateFSCKRepair"),
             object: nil,
             userInfo: ["percentage_done": percent, "status": status])
    }

    func postDidLoadBlob(identifier: BlobIdentifier) {
        post(name: Notification.Name("didLoadBlob"), object: nil, userInfo: ["blobIdentifier": identifier])
    }

}
