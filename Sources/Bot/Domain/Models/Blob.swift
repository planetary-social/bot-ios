//
//  Blob.swift
//  
//
//  Created by Martin Dutra on 26/12/21.
//

import Foundation

public struct Blob: Codable {

    public let identifier: String
    public let name: String?

    public struct Metadata: Codable {

        public struct Dimensions: Codable {
            public var width: Int
            public var height: Int

            public init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }
        }
        
        public let averageColorRGB: Int?
        public let dimensions: Dimensions?
        public let mimeType: String?
        public let numberOfBytes: Int?

        public init(averageColorRGB: Int?, dimensions: Blob.Metadata.Dimensions?, mimeType: String?, numberOfBytes: Int?) {
            self.averageColorRGB = averageColorRGB
            self.dimensions = dimensions
            self.mimeType = mimeType
            self.numberOfBytes = numberOfBytes
        }
    }
    public let metadata: Metadata?

    public init(identifier: String, name: String? = nil, metadata: Metadata? = nil) {
        self.identifier = identifier
        self.name = name
        self.metadata = metadata
    }
}

public typealias Blobs = [Blob]

public extension Blob {
    func asMention() -> Mention {
        return Mention(link: self.identifier, name: self.name, metadata: self.metadata)
    }
}

public extension Blobs {
    func asMentions() -> Mentions {
        return self.map {
            return $0.asMention()
        }
    }
}
