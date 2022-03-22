//
//  FileHandler.swift
//  Landmarks
//
//  Created by Henry Huang on 12/14/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import Foundation

enum FileDirectory {
    case image
    case imageCache

    var url: URL? {
        switch self {
        case .image:
            let imageDir = URL(fileURLWithPath: FileHandler.documentDirectoryPath).appendingPathComponent("Images")

            if !FileManager.default.fileExists(atPath: imageDir.path) {
                do {
                    try FileManager.default.createDirectory(at: imageDir,
                                                            withIntermediateDirectories: true,
                                                            attributes: [FileAttributeKey.protectionKey: FileProtectionType.none])
                } catch {
                    print("Can't create Images folder.")
                    return nil
                }
            }

            return imageDir
        case .imageCache:
            let imageCacheDir = URL(fileURLWithPath: FileHandler.documentDirectoryPath).appendingPathComponent("ImageCaches")

            if !FileManager.default.fileExists(atPath: imageCacheDir.path) {
                do {
                    try FileManager.default.createDirectory(at: imageCacheDir,
                                                            withIntermediateDirectories: true,
                                                            attributes: [FileAttributeKey.protectionKey: FileProtectionType.none])
                } catch {
                    print("Can't create ImageCaches folder.")
                    return nil
                }
            }

            return imageCacheDir
        }
    }
}

struct FileHandler {
    static var documentDirectoryPath: String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }

    @discardableResult
    static func read(from directory: FileDirectory, fileName: String) -> Data? {
        guard let fileURL = directory.url?.appendingPathComponent(fileName),
              FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("Error reading saved file")
            return nil
        }
    }

    @discardableResult
    static func save(data: Data, toDirectory directory: FileDirectory, withFileName fileName: String) -> URL? {
        guard let fileURL = directory.url?.appendingPathComponent(fileName) else { return nil }

        do {
            try data.write(to: fileURL, options: .noFileProtection)
        } catch {
            print("Error", error)
            return nil
        }

        return fileURL
    }
}
