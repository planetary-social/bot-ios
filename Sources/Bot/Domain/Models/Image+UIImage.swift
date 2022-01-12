//
//  File.swift
//  
//
//  Created by Martin Dutra on 11/1/22.
//

import Foundation
import UIKit

extension Image {

    // TODO: Check if we can remove this
    init(link: BlobIdentifier, jpegImage: UIImage, data: Data) {
        self.link = link
        self.width = Int(jpegImage.size.width)
        self.height = Int(jpegImage.size.height)
        self.size = data.count
        self.type = MIMEType.jpeg.rawValue
    }
    
}
