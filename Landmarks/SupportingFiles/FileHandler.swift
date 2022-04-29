//
//  FileHandler.swift
//  Landmarks
//
//  Created by Henry Huang on 12/14/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import Foundation

enum FileDirectory: String {
    case image
    case iiifArchive
    case imageCache
    case archiveCache

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
        case .iiifArchive:
            let iiifDir = URL(fileURLWithPath: FileHandler.documentDirectoryPath).appendingPathComponent("iiif")

            if !FileManager.default.fileExists(atPath: iiifDir.path) {
                do {
                    try FileManager.default.createDirectory(at: iiifDir,
                                                            withIntermediateDirectories: true,
                                                            attributes: [FileAttributeKey.protectionKey: FileProtectionType.none])
                } catch {
                    print("Can't create iiif folder.")
                    return nil
                }
            }

            return iiifDir
        case .imageCache:
            let imageCacheDir = URL(fileURLWithPath: FileHandler.cachesDirectoryPath).appendingPathComponent("ImageCaches")

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
        case .archiveCache:
            let archiveCacheDir = URL(fileURLWithPath: FileHandler.cachesDirectoryPath).appendingPathComponent("ArchiveCaches")

            if !FileManager.default.fileExists(atPath: archiveCacheDir.path) {
                do {
                    try FileManager.default.createDirectory(at: archiveCacheDir,
                                                            withIntermediateDirectories: true,
                                                            attributes: [FileAttributeKey.protectionKey: FileProtectionType.none])
                } catch {
                    print("Can't create archiveCache folder.")
                    return nil
                }
            }

            return archiveCacheDir
        }
    }
}

struct FileHandler {
    static var cachesDirectoryPath: String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
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

    static func clean(directory: FileDirectory) {
        guard let directoryURL = directory.url,
              FileManager.default.fileExists(atPath: directoryURL.path) else {
            return
        }

        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: directoryURL.path)

            for fileName in fileNames {
                try FileManager.default.removeItem(atPath: "\(directoryURL.path)/\(fileName)")
            }
        } catch {
            print("Could not clean up directory \(directory.self): \(error)")
        }
    }
}
