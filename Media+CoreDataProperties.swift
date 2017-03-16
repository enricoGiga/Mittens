//
//  Media+CoreDataProperties.swift
//  Mittens
//
//  Created by enrico  gigante on 08/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData


extension Media {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media");
    }

    @NSManaged public var data: NSData?
    @NSManaged public var fileUrl: String?
    @NSManaged public var message: Message?

}
