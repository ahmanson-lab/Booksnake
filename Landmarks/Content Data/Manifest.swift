//
//  ContentData+Extension.swift
//  Landmarks
//
//  Created by Christy Ye on 12/10/20.
//  Copyright © 2021 University of Southern California. All rights reserved.
//

import Foundation
import CoreData

public class Manifest: NSManagedObject, Identifiable, Codable {
    @NSManaged public var id: UUID
    @NSManaged public var labels: [String]?
    @NSManaged public var values: [String]?
    @NSManaged public var itemLabel: String
    @NSManaged public var createdDate: Date
    @NSManaged public var collections: NSSet
    
    //for init sizes
    @NSManaged public var width: Float
    @NSManaged public var length: Float

    enum CodingKeys: CodingKey {
        case id, labels, values, itemLabel, createdDate, width, length
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderError.missingManagedObjectContext
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.labels = (try? container.decode([String].self, forKey: .labels)) ?? nil
        self.values = (try? container.decode([String].self, forKey: .values)) ?? nil
        self.itemLabel = try container.decode(String.self, forKey: .itemLabel)
        self.createdDate = try container.decode(Date.self, forKey: .createdDate)
        self.width = try container.decode(Float.self, forKey: .width)
        self.length = try container.decode(Float.self, forKey: .length)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(labels, forKey: .labels)
        try container.encode(values, forKey: .values)
        try container.encode(itemLabel, forKey: .itemLabel)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(width, forKey: .width)
        try container.encode(length, forKey: .length)
    }
}

extension Manifest {
    var imageURL: URL? {
        return FileDirectory.image.url?.appendingPathComponent("\(id).jpg")
    }

    var fileURL: URL? {
        return FileDirectory.iiifArchive.url?.appendingPathComponent("\(itemLabel).json")
    }

    static func sortedFetchRequest() -> NSFetchRequest<Manifest> {
        let request = Manifest.fetchRequest() as! NSFetchRequest<Manifest>
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Manifest.createdDate, ascending: true)]
          
        return request
    }
}
