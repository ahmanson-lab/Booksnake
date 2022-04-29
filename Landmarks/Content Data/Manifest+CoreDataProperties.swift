//
//  Manifest+CoreDataProperties.swift
//  Landmarks
//
//  Created by Henry Huang on 2/15/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//
//

import Foundation
import CoreData

// MARK: Generated accessors for collections
extension Manifest {

    @objc(addCollectionsObject:)
    @NSManaged public func addToCollections(_ value: ItemCollection)

    @objc(removeCollectionsObject:)
    @NSManaged public func removeFromCollections(_ value: ItemCollection)

    @objc(addCollections:)
    @NSManaged public func addToCollections(_ values: NSSet)

    @objc(removeCollections:)
    @NSManaged public func removeFromCollections(_ values: NSSet)

}
