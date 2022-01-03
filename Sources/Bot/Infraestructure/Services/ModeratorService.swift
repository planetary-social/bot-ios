//
//  ModeratorService.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation
import Moderator

class ModeratorService: APIService {
    
    func everyone(completion: @escaping (([KeyValue], Error?) -> Void)) {
        Moderator.shared.everyone { posts in
            let keyValues = posts.map { post -> KeyValue in
                let builder = KeyValueBuilder()
                return builder.build(post: post)
            }
            completion(keyValues, nil)
        }
    }

}
