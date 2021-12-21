//
//  ContentData+Extension.swift
//  Landmarks
//
//  Created by Christy Ye on 12/10/20.
//  Copyright © 2021 University of Southern California. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// ❇️ BlogIdea code generation is turned OFF in the xcdatamodeld file
public class ContentData: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    //@NSManaged public var item: [String]?
    @NSManaged public var labels: [String]?
    @NSManaged public var values: [String]?
    @NSManaged public var item_label: String?
//	@NSManaged public var image_url: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var index: Int16
    
    //for init sizes
    @NSManaged public var width: Float
    @NSManaged public var length: Float
}

extension ContentData {
    static func allIdeasFetchRequest() -> NSFetchRequest<ContentData> {
        let request: NSFetchRequest<ContentData> = ContentData.fetchRequest() as! NSFetchRequest<ContentData>
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
          
        return request
    }
}
