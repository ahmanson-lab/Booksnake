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

enum ImageThumbnailSize: String {
    case small = "small"
    case medium = "medium"

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
    static func loadThumbnail(at url: URL?, forSize size: ImageThumbnailSize) -> UIImage? {
        guard let url = url else { return nil }
        
        if let cachedImage = loadFromCache(at: url, forSize: size) {
            return cachedImage
        }

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
        
        let uiImage = UIImage(cgImage: image)
        cache(thumbnail: uiImage, at: url, forSize: size)
        
        return uiImage
    }
    
    private static func cache(thumbnail: UIImage, at url: URL, forSize size: ImageThumbnailSize) {
        guard let originalFilename = URL(string: url.lastPathComponent) else {
            return
        }
        
        let filename = originalFilename.appendingPathExtension(size.rawValue)
        FileHandler.save(data: thumbnail.jpegData(compressionQuality: 1.0) ?? Data(),
                         toDirectory: .imageCache,
                         withFileName: filename.lastPathComponent)
    }
    
    private static func loadFromCache(at url: URL, forSize size: ImageThumbnailSize) -> UIImage? {
        guard let originalFilename = URL(string: url.lastPathComponent) else {
            return nil
        }
        
        let filename = originalFilename.appendingPathExtension(size.rawValue)
        guard let data = FileHandler.read(from: .imageCache, fileName: filename.lastPathComponent) else {
            return nil
        }
        
        return UIImage(data: data)
    }
}
