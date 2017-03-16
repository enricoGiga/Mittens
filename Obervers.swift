//
//  Obervers.swift
//  Mittens
//
//  Created by enrico  gigante on 28/08/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation

import CoreData
import Firebase

class Observers: StartSynchingProtocol {
    static let observer = Observers()
    func observeChats(chatRef: FIRDatabaseReference, inContext context: NSManagedObjectContext) {
        
        // ricerca nel core delle chat aperte
        let allChats = Chat.returnAllChats(inContext: context)
        for chat in allChats {
         //   print(chat.hashtagID)
            let hashtag = chat.hashtagID
            let lastMessageTime = chat.lastMessage
            let messageRef = chatRef.child(hashtag!).child("messages")
            
            //TODO: if token on firebase != mytoken aggiorniamo
            
            
            self.observeMessage(messageRef: messageRef,lastMessageTime: lastMessageTime as Date? ,  inContext: context)
        }
    }
    
    func observeThisChat ( chat: Chat, context: NSManagedObjectContext) {
        let lastMessageTime = chat.lastMessage
        let hashtag = chat.hashtagID
        let chatRef = AllFirebasePaths.firebase(pathName: "pathChats")!
        
        let messageRef = chatRef.child(hashtag!).child("messages")
        self.observeMessage(messageRef: messageRef,lastMessageTime: lastMessageTime as Date? ,  inContext: context)
    }
    
    func observeMessage(messageRef: FIRDatabaseReference,lastMessageTime: Date?, inContext context: NSManagedObjectContext) {
        
        
        let lastMessage = lastMessageTime?.timeIntervalSince1970  ?? 0
        // .ChildAdded guarda uno alla volta , .Child restituisce tutto una sola volta
        /*queryOrderedByKey().queryStarting(atValue: lastMessage).*/
        // fetch dall'ultimo messaggio registrato
        messageRef.queryOrderedByKey().queryStarting(atValue: String(lastMessage * 100000 )).observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            //print (snapshot.value)
            if let dict = snapshot.value as? [String: Any] {
                //print (dictionary)
                // questi tre sono obbligatori
                guard let senderId = dict["senderId"] as? String else {return}
                //guard let senderName = dict["senderDisplayName"] as? String else {return}
                guard let mediaType = dict["MediaType"]as? String else {return}
                guard let timeinterval = dict["timestamp"]as?  TimeInterval  else {return}
                guard let hashchat = dict["chat"] as? String else {return}
                let date = NSDate(timeIntervalSince1970: timeinterval)
                
                
                
                
                // se il messaggio esiste esco
                if Message.messageExisting(timestamp: date, inConctext: context) != nil { return }
                
                switch mediaType {
                case "TEXT":
                    let text = dict["text"] as! String
                    
                    // se il contatto esiste nel core...
                    
                    if let contact = Contact.isContactExisting(withId: senderId, inContext: context) {
                        // print ("contact existing, id:\(contact.id) con nome:\(contact.displayName)")
                        guard let chat = Chat.chatExisting(hashtag: hashchat, context: context) else {print("niente chat?"); return}
                        if Chat.isThisContactPartecipate(contact: contact, chat: chat, inContext: context) == false{
                            chat.addToContacts(contact)
                        }
                        
                        Message.createNewMessage(text: text, timestamp: date, media: nil, sender: contact, context: context, chat: chat)
                        
                    } else {
                        //altrimenti devo prendere la foto profilo! vado nello storage...
                        FIRDatabase.database().reference().child("users").child(senderId).observe(.value) { (snapshot: FIRDataSnapshot) in
                            //print(snapshot.value)
                            guard let dict = snapshot.value as? [String:Any]  else {return }
                            let avatarUrl = dict["profilePhoto"] as! String
                            let displayName = dict["displayName"] as! String
                            
                            let fileUrl = URL(string: avatarUrl)
                            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                            let data = try? Data(contentsOf: fileUrl!)
                            DispatchQueue.main.async {
                            guard let chat = Chat.chatExisting(hashtag: hashchat, context: context) else {print("niente chat?"); return}
                            
                            let contact = Contact.isContactExisting(withId: senderId, inContext: context) ?? Contact.saveAndReturnNewContact(withId: senderId, withDisplayName: displayName, withProfilePhoto: data as NSData?, chat: chat, inContext: context)
                            if Chat.isThisContactPartecipate(contact: contact!, chat: chat, inContext: context) == false{
                                chat.addToContacts(contact!)
                            }
                            // print ("contact existing, id:\(contact?.id) con nome:\(contact?.displayName)")
                            
                            Message.createNewMessage(text: text, timestamp: date, media: nil, sender: contact, context: context, chat: chat)
                            }
                            }
                        }
                    }
                    
                    
                case "PHOTO", "VIDEO":
                    
                    let textUrl = dict["fileUrl"] as! String
                    //if contact exist with this senderId
                    if let contact = Contact.isContactExisting(withId: senderId, inContext: context){
                        guard let messages = contact.messages?.allObjects as? [Message] else {return}
                        
                        // if message with this url exist inside CoreData then return
                        if  messages.filter({ $0.media?.fileUrl == textUrl   }).first != nil{
                            return
                            
                            
                        } else {
                            //otherwise create new message
                            if let url = URL(string: textUrl){
                                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                                if let data = try? Data(contentsOf: url) {
                                    DispatchQueue.main.async {
                                    let media = Media.insertMedia(mediaData: data as NSData, fileUrl: textUrl, inContext: context)
                                    
                                    let chat = Chat.chatExisting(hashtag: hashchat, context: context)
                                    // salviamo il nuovo messaggio
                                    if Chat.isThisContactPartecipate(contact: contact, chat: chat!, inContext: context) == false{
                                        chat?.addToContacts(contact)
                                    }
                                    Message.createNewMessage(text: nil, timestamp: date, media: media , sender: contact, context: context, chat: chat!)
                                    }
                                }
                                }
                            }
                        }
                        
                    } else{
                        //altrimenti non esiste il contatto
                        
                        //altrimenti devo prendere la foto profilo! vado nello storage...
                        FIRDatabase.database().reference().child("users").child(senderId).observe(.value) { (snapshot: FIRDataSnapshot) in
                            //print(snapshot.value)
                            guard let dict = snapshot.value as? [String:AnyObject]  else {return }
                            let avatarUrl = dict["profilePhoto"] as! String
                            let displayName = dict["displayName"] as! String
                            
                            let fileUrl = URL(string: avatarUrl)
                             DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                            let data = try? Data(contentsOf: fileUrl!)
                            DispatchQueue.main.async {
                            
                            guard let chat = Chat.chatExisting(hashtag: hashchat, context: context) else {print("niente chat?"); return}
                            
                            let contact = Contact.isContactExisting(withId: senderId, inContext: context) ?? Contact.saveAndReturnNewContact(withId: senderId, withDisplayName: displayName, withProfilePhoto: data as NSData?, chat: chat, inContext: context)
                            
                            if Chat.isThisContactPartecipate(contact: contact!, chat: chat, inContext: context) == false{
                                chat.addToContacts(contact!)
                            }
                                
                            if let url = URL(string: textUrl){
                                
                                if let data = try? Data(contentsOf: url) {
                                    
                                    let media = Media.insertMedia(mediaData: data as NSData, fileUrl: textUrl, inContext: context)
                                    // salviamo il nuovo messaggio
                                    
                                    let chat = Chat.chatExisting(hashtag: hashchat, context: context)
                                    Message.createNewMessage(text: nil, timestamp: date, media: media , sender: contact, context: context, chat: chat!)
                                }
                                
                                else{
                                    print("niente url")
                                }
                            }
                            
                            //Message.createNewMessage(text, timestamp: date, media: nil, sender: contact, context: context)
                            }
                            }
                        }
                        
                        
                    }
                    
                    break
                    
                //                case "VIDEO": break
                default: break
                }
                
                
            }
        }
    }
    
    
}
