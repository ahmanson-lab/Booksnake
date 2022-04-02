//
//  CollectionData.swift
//  Landmarks
//
//  Created by Henry Huang on 3/31/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import Foundation
import Zip

// SharingZip Structure
/*
 myCollection.zip
 - meta.json
 - id1.json (iiif files)
 - id2.json (iiif files)
 */

//struct ItemCollectionSharingData: Codable {
//    init(title: String, subtitle: String, author: String, detail: String, createdDate: Date, itemsName: [ManifestSharingData]) {
//        self.title = title
//        self.subtitle = subtitle
//        self.author = author
//        self.detail = detail
//        self.createdDate = createdDate
//        self.itemsName = itemsName
//    }
//
//    let title: String
//    let subtitle: String
//    let author: String
//    let detail: String
//    let createdDate: Date
//    let itemsName: [ManifestSharingData]
//}
//
//struct ManifestSharingData: Codable {
//    init(id: UUID, labels: [String]?, values: [String]?, itemLabel: String?, imageFileName: String, createdDate: Date, width: Float, length: Float) {
//        self.id = id
//        self.labels = labels
//        self.values = values
//        self.itemLabel = itemLabel
//        self.imageFileName = imageFileName
//        self.createdDate = createdDate
//        self.width = width
//        self.length = length
//    }
//
//    let id: UUID
//    let labels: [String]?
//    let values: [String]?
//    let itemLabel: String?
//    let imageFileName: String
//    let createdDate: Date
//    let width: Float
//    let length: Float
//}

enum DataExportError: Error {
    case metaFileCreationError
    case zipFileCreationError
    case zipOperationError
}

struct DataExportHandler {
    static func prepareArchive(itemCollection: ItemCollection) async throws -> URL {
        // Encode ItemCollection
        let collectionMetaData = try JSONEncoder().encode(itemCollection)
        guard let collectionMetaFileURL = FileHandler.save(data: collectionMetaData, toDirectory: .archiveCache, withFileName: "\(itemCollection.title).json") else {
            throw DataExportError.metaFileCreationError
        }

        // Prepare iiif files
        var iiifFileURLs = [URL]()
        if let itemArray = itemCollection.items?.array as? [Manifest] {
            itemArray
                .compactMap { $0.fileURL }
                .filter { FileManager.default.fileExists(atPath: $0.path) }
                .forEach { iiifFileURLs.append($0) }
        }

        // Archive mata and images
        return try await withCheckedThrowingContinuation { continuation in
            guard let zipFileURL = FileDirectory.archiveCache.url?.appendingPathComponent("\(itemCollection.title).zip") else {
                continuation.resume(throwing: DataExportError.zipFileCreationError)
                return
            }

            do {
                try Zip.zipFiles(paths: [collectionMetaFileURL] + iiifFileURLs, zipFilePath: zipFileURL, password: nil, progress: { (progress) -> () in
                    if progress == 1.0 {
                        continuation.resume(returning: zipFileURL)
                    }
                })
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    static func importArchive(data: Data) async throws -> ItemCollection {
        
    }
}
