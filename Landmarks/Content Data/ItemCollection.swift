//
//  Collection.swift
//  Landmarks
//
//  Created by Henry Huang on 2/10/22.
//  Copyright © University of Southern California. All rights reserved.
//

import Foundation
import CoreData

public class ItemCollection: NSManagedObject, Identifiable {
    @NSManaged public var title: String?
    @NSManaged public var subtitle: String?
    @NSManaged public var author: String?
    @NSManaged public var detail: String?
    @NSManaged public var createdDate: Date
    @NSManaged public var items: NSOrderedSet?
}

extension ItemCollection {
    static func sortedFetchRequest() -> NSFetchRequest<ItemCollection> {
        let request = ItemCollection.fetchRequest() as! NSFetchRequest<ItemCollection>

        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemCollection.createdDate, ascending: true)]

        return request
    }
}
