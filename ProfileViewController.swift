//
//  ProfileViewController.swift
//  Mittens
//
//  Created by enrico  gigante on 29/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class ProfileViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CustomDelegate, PresentationDelegate, MoveToPageOneDelegate,isMyChat, UIPopoverPresentationControllerDelegate {
    
    var profileImage = UIImage()
    var cacheMemory =  NSCache<NSURL,UIImage>()
    // l'ID da considerare
    var userID = UserDef.returnMyiD()
    let context = AllContext.mainContext
    var myChats = [Chat]()
    var name : String?
    var feeds = [Feed](){
        didSet{
            feeds = feeds.sorted{
                if let first = $0.date , let second = $1.date  {
                    return Int(first) > Int(second)
                }
                else { return false }
            }
            collectionView?.reloadData()
        }
    }
    
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "◦◦◦", style: .plain, target: self, action: #selector(presentActionSheet))
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        // add constrains
        view.addConstraintsWithFormat("H:|[v0]|", views: collectionView!)
        view.addConstraintsWithFormat("V:|[v0]|", views: collectionView!)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        myChats = Chat.returnAllMyChats(inContext: context!)
        
        // Register cell classes
        self.collectionView!.register(FirstCollectionViewCell.self, forCellWithReuseIdentifier: "profile")
        self.collectionView!.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: "feed")
        firebaseFeedQuery()
        
    }
    
    func presentActionSheet(){
        let actionSheet = UIAlertController()
        
        let logout = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            if FBSDKAccessToken.current() != nil {
                self.logOutFromProfile(whitProvider: "Facebook")
            }else{
                self.logOutFromProfile(whitProvider: "Google")
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(logout)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }

    
    func logOutFromProfile(whitProvider provider: String) {
        switch provider {
        case "Facebook":
            let fbsMenager = FBSDKLoginManager()
            fbsMenager.logOut()
            switchToLogInViewController()
        case "Google":
            GIDSignIn.sharedInstance().signOut()
            do {
                try  FIRAuth.auth()?.signOut()
            } catch {
                print("error Firbase signOut")
            }
            switchToLogInViewController()
        default:
            break
        }
    }
    
    private func switchToLogInViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // from main storyboard instatiate a navigation controller
        let googleLoginVC = storyboard.instantiateViewController(withIdentifier: "googleLogIn")
        //get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //set the navigation controller as rootVireController
        appDelegate.window?.rootViewController = googleLoginVC
    }

    
    private func firebaseFeedQuery(){
    FIRDatabase.database().reference().child("UsersPublicationsReference").child(userID!).child("Publications").queryOrderedByKey().observe(.childAdded, with: { snapshot in
            //let retrived = snapshot.value as? [String: Any]

            let key = snapshot.key
                
            FIRDatabase.database().reference().child("Feeds").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                let dic = snapshot.value as? [String: Any]
                
                let feedId = snapshot.key
                let feedText = dic?["feedText"] as! String
                let authorID = dic?["authorID"] as! String
                let timeInterval = dic?["PublicationData"] as! TimeInterval
                let media = dic?["Media"] as! String
                let mediaItemUrl = dic?["MediaItemsUrl"] as? [String]
                let likes = dic?["Likes"] as? [String:String] ?? [:]
                let chatID = dic?["chatReference"] as! String
                let category = dic?["type"] as! String
                let chatName = dic?["chatName"] as! String
                let locationInfo = dic?["locationInfo"] as! NSDictionary
                
                // User Info
                var avatarUrl: String?
                var name: String?
                
                //let stringDate = String(describing: date)
                let myPath = FIRDatabase.database().reference().child("users").child(authorID)
                myPath.observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    guard let dict = snapshot.value as? [String:Any]  else {return}
                    avatarUrl = dict["profilePhoto"] as? String
                    name = dict["displayName"] as? String
                    
                    let newFeed = Feed(feedWithId: feedId, InsertionistName: name!, profileImageUrl: avatarUrl!, publicaionDate: timeInterval, forCategory: category ,media: media, mediasUrl: mediaItemUrl, feedText: feedText, likeList: likes, chatID: chatID, chatName: chatName, locationInfo: locationInfo, authorId: authorID)
                    
                    self.feeds.insert(newFeed, at: 0)
                })
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return feeds.count
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile", for: indexPath) as? FirstCollectionViewCell
            cell?.photoView.image = profileImage
            cell?.nameLabel.text = name
            var likes = 0
            for feed in feeds{
                likes += feed.likes?.count ?? 0
            }
            cell?.totalLike.text = "\(likes) Likes ricevuti"
            let totalFeed = feeds.count 
            cell?.totalFeed.text = "\(totalFeed) Inserzioni pubblicate"
            return cell!
            
        case 1:
            
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "feed", for: indexPath) as! FeedCollectionViewCell
            item.delegate = self
            item.presentationDelegate = self
            item.presentationDelegate = self
            item.feed = feeds[indexPath.item]
            
            return item
            
            
        default : break
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section > 2{
            let selectedFeedCVC = SelectedFeedController()
            
            selectedFeedCVC.feed = feeds[indexPath.item]
            selectedFeedCVC.cacheDelegate = self
            
            navigationController?.pushViewController(selectedFeedCVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: view.bounds.width, height: 270)
        case 1:
            let defaultSize = CGSize(width: view.frame.width - 20, height: 50000)
            
            guard let text = feeds[indexPath.item].text else { return defaultSize }
            var constant: CGFloat = 0
            
            let thisFeed = feeds[indexPath.item]
            
            switch thisFeed.media! {
            case "txt":
                constant = 125
            case"img":
                constant = 330
            default:
                break
            }
            
            let surroundings = NSString(string: text).boundingRect(
                with: defaultSize,
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)],
                context: nil)
            
            return CGSize(width: view.frame.width, height: surroundings.height + constant)
            
        default:
            return CGSize(width: 0, height: 0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: view.bounds.width, height: 8)
    }
    // MARK: UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
   
    func presentPopoverForFeed(withID idFeed: String, idChat: String, sender: UIView) {
        let popOver = PopoverViewController()
        
        popOver.modalPresentationStyle = .popover
        popOver.preferredContentSize = CGSize(width: view.frame.width, height: 100)
        
        let presentationController = popOver.popoverPresentationController
        presentationController?.delegate = self
        
        presentationController?.sourceView = sender
        presentationController?.sourceRect = CGRect(x: -16, y: 0, width: sender.frame.size.width, height: sender.frame.size.height)
        presentationController?.backgroundColor = .white
        
        if (sender.superview?.superview?.convert((view.center), from: view))!.y < CGFloat(-100.0){
            presentationController?.permittedArrowDirections = .down
        }else{
            presentationController?.permittedArrowDirections = .up
        }
        
        popOver.feedId = idFeed
        
        
        popOver.removeFeedDelegation = self
        
        present(popOver, animated: true, completion: nil)
    }
    
    func removeFeed(withID id: String) {
        let observePath = FIRDatabase.database().reference().child("Feeds").child(id)
        observePath.removeValue()
        feeds = feeds.filter { (feed) -> Bool in
            return feed.feedId != id
        }
        collectionView?.reloadData()
    }
    
    // MARK: - Popover Presentation Delegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        print("prepare for presentation")
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("did dismiss")
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        print("should dismiss")
        return true
    }
    
    // MARK: - CustomDelegate Method
    func goToSelectedChat(chatID: String, chatName: String){
        
        let chatvc = ChatViewController()
        
        guard let context = AllContext.mainContext  else {print ("error core data"); return }
        if let chat = Chat.chatExisting(hashtag: chatID, context: context){
            
            chatvc.context = AllContext.mainContext
            chatvc.title = chat.nameChat!
            
            chatvc.chat = chat
            
            chatvc.senderId = UserDefaults.standard.object(forKey: "uid") as! String
            chatvc.senderDisplayName = UserDefaults.standard.object(forKey: "displayName") as! String
            chatvc.messageRef = AllFirebasePaths.firebase(pathName: "pathChats")?.child(chatID).child("messages")
            
            let navVC = UINavigationController(rootViewController: chatvc)
            
            present(navVC, animated: true, completion: nil)
        }
        else
        {
            //let myId = UserDefaults.standard.object(forKey: "uid") as! String
            guard let context = AllContext.mainContext else {return}
            let chat = Chat.newChat(hashtag: chatID,nameChat: chatName, context: context)
            
            Observers.observer.observeThisChat(chat: chat!, context: context)
            // mettiamo come foto di defaoult della chat la foto di profilo del primo messaggio in assoluto presente nella chat, che è il mex del creatore della chat!
            let chatRef = AllFirebasePaths.firebase(pathName: "pathChats")!
            let messageRef = chatRef.child(chatID).child("messages")
            messageRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
                if let dict = snapshot.value as? [String: Any] {
                    guard let senderId = dict["senderId"] as? String else {return}
                    FIRDatabase.database().reference().child("users").child(senderId).observe(.value) { (snapshot: FIRDataSnapshot) in
                        //print(snapshot.value)
                        guard let dict = snapshot.value as? [String:Any]  else {return }
                        let avatarUrl = dict["profilePhoto"] as! String
                        
                        let fileUrl = URL(string: avatarUrl)
                        let data = try? Data(contentsOf: fileUrl!)
                        chat?.photoChat = data as NSData?
                        
                        context.performAndWait {
                            do {
                                try context.save()
                            }catch {
                                
                            }
                        }
                    }
                }
            })
            //chat?.photoChat = chat?.firstMessageTime?.sender?.profilePhoto
            
            chatvc.title = chat?.nameChat!
            chatvc.context = context
            chatvc.chat = chat
            
            chatvc.senderId = UserDefaults.standard.object(forKey: "uid") as! String
            chatvc.senderDisplayName = UserDefaults.standard.object(forKey: "displayName") as! String
            chatvc.messageRef = AllFirebasePaths.firebase(pathName: "pathChats")?.child(chatID).child("messages")
            
            let navVC = UINavigationController(rootViewController: chatvc)
            
            present(navVC, animated: true, completion: nil)
        }
    }
    
    func finishFatchImage(obj: UIImage, key: NSURL, cost: Int) {
        cacheMemory.setObject(obj, forKey: key, cost: cost)
    }
    
    func restoreImage(urlOfImage url: NSURL) -> UIImage? {
        if let image = cacheMemory.object(forKey: url) {
            return image
        }
        else {
            return nil
        }
    }
    
    // MARK: - Presentation Delegate
    func presentLikersForFeed(whitLikes likes: [String : String]) {
        let likersTVC = LikersTableViewController()
        likersTVC.delegate = self
        likersTVC.title = "Likers"
        
        let key = likes.keys
        let likers = Array(key)
        likersTVC.likers = likers
        
        navigationController?.pushViewController(likersTVC, animated: true)
    }
    
    func moveToSelectedProfile(withID id: String, profilePhoto: UIImage?, withName: String) {
        let profileVC = ProfileViewController()
        profileVC.userID = id
        if let photoProfile = profilePhoto {
            profileVC.profileImage = photoProfile
        }
        profileVC.name = withName
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
