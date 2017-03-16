//
//  Chat+CoreDataClass.swift
//  Mittens
//
//  Created by enrico  gigante on 30/08/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData


public class Chat: NSManagedObject {
    
    var lastMessageTime: Message? {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "chat = %@ AND media == nil", self)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false )]
        request.fetchLimit = 1
        do {
            let results = try self.managedObjectContext?.fetch(request)
            return results?.first
        }catch {
            print("Error")
        }
        return nil
    }
    
    var firtMessageTime: Message? {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "chat = %@ AND media == nil", self)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true )]
        request.fetchLimit = 1
        do {
            let results = try self.managedObjectContext?.fetch(request)
            return results?.first
        }catch {
            print("Error")
        }
        return nil
    }

    static func isThisContactPartecipate (contact: Contact, chat: Chat, inContext context: NSManagedObjectContext) -> Bool{
        let contatti = chat.contacts?.allObjects as? [Contact]
        for i in contatti! {
            if i.id == contact.id! {
                return true
            }
            
         }

        return false
    }
    func addObject(value: NSManagedObject, forKey key: String) {
        let items = self.mutableSetValue(forKey: key)
        items.add(value)
    }
//    func addToContacts (contact: Contact){
//        
//    }
    /**
     * return all Hashtag in Core Data
     */
    static func returnAllMyChats( inContext context: NSManagedObjectContext) -> [Chat]{
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        request.predicate = NSPredicate(format: "isMyChat = true")
        var chats = [Chat]()
        do {
            chats = try context.fetch(request)
            
            
        }catch  {
            print ("error: ")
        }
        return chats
    }
    static func returnAllChats(inContext context: NSManagedObjectContext) -> [Chat] {
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        var chats = [Chat]()
        do {
            chats = try context.fetch(request)
            

        }catch  {
            print ("error: ")
        }
        return chats
    }
    static func chatExisting(hashtag: String, context: NSManagedObjectContext) -> Chat? {
        let request: NSFetchRequest<Chat> = Chat.fetchRequest()
        request.predicate = NSPredicate(format: "hashtagID = %@", hashtag)
        do {
            let results = try context.fetch(request) 
            return results.first
            
        }catch {
            print ("error fetching")
        }
        return nil
        
    }
    static func newChat(hashtag: String,nameChat: String, context: NSManagedObjectContext) -> Chat? {
        guard let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat",into: context)as? Chat else {return nil}
        
            chat.nameChat = nameChat
            chat.hashtagID = hashtag
           
            do {
                try context.save()
            }
            catch {
                print ("Error saving")
            }
        
        return chat
    }
}
