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
	
    //public static var supportsSecureCoding: Bool = true
	let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
	let userDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
}

struct ManifestDataHandler {
    public static func addNewManifest(from urlPath: String,
                                      width: Float = 1,
                                      length: Float = 1,
                                      managedObjectContext: NSManagedObjectContext,
                                      completion: (Result<String, ManifestDataErorr>) -> Void) {
        guard let new_item = ManifestDataHandler.getRemoteManifest(from: urlPath) else {
            completion(.failure(.remoteFetchError))
            return
        }

        print("Adding Remote Manifest")

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

        completion(.success(new_manifest.item.label))
    }

    private static func getRemoteManifest(from urlString: String) -> ManifestData? {
        // TODO: Need to make this async code, or the data download may failed
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let jsonData = jsonObject as? [String: Any] else { return nil }

        return parseJson(dictionary: jsonData)
    }
	
    private static func parseJson(dictionary: [String: Any]) -> ManifestData? {
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
        manifestData.image = (downloadImage(path:path))

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

    private static func downloadImage(path:String) -> UIImage {
        var image = UIImage()
        do {
            let url = URL.init(string: path)!
            let data = try Data(contentsOf: url)
            image = UIImage(data: data) ?? UIImage()
        }
        catch {
            print ("cannot find image")
        }
        return image
    }
}

// MARK: - FOR DEMO ONLY: add hard coded values from local manifests and images
extension ManifestDataHandler {
    public static func addExamples(managedObjectContext: NSManagedObjectContext) {
        let resource_paths = ["MapOfCalifornia", "MapOfLosAngeles", "TopographicLA", "LA1909", "AutomobileLA", "Hollywood"]
        let sizes = [[0.48, 0.69], [0.63, 0.56],[1.53, 0.56],[0.85, 1.02],[0.22, 0.08],[0.67, 0.66]]

        for index in 0..<resource_paths.count {
            if let new_item = ManifestDataHandler.getLocalManifest(from: resource_paths[index]) {
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

                do {
                    try managedObjectContext.save()
                }
                catch {
                    print(error)
                }
            }
        }
    }

    private static func getLocalManifest(from resrouceName: String) -> ManifestData? {
        guard let url = Bundle.main.url(forResource: resrouceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonData = jsonObject as? [String: Any] else { return nil }

        return parseJson(dictionary: jsonData)
    }
}
