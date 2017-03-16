//
//  Chat+CoreDataProperties.swift
//  Mittens
//
//  Created by enrico  gigante on 09/10/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData


extension Chat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chat> {
        return NSFetchRequest<Chat>(entityName: "Chat");
    }

    @NSManaged public var hashtagID: String?
    @NSManaged public var isMyChat: Bool
    @NSManaged public var lastMessage: NSDate?
    @NSManaged public var nameChat: String?
    @NSManaged public var photoChat: NSData?
    @NSManaged public var userID: String?
    @NSManaged public var contacts: NSSet?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for contacts
extension Chat {

    @objc(addContactsObject:)
    @NSManaged public func addToContacts(_ value: Contact)

    @objc(removeContactsObject:)
    @NSManaged public func removeFromContacts(_ value: Contact)

    @objc(addContacts:)
    @NSManaged public func addToContacts(_ values: NSSet)

    @objc(removeContacts:)
    @NSManaged public func removeFromContacts(_ values: NSSet)

}

// MARK: Generated accessors for messages
extension Chat {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
