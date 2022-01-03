//
//  BotServiceAdapter.swift
//  
//
//  Created by Martin Dutra on 28/12/21.
//

import Foundation

class BotServiceAdapter: BotService {

    var api: APIService

    init(api: APIService) {
        self.api = api
    }

    func everyone(completion: @escaping (([KeyValue]) -> Void)) {
        api.everyone { keyValues, _ in
            completion(keyValues)
        }
    }
    
}
