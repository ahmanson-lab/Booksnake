//
//  ContentData+Extension.swift
//  Landmarks
//
//  Created by Christy Ye on 12/10/20.
//  Copyright © 2021 University of Southern California. All rights reserved.
//

import Foundation
import CoreData

public class Manifest: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var labels: [String]?
    @NSManaged public var values: [String]?
    @NSManaged public var itemLabel: String?
    @NSManaged public var imageFileName: String
    @NSManaged public var createdDate: Date
    @NSManaged public var collections: NSSet
    
    //for init sizes
    @NSManaged public var width: Float
    @NSManaged public var length: Float
}

extension Manifest {
    var imageURL: URL? {
        return FileDirectory.image.url?.appendingPathComponent(imageFileName)
    }

    static func sortedFetchRequest() -> NSFetchRequest<Manifest> {
        let request = Manifest.fetchRequest() as! NSFetchRequest<Manifest>
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Manifest.createdDate, ascending: true)]
          
        return request
    }
}
