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

enum ImageThumbnailSize {
    case small
    case medium

    var cgSize: CGSize {
        switch self {
        case .small:
            return CGSize(width: 150.0, height: 150.0)
        case .medium:
            return CGSize(width: 750.0, height: 750.0)
        }
    }
}

extension UIImage {
    static func getThumbnail(at url: URL?, for size: ImageThumbnailSize) -> UIImage? {
        guard let url = url else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.cgSize.width, size.cgSize.height)
        ]
        
        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else {
            return nil
        }
        
        return UIImage(cgImage: image)
    }
}
