//
//  Media+CoreDataClass.swift
//  Mittens
//
//  Created by enrico  gigante on 29/08/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import CoreData


public class Media: NSManagedObject {
    static func mediaExisting (existUrl fileUrl:String, inContext context: NSManagedObjectContext) -> Media? {
        let request: NSFetchRequest<Media> = Media.fetchRequest()
        request.predicate = NSPredicate(format: "fileUrl = %@ ", fileUrl)
        do {
            let results = try context.fetch(request)
            
            let media = results.first
            
            return media
            
            
        } catch {
            print ("error fetching")
        }
        return nil
    }
    
    static func insertMedia ( mediaData: NSData, fileUrl:String, inContext context: NSManagedObjectContext) -> Media? {
        guard let media = NSEntityDescription.insertNewObject(forEntityName: "Media", into: context) as? Media else {return nil}
        media.data = mediaData
        media.fileUrl = fileUrl
        
        return media
    }
}
