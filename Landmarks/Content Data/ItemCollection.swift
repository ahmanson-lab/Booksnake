//
//  Collection.swift
//  Landmarks
//
//  Created by Henry Huang on 2/10/22.
//  Copyright © University of Southern California. All rights reserved.
//

import Foundation
import CoreData

public class ItemCollection: NSManagedObject, Identifiable, Codable {
    @NSManaged public var title: String
    @NSManaged public var subtitle: String
    @NSManaged public var author: String
    @NSManaged public var detail: String
    @NSManaged public var createdDate: Date
    @NSManaged public var items: NSOrderedSet?

    public var compositeImageURLs: [URL] {
        var urls = [URL]()
        let enumerator = items?.objectEnumerator()

        while let manifest = enumerator?.nextObject() as? Manifest,
            let imageURL = manifest.imageURL {
            guard urls.count < 4 else { break }

            urls.append(imageURL)
        }

        return urls
    }

    enum CodingKeys: CodingKey {
        case title, subtitle, author, detail, createdDate, itemArray
    }

    required convenience public init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.author = try container.decode(String.self, forKey: .author)
        self.detail = try container.decode(String.self, forKey: .detail)
        self.createdDate = try container.decode(Date.self, forKey: .createdDate)

        if let itemArray = try? container.decode([Manifest].self, forKey: .itemArray) {
            self.addToItems(NSOrderedSet(array: itemArray))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(author, forKey: .author)
        try container.encode(detail, forKey: .detail)
        try container.encode(createdDate, forKey: .createdDate)

        if let itemArray = items?.array as? [Manifest] {
            try container.encode(itemArray, forKey: .itemArray)
        }
    }
}

extension ItemCollection {
    static func sortedFetchRequest() -> NSFetchRequest<ItemCollection> {
        let request = ItemCollection.fetchRequest() as! NSFetchRequest<ItemCollection>

        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemCollection.createdDate, ascending: true)]

        return request
    }
}
