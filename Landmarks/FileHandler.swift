//
//  FileHandler.swift
//  Landmarks
//
//  Created by Henry Huang on 12/14/21.
//  Copyright © 2021 Sean Fraga. All rights reserved.
//

import Foundation

struct FileHandler {
    private static var documentDirectoryPath: String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }

    static var imageDirectoryURL: URL? {
        let imageDir = URL(fileURLWithPath: Self.documentDirectoryPath).appendingPathComponent("Images")

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

    static func read(from directoryURL: URL, fileName: String) -> Data? {
        let fileURL = directoryURL.appendingPathComponent(fileName)

        do {
            let savedFile = try Data(contentsOf: fileURL)

            print("File saved at \(fileURL)")

            return savedFile
        } catch {
            print("Error reading saved file")
            return nil
        }
    }

    static func save(data: Data, toDirectory directory: URL, withFileName fileName: String) -> URL? {
        let fileURL = directory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL, options: .noFileProtection)
        } catch {
            print("Error", error)
            return nil
        }

        return fileURL
    }
}
