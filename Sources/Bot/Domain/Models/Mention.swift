//
//  Mention.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct Mention {

    public let link: LinkIdentifier
    public let name: String?

    public var identity: Identifier {
        return self.link
    }

    // optional
    public let size: Int? // filesize in bytes
    public let width: Int?
    public let height: Int?
    public let type: String?


    // just for hashtags
//    init(link: String) {
//        self.link = link
//
//        // empty
//        self.name = nil
//        self.size = nil
//        self.width = nil
//        self.height = nil
//        self.type = nil
//    }

    public init(link: String, name: String? = nil , metadata: Blob.Metadata? = nil) {
        self.link = link
        self.name = name

        if let m = metadata {
            self.size = m.numberOfBytes
            self.width = m.dimensions?.width
            self.height = m.dimensions?.height
            self.type = m.mimeType
        } else {
            self.size = nil
            self.width = nil
            self.height = nil
            self.type = nil
        }
    }
    
}

extension Mention: Codable {

}

extension Mention: Markdownable {

    public var markdown: String {
        guard let name = self.name else { return "" }
        return "[\(name)](\(self.link))"
    }
}

public typealias Mentions = [Mention]

public extension Mentions {

    func identities() -> [String] {
        return self.map { $0.identity }
    }

    func markdowns() -> [String] {
        return self.map { $0.markdown }
    }
}

public extension Mentions {
    func asBlobs() -> Blobs {
        return self.filter {
            return $0.link.isBlob
        }.map {
            var dims:Blob.Metadata.Dimensions? = nil
            let w = $0.width ?? 0
            let h = $0.height ?? 0
            if w != 0 && h != 0 {
                dims = Blob.Metadata.Dimensions(width: w, height: h)
            }
            let meta = Blob.Metadata(averageColorRGB: nil, dimensions: dims, mimeType: $0.type, numberOfBytes: $0.size)
            return Blob(identifier: $0.link, name: $0.name, metadata: meta)
        }
    }
}

