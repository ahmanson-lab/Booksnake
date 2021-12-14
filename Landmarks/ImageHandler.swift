//
//  ImageHandler.swift
//  Landmarks
//
//  Created by Henry Huang on 12/14/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

extension UIImage {
    static func resizedImage(at url: URL?, for size: CGSize) -> UIImage? {
        guard let url = url else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
        ]
        
        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else {
            return nil
        }
        
        return UIImage(cgImage: image)
    }
}
