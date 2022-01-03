//
//  PostRow.swift
//  BotDemo
//
//  Created by Martin Dutra on 30/12/21.
//

import SwiftUI

struct PostRow: View {
    var post: Post

    var body: some View {
        VStack(alignment: .leading) {
            Text(post.author)
            Text(post.content)
        }
    }
}

struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PostRow(post: Post(id: "1",
                               author: "Lucas",
                               content: "My post"))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
