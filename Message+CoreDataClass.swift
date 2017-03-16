//
//  Message+CoreDataClass.swift
//  Mittens
//
//  Created by enrico  gigante on 29/08/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData


public class Message: NSManagedObject {
    static func  messageExisting (timestamp : NSDate, inConctext context: NSManagedObjectContext) -> Message? {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp = %@", timestamp)
        do {
            let results = try context.fetch(request)
                return results.first
                
        }catch {
            print ("error fetching")
        }
        return nil
    }
    static func createNewMessage (text: String?, timestamp: NSDate?, media: Media?,sender: Contact?, context: NSManagedObjectContext, chat: Chat){
        guard let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context)as? Message else {return}
        message.media = media
        message.sender = sender
        message.text = text
        message.timestamp = timestamp
        message.chat = chat
        do {
            try context.save()
        }catch {
            print ("error saving massage")
        }
    }
}
