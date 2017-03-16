//
//  File.swift
//  Mittens
//
//  Created by enrico  gigante on 27/08/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData
import Firebase

protocol StartSynchingProtocol {
    func observeMessage(messageRef: FIRDatabaseReference,lastMessageTime: Date?, inContext context: NSManagedObjectContext )
    func observeChats(chatRef: FIRDatabaseReference, inContext context: NSManagedObjectContext)
}
