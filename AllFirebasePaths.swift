//
//  AllFirebasePaths.swift
//  Mittens
//
//  Created by enrico  gigante on 27/08/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import Firebase

struct AllFirebasePaths  {
    
    static let root = [
    "rootRef": FIRDatabase.database().reference(),
    "pathMessages": FIRDatabase.database().reference().child("messages"),
    "pathChats": FIRDatabase.database().reference().child("Chats")
    
    ]
    static func firebase( pathName: String) -> FIRDatabaseReference? {
        guard let firebaseRoot = root[pathName] else {return nil}
        return firebaseRoot
    }
}
