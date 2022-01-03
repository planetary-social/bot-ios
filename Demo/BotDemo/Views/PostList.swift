//
//  PostList.swift
//  BotDemo
//
//  Created by Martin Dutra on 30/12/21.
//

import SwiftUI
 
struct PostList: View {
    @ObservedObject var repository = PostRepository.shared
    var body: some View {
        NavigationView {
            List(repository.posts) { post in
                PostRow(post: post)
            }
            .navigationTitle("Posts")
            .toolbar {
                Button("Refresh") {
                    PostRepository.shared.update {

                    }
                }
            }
        }
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        PostList(repository: PostRepository(filename: "Posts"))
    }
}
