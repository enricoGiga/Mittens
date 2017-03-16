//
//  GoogleLogInVC.swift
//  Mittens
//
//  Created by enrico  gigante on 24/08/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class GoogleLogInVC: UIViewController, GIDSignInUIDelegate , GIDSignInDelegate, FBSDKLoginButtonDelegate {
    let welcomeLebel = UILabel()
    let whatISMittens = UILabel()

    
    
    //MARK: Variables
    private let segueToChat = "chatSegue"
    let signInButton = GIDSignInButton()
    let facebookButton = FBSDKLoginButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookButton.delegate = self
        let labels = [welcomeLebel, whatISMittens,  signInButton, facebookButton]
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
        }
        
        // welcome label
        let welcomeAttributes = [NSForegroundColorAttributeName: UIColor.lightGray]
        let textWelcome = NSMutableAttributedString(string: "Benvenuto in Mittens!", attributes: welcomeAttributes)
        welcomeLebel.attributedText = textWelcome
        welcomeLebel.textAlignment = .center
        welcomeLebel.font = UIFont.init(name: "AppleGothic", size: 24)
        //whatIsMittens Label
        whatISMittens.text = "Crea un' inserzione in maniera semplice e efficace. "
        //Hai un attività o Vuoi semplicemente registare le tue lezioni private? Allora Mittens fa al tuo caso.  Ti consigliamo per esperienza che la soluzione migliore per ottenere likes e quindi aumentare il numero di interessati è quella di inserire una descrizione esauriente della tua attività allegando delle immagini. \n Ti ricordiamo che Mittens è un'applicazione completamente gratuita creata al solo scopo di facilitare la  pubblicizzazione di annunci privati di qualsiasi genere. Sarà inoltre possibile entrare in comunicazione tramite una chat privata con l'interessato\n. Inizia subito!
        whatISMittens.textColor = UIColor.white
        whatISMittens.textAlignment = .center
        whatISMittens.numberOfLines = 15
        whatISMittens.font = UIFont.init(name: "AppleGothic", size: 18)
        //button
        
      //  signInButton.addTarget(self, action: #selector(gologInWithGoogle), for: .touchUpInside)
        //constrains
        let constrains: [NSLayoutConstraint] = [
            welcomeLebel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            welcomeLebel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            welcomeLebel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            welcomeLebel.bottomAnchor.constraint(equalTo: whatISMittens.topAnchor, constant: -20),
            whatISMittens.topAnchor.constraint(equalTo: welcomeLebel.bottomAnchor, constant: 20),
            whatISMittens.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            whatISMittens.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            //whatISMittens.bottomAnchor.constraint(equalTo: facebookButton.topAnchor, constant: -150),
           whatISMittens.bottomAnchor.constraint(lessThanOrEqualTo: facebookButton.topAnchor, constant: -150),

            facebookButton.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -16),
            facebookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signInButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constrains)
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "sfondo1")!)
        GIDSignIn.sharedInstance().clientID =  FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
//            if user != nil {
//                guard let context = AllContext.mainContext else {return }
//                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
//                
//                let data = try? Data(contentsOf: user!.photoURL!)
//                newUser.setValue([ "displayName" : "\(user!.displayName!)", "id" : "\(user!.uid)" , "profilePhoto": "\(user!.photoURL!)"])
//                UserDefaults.standard.set(user!.uid, forKey: "uid")
//                //let uid = UserDefaults.standard.object(forKey: "uid") as? String
//                UserDefaults.standard.set(user?.displayName, forKey: "displayName")
//                
//                if  Contact.isContactExisting(withId: user!.uid, inContext: context) == nil {
//                    _ = Contact.saveAndReturnNewContact(withId: user!.uid, withDisplayName: user!.displayName!, withProfilePhoto: data as NSData?,chat: nil, inContext: context)
//                    UserDefaults.standard.set(user!.uid, forKey: "uid")
//                    UserDefaults.standard.set(user?.displayName, forKey: "displayName")
//                }
//                Helpers.helper.switchToNavigationController()
//            }
//        })
//    }
    
    // MARK: - Facebook Delegate Methods
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        Helpers.helper.loginWhitFacebook(whitToken: result.token)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logout")
    }
    
    // MARK: - Google Delegate Methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error.localizedDescription)
            return
        }
        
        print("print user autentication: \(user.authentication)")
        Helpers.helper.logInWithGoogle(autentication: user.authentication)
        
        //andiamo sulla tab bar
        //  performSegueWithIdentifier(segueToChat, sender: self)
    }

    func gologInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
        
    
    }

    


}
