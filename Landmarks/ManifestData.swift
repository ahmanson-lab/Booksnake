//
//  ImageTest.swift
//  Landmarks
//
//  Created by Christy Ye on 10/8/20.
//  Copyright © 2021 University of Southern California. All rights reserved.
//

import Foundation
import UIKit

public struct ManifestData {
    var label: String = ""
    var image: UIImage?
    var width: Float?
    var height: Float?
    var labels: [String]?
    var values: [String]?
    var metadata: Metadata?
}

struct ManifestDataHandler {
    public static func getRemoteManifest(from urlString: String) -> ManifestData? {
        // TODO: Need to make this async code, or the data download may failed
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let jsonData = jsonObject as? [String: Any] else { return nil }

        return parseJson(dictionary: jsonData)
    }

    public static func getLocalManifest(from resrouceName: String) -> ManifestData? {
        guard let url = Bundle.main.url(forResource: resrouceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
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

//        for i in 0...(manifest_data.count) - 1 {
//            let canvas = test_manifest?.sequences?[0].canvases[i]
//            let annotation  = canvas?.images
//            let path = annotation?[0].resource.id ?? ""
//            self.image = (downloadImage(path:path))

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
