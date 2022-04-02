//
//  CollectionData.swift
//  Landmarks
//
//  Created by Henry Huang on 3/31/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//

import Foundation
import Zip
import CoreData

// SharingZip Structure
/*
 myCollection.zip
 - meta.json
 - labelName1.json (iiif files)
 - labelName2.json (iiif files)
 */

enum DataExportError: Error {
    case cannotCreateMetaFile
    case cannotCreateZipFile
    case zipOperationError
    case cannotOpenArchiveFolder
    case cannotReadMetaFile
    case cannotCreateFetchRequest
}

struct DataExportHandler {
    static func prepareArchive(itemCollection: ItemCollection) async throws -> URL {
        // Cleanup cache folder and prepare cacheDir
        FileHandler.clean(directory: .archiveCache)

        // Encode ItemCollection
        let collectionMetaData = try JSONEncoder().encode(itemCollection)
        guard let collectionMetaFileURL = FileHandler.save(data: collectionMetaData, toDirectory: .archiveCache, withFileName: "meta.json") else {
            throw DataExportError.cannotCreateMetaFile
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
        guard let zipFileURL = FileDirectory.archiveCache.url?.appendingPathComponent("\(itemCollection.title).zip") else {
            throw DataExportError.cannotCreateZipFile
        }
        try await zipFiles(paths: [collectionMetaFileURL] + iiifFileURLs, zipFilePath: zipFileURL)

        return zipFileURL
    }

    static func importArchive(archiveURL: URL, managedObjectContext: NSManagedObjectContext) async throws -> ItemCollection {
        let collectionName = archiveURL.deletingPathExtension().lastPathComponent
        guard let archiveCacheDirectory = FileDirectory.archiveCache.url?.appendingPathComponent(collectionName),
              let iiifArchiveDirectory = FileDirectory.iiifArchive.url else {
            throw DataExportError.cannotOpenArchiveFolder
        }

        // Unzip archive
        try await unzipFile(archiveURL, destination: archiveCacheDirectory)

        // Retrieve meta json file
        guard let metaCollectionData = FileHandler.read(from: .archiveCache, fileName: "meta.json") else {
            throw DataExportError.cannotReadMetaFile
        }
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = managedObjectContext
        let itemCollection = try decoder.decode(ItemCollection.self, from: metaCollectionData)

        // Prepare DB fetchRequest
        guard let fetchRequest = Manifest.fetchRequest() as? NSFetchRequest<Manifest> else {
            throw DataExportError.cannotCreateFetchRequest
        }
        fetchRequest.fetchLimit = 1

        // Retrieve Manifest json files
        let archiveCacheFileNames = try FileManager.default.contentsOfDirectory(atPath: archiveCacheDirectory.path)
        for fileName in archiveCacheFileNames {
            guard fileName != "meta.json" else { continue }

            // Check if Manifest exist in DB
            let manifestItemName = (fileName as NSString).deletingPathExtension
            fetchRequest.predicate = NSPredicate(format: "itemLabel LIKE[cd] %@", manifestItemName)
            if let existedManifest = try managedObjectContext.fetch(fetchRequest).first {
                itemCollection.addToItems(existedManifest)
            } else {
                // Copy IIIF files into iiifArchiveDirectory
                let sourcePath = "\(archiveCacheDirectory.path)/\(fileName)"
                let destinationPath = "\(iiifArchiveDirectory.path)/\(fileName)"
                if !FileManager.default.fileExists(atPath: destinationPath) {
                    try FileManager.default.moveItem(atPath: sourcePath, toPath: destinationPath)
                }

                // Parse IIIF Json
                guard let destinationURL = URL(string: destinationPath),
                      let (new_item, _) = await ManifestDataHandler.getLocalManifest(from: destinationURL) else { continue }

                // Create ManifestItem
                let manifestItem = ManifestItem(item: new_item, image: new_item.image!)

                // Save ItemIntoDB
                let manifest = ManifestDataHandler.saveManifestInDB(with: manifestItem, managedObjectContext: managedObjectContext)

                itemCollection.addToItems(manifest)
            }
        }

        return itemCollection
    }


    private static func zipFiles(paths: [URL], zipFilePath: URL) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try Zip.zipFiles(paths: paths, zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                    if progress == 1.0 {
                        continuation.resume()
                    }
                })
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private static func unzipFile(_ zipFilePath: URL, destination: URL) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try Zip.unzipFile(zipFilePath, destination: destination, overwrite: true, password: nil, progress: { (progress) -> () in
                    if progress == 1.0 {
                        continuation.resume()
                    }
                })
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
