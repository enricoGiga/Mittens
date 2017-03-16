//
//  Person.swift
//  mittens
//
//  Created by Cristian Turetta on 19/10/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import UIKit

class Person{
    var displayName:String?
    var identifier: String?
    var profileImage: UIImage?
    
    init(personoWhitName name: String, userIdentifier userId: String, andProfileImage image: UIImage) {
        displayName = name
        identifier = userId
        profileImage = image
    }
    
}
