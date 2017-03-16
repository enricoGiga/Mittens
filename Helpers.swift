//
//  Helpers.swift
//  
//
//  Created by enrico  gigante on 22/08/16.
//
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn
import FirebaseDatabase
import CoreData
import FBSDKLoginKit

class Helpers {
    static let helper = Helpers()
    
    func loginWhitFacebook(whitToken token: FBSDKAccessToken){
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) in
            
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            } else {
                
                guard let context = AllContext.mainContext else {return }
                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
                
                let data = try? Data(contentsOf: user!.photoURL!)
                newUser.setValue([ "displayName" : "\(user!.displayName!)", "id" : "\(user!.uid)" , "profilePhoto": "\(user!.photoURL!)"])
                UserDefaults.standard.set(user!.uid, forKey: "uid")
                //let uid = UserDefaults.standard.object(forKey: "uid") as? String
                UserDefaults.standard.set(user?.displayName, forKey: "displayName")
                
                if  Contact.isContactExisting(withId: user!.uid, inContext: context) == nil {
                    _ = Contact.saveAndReturnNewContact(withId: user!.uid, withDisplayName: user!.displayName!, withProfilePhoto: data as NSData?,chat: nil, inContext: context)
                    UserDefaults.standard.set(user!.uid, forKey: "uid")
                    //let uid = UserDefaults.standard.object(forKey: "uid") as? String
                    UserDefaults.standard.set(user?.displayName, forKey: "displayName")
                    let displayName = UserDefaults.standard.object(forKey: "displayName") as? String
                    
                }
                self.switchToNavigationController()
            }
        })        
    }
    
    
    func logInWithGoogle(autentication: GIDAuthentication){
        let credential = FIRGoogleAuthProvider.credential(withIDToken: autentication.idToken, accessToken: autentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) in
       
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            } else {

                guard let context = AllContext.mainContext else {return }
                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
               
                let data = try? Data(contentsOf: user!.photoURL!)
                newUser.setValue([ "displayName" : "\(user!.displayName!)", "id" : "\(user!.uid)" , "profilePhoto": "\(user!.photoURL!)"])
                UserDefaults.standard.set(user!.uid, forKey: "uid")
                //let uid = UserDefaults.standard.object(forKey: "uid") as? String
                UserDefaults.standard.set(user?.displayName, forKey: "displayName")

                if  Contact.isContactExisting(withId: user!.uid, inContext: context) == nil {
                    _ = Contact.saveAndReturnNewContact(withId: user!.uid, withDisplayName: user!.displayName!, withProfilePhoto: data as NSData?,chat: nil, inContext: context)
                    UserDefaults.standard.set(user!.uid, forKey: "uid")
                    UserDefaults.standard.set(user?.displayName, forKey: "displayName")
                }
                self.switchToNavigationController()
            }
        })
    }
    func switchToNavigationController () {
        // create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // from main storyboard instatiate a navigation controller
        let tabVC = storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        //get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //set the navigation controller as rootVireController
        appDelegate.window?.rootViewController = tabVC
        
        
    }
}
