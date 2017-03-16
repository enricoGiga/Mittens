//
//  Message+CoreDataProperties.swift
//  Mittens
//
//  Created by enrico  gigante on 08/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }

    @NSManaged public var text: String?
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var chat: Chat?
    @NSManaged public var media: Media?
    @NSManaged public var sender: Contact?

}
