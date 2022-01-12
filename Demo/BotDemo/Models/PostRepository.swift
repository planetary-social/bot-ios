//
//  PostRepository.swift
//  BotDemo
//
//  Created by Martin Dutra on 3/1/22.
//

import Foundation
import Bot
import UIKit

class PostRepository: ObservableObject {

    static var shared = PostRepository()

    @Published var posts: [Post]

    init() {
        self.posts = []
    }

    init(posts: [Post]) {
        self.posts = posts
    }

    init(filename: String) {
        guard let asset = NSDataAsset(name: filename) else {
            fatalError("Couldn't find \(filename) in assets.")
        }

        do {
            let decoder = JSONDecoder()
            self.posts = try decoder.decode([Post].self, from: asset.data)
        } catch {
            fatalError("Couldn't parse \(filename) as \([Post].self):\n\(error)")
        }
    }

    func didTapButton() {
        update {
            
        }
    }

    func update(completionHandler: @escaping (() -> Void)) {
        BBot.shared.everyone { keyValues in
            let posts = keyValues.map { Post(keyValue: $0) }
            DispatchQueue.main.async {
                self.posts = posts
                completionHandler()
            }
        }
    }

}
