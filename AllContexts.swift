//
//  AllContexts.swift
//  Mittens
//
//  Created by enrico  gigante on 27/08/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class AllContext {
    /**
     * returns the main object Context
     */
    static var mainContext : NSManagedObjectContext? {
        get{
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            return appDelegate?.persistentContainer.viewContext
        }
    }
}
