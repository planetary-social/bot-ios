//
//  UIImage+Resize.swift
//  
//
//  Created by Martin Dutra on 12/1/22.
//

import Foundation
import UIKit

// TODO: Check if we can get away without this
extension UIImage {

    /// Returns an image sized to the max specified dimension
    /// while also retaining the original image aspect ratio.
    /// If resizing fails, nil is returned.
    func resized(toLargestDimension dimension: CGFloat) -> UIImage? {
        let max = fmax(self.size.width, self.size.height)
        let scale = dimension / max
        let size = self.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaled = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaled
    }
}
