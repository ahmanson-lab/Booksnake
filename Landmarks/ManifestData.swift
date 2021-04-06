//
//  ImageTest.swift
//  Landmarks
//
//  Created by Christy Ye on 10/8/20.
//  Copyright © 2020 Sean Fraga. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class ManifestData: ValueTransformer {
    
    var label: String = ""
    var image: UIImage?
    
    var labels: [String]?
    var values: [String]?
    var metadata: Metadata?
    
    var curr_json: Any?
    
    public static var supportsSecureCoding: Bool = true
   // public var downloadProgress: CGFloat = 0.0
    
    public func getRemoteManifest(resource_name: String) -> Bool{
       
        fetchData(resource_path: resource_name)

        return parseJson()
    }
    
    public func getLocalManifest(resource_name: String) -> Bool{
        let url = Bundle.main.url(forResource: resource_name, withExtension: "json")
        guard let jsonData = url else {return false}
        guard let data = try? Data(contentsOf: jsonData) else { return false}
        curr_json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        return parseJson()
    }

    public func parseJson() -> Bool {
        
        if let dictionary = curr_json as? [String: Any] {
            
            let test_manifest = IIIFManifest(dictionary)
            
            if let manifest_data = test_manifest?.sequences?[0].canvases {
                
                if let label = dictionary["label"] as? String{
                    self.label = label
                }
                
                for i in 0...(manifest_data.count) - 1 {
                    let canvas = test_manifest?.sequences?[0].canvases[i]
                    let annotation  = canvas?.images
                    let path = annotation?[0].resource.id ?? ""
                    self.image = (downloadImage(path:path))
                    
                    if let metadata = test_manifest?.metadata {
                        self.metadata = metadata
                        
                        var l = [String]()
                        var v = [String]()
                        
                        //add the title of content
                        l.append("Title")
                        v.append(self.label)
                        
                        for j in metadata.items {

                            if !(j.getLabel(forLanguage: "English")!.contains("Citation") || j.getLabel(forLanguage: "English")!.contains("item Url")){
                                l.append(j.getLabel(forLanguage: "English")!)
                                v.append(j.getValue(forLanguage: "English")!)
                            }
                        }
                        
                        self.labels = l
                        self.values = v
                    }
                }
                return true
            }
        }
        return false
    }

    func downloadImage(path:String) -> UIImage {
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
    
    /* Load a URL to get a json file
     1. test library of congress https://www.loc.gov/item/2009579466/manifest.json
     2. test library of congress webpage https://www.loc.gov/item/2009579466
     */
    func fetchData(resource_path: String){
        
        let url = URL(string: resource_path)!
       
        guard let data = try? Data(contentsOf: url) else { return }
        curr_json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
}
