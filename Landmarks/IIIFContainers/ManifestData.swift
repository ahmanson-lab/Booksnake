//
//  ImageTest.swift
//  Landmarks
//
//  Created by Christy Ye on 10/8/20.
//  Copyright © 2021 University of Southern California. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum ManifestDataErorr: Error {
    case remoteFetchError
}

public struct ManifestData {
    var label: String = ""
    var image: UIImage?
    var width: Float?
    var height: Float?
    var labels: [String]?
    var values: [String]?
    var metadata: Metadata?
}

//don't use this struct in view
struct ManifestItem: Identifiable {
    let id = UUID()
    let item: ManifestData
    let image: UIImage
}

struct ManifestDataHandler {
    public static func addNewManifest(from urlPath: String,
                                      width: Float = 1,
                                      length: Float = 1,
                                      managedObjectContext: NSManagedObjectContext) async -> Result<String, ManifestDataErorr> {
        guard let new_item = await ManifestDataHandler.getRemoteManifest(from: urlPath) else {
            return .failure(.remoteFetchError)
        }

        print("adding remote manifest")

        let new_manifest = ManifestItem(item: new_item, image: new_item.image!)

        let contentdata = NSEntityDescription.insertNewObject(forEntityName: "Manifest", into: managedObjectContext) as! Manifest
        contentdata.id = new_manifest.id
        contentdata.labels = new_manifest.item.labels
        contentdata.itemLabel = new_manifest.item.label
        contentdata.values = new_manifest.item.values
        contentdata.width = new_manifest.item.width ?? width
        contentdata.length = new_manifest.item.height ?? length
        contentdata.createdDate = Date()
        FileHandler.save(data: new_manifest.image.jpegData(compressionQuality: 1.0) ?? Data(),
                         toDirectory: .image,
                         withFileName: "\(new_manifest.id).jpg")
        contentdata.imageFileName = "\(new_manifest.id).jpg"

        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }

        return .success(new_manifest.item.label)
    }

    private static func getRemoteManifest(from urlString: String) async -> ManifestData? {
        guard let url = URL(string: urlString) else { return nil }

        let request = URLRequest(url: url)
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let jsonData = jsonObject as? [String: Any] else { return nil }

        return await parseJson(dictionary: jsonData)
    }

    private static func parseJson(dictionary: [String: Any]) async -> ManifestData? {
        var manifestData = ManifestData()
        let resolvedManifest = IIIFManifest(dictionary)

        guard let manifest_data = resolvedManifest?.sequences?[0].canvases,
              !manifest_data.isEmpty else { return nil }

        if let label = dictionary["label"] as? String {
            manifestData.label = label
        }

        let canvas = manifest_data[0]

        // get width and height
        manifestData.width = Float(canvas.width) / 3000
        manifestData.height = Float(canvas.height) / 3000

        let annotation  = canvas.images
        let path = annotation?[0].resource.id ?? ""
        if let imageURL = URL(string: path) {
            manifestData.image = try? await downloadImage(from: imageURL)
        }

        if let metadata = resolvedManifest?.metadata {
            manifestData.metadata = metadata

            var l = [String]()
            var v = [String]()

            //add the title of content
            l.append("Title")
            v.append(manifestData.label)

            for j in metadata.items {

                if !(j.getLabel(forLanguage: "English")!.contains("Citation") || j.getLabel(forLanguage: "English")!.contains("item Url")){
                    l.append(j.getLabel(forLanguage: "English")!)
                    v.append(j.getValue(forLanguage: "English")!)
                }
            }

            manifestData.labels = l
            manifestData.values = v
        } else {
            manifestData.labels = [String]()
            manifestData.values = [String]()
        }

        return manifestData
    }

    private static func downloadImage(from url: URL) async throws -> UIImage? {
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }

        return UIImage(data: data)
    }
}

// MARK: - FOR DEMO ONLY: add hard coded values from local manifests and images
extension ManifestDataHandler {
    public static func addExamples(managedObjectContext: NSManagedObjectContext) async {
        let resource_paths = ["LA1909", "MapOfCalifornia", "MapOfLosAngeles", "TopographicLA", "AutomobileLA", "Hollywood"]
        let sizes = [[0.48, 0.69], [0.63, 0.56],[1.53, 0.56],[0.85, 1.02],[0.22, 0.08],[0.67, 0.66]]

        // ItemCollection
        let collectionData = NSEntityDescription.insertNewObject(forEntityName: "ItemCollection", into: managedObjectContext) as! ItemCollection
        collectionData.title = "Sample List"
        collectionData.subtitle = "This is a sample list"
        collectionData.author = "Booksnake's Team"
        collectionData.detail = ""
        collectionData.createdDate = Date()

        for index in 0..<resource_paths.count {
            if let new_item = await ManifestDataHandler.getLocalManifest(from: resource_paths[index]) {
                let new_manifest = ManifestItem(item:new_item, image: UIImage(named: resource_paths[index])!)
                let contentdata = NSEntityDescription.insertNewObject(forEntityName: "Manifest", into: managedObjectContext) as! Manifest
                contentdata.id = new_manifest.id
                contentdata.labels = new_manifest.item.labels
                contentdata.itemLabel = new_manifest.item.label
                contentdata.values = new_manifest.item.values
                contentdata.width = Float(sizes[index][1])
                contentdata.length = Float (sizes[index][0])
                contentdata.createdDate = Date()
                FileHandler.save(data: new_manifest.image.jpegData(compressionQuality: 1.0) ?? Data(),
                                 toDirectory: .image,
                                 withFileName: "\(new_manifest.id).jpg")
                contentdata.imageFileName = "\(new_manifest.id).jpg"
                contentdata.addToCollections(collectionData)

                do {
                    try managedObjectContext.save()
                }
                catch {
                    print(error)
                }
            }
        }
    }

    private static func getLocalManifest(from resourceName: String) async -> ManifestData? {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonData = jsonObject as? [String: Any] else { return nil }

        return await parseJson(dictionary: jsonData)
    }
}
