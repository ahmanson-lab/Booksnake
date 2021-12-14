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
                    print("Can't create Document/Image folder.")
                    return nil
                }
            }

            return imageDir
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
        guard let fileURL = directory.url?.appendingPathComponent(fileName) else { return nil }

        do {
            let savedFile = try Data(contentsOf: fileURL)

            print("File read at \(fileURL)")

            return savedFile
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
