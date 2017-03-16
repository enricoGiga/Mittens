//
//  Contact+CoreDataClass.swift
//  Mittens
//
//  Created by enrico  gigante on 01/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData


public class Contact: NSManagedObject {
    static func  isContactExisting( withId id: String, inContext context: NSManagedObjectContext) -> Contact? {
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        do {
            let results = try context.fetch(request)
            return results.first
            
        }catch {
            print ("error fetching")
        }
        return nil
    }
    
    static func saveAndReturnNewContact( withId id: String, withDisplayName displayName: String?, withProfilePhoto profilePhoto: NSData? ,chat: Chat?,  inContext context: NSManagedObjectContext) -> Contact? {
        guard let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact",into: context)as? Contact else {return nil}
        context.performAndWait {
            
            contact.displayName = displayName
            contact.id = id
            contact.profilePhoto = profilePhoto
            guard let chat = chat else {return}
            contact.addToChats(chat)
            do {
                try context.save()
                
            } catch {
                print ("Error saving")
            }
        }
        
        return contact
        
    }
}
