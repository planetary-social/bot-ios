//
//  BBot.swift
//
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public class BBot {

    public static var shared = BBot(service: BotServiceAdapter(api: ModeratorService()))
    var service: BotService

    init(service: BotService) {
        self.service = service
    }

    public func everyone(completion: @escaping (([BBot.Post]) -> Void)) {
        service.everyone { keyValues in
            let posts = keyValues.map { keyValue -> BBot.Post in
                let builder = PostBuilder()
                return builder.build(keyValue: keyValue)
            }
            completion(posts)
        }
    }

}
