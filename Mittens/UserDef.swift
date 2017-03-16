//
//  UserDefaults.swift
//  ProChat
//
//  Created by Otto House on 04/08/16.
//  Copyright © 2016 Cristian. All rights reserved.
//

import Foundation

class UserDef {
    
    struct Chiavi {
        static let keyuser = "keyUserSearch"
        static let tipology = "tipology"
        static let description = "description"
        static let myUserId = "uid"
        static let distance = "distance"
    }
    
    private let numberOfSearchStored = 1 // quanti ne voglio memorizzare
    let userDefault = UserDefaults.standard
    
    func store(count: Int) {
        
        //evitiamo le ripetizioni
        
        userDefault.set(count, forKey: Chiavi.keyuser)
    }
    
    func returnNumber () -> Int?{
        return userDefault.object(forKey: Chiavi.keyuser) as? Int
    }
    
    //tipologia annuncio
    func storeTipologyInsertion(forTipology tipology: String)  {
        userDefault.set(tipology, forKey: Chiavi.tipology)
    }
    func returnTipologyInsetion() -> String?{
        return userDefault.object(forKey: Chiavi.tipology) as? String
    }
    // description annuncio
    func storeDescription(text: String) {
        userDefault.set(text, forKey: Chiavi.description)
    }
    func returnDescription () -> String? {
        return userDefault.object(forKey: Chiavi.description) as? String
    }
    static func returnMyiD() -> String? {
        return UserDefaults.standard.object(forKey: Chiavi.myUserId) as? String
    }
    func storeDistance(forDistance distance: Float) {
        userDefault.set(distance, forKey: Chiavi.distance)
    }
    func returnDistance() -> Float? {
        return userDefault.object(forKey: Chiavi.distance) as? Float
    }
    func storeCenter(latitude: Double, longitude: Double) {
        userDefault.set(latitude, forKey: "latitude")
        userDefault.set(longitude, forKey: "longitude")
    }
    func returnCenter() -> (Double?,Double?) {
        return (userDefault.object(forKey: "latitude") as? Double, userDefault.object(forKey: "longitude") as? Double)
    }
    func storeMyToken(token: String){
        userDefault.set(token, forKey: "token")
    }
    func returnMyToken() -> String? {
        return userDefault.object(forKey: "token") as? String
    }
 }

