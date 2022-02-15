//
//  ItemCollection+CoreDataProperties.swift
//  Landmarks
//
//  Created by Henry Huang on 2/15/22.
//  Copyright © 2022 University of Southern California. All rights reserved.
//
//

import Foundation
import CoreData

// MARK: Generated accessors for items
extension ItemCollection {

    @objc(insertObject:inItemsAtIndex:)
    @NSManaged public func insertIntoItems(_ value: Manifest, at idx: Int)

    @objc(removeObjectFromItemsAtIndex:)
    @NSManaged public func removeFromItems(at idx: Int)

    @objc(insertItems:atIndexes:)
    @NSManaged public func insertIntoItems(_ values: [Manifest], at indexes: NSIndexSet)

    @objc(removeItemsAtIndexes:)
    @NSManaged public func removeFromItems(at indexes: NSIndexSet)

    @objc(replaceObjectInItemsAtIndex:withObject:)
    @NSManaged public func replaceItems(at idx: Int, with value: Manifest)

    @objc(replaceItemsAtIndexes:withItems:)
    @NSManaged public func replaceItems(at indexes: NSIndexSet, with values: [Manifest])

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Manifest)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Manifest)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSOrderedSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSOrderedSet)

}
