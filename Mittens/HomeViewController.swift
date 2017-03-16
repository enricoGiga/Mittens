//
//  HomeViewController.swift
//  Home
//
//  Created by Cristian Turetta on 10/09/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import CoreData
import MBProgressHUD
import GeoFire


class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CustomDelegate, PresentationDelegate, MoveToPageOneDelegate,isMyChat, UIPopoverPresentationControllerDelegate
{
    
    
    // dispatch group
    //let queue:DispatchQueue	= DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault)
    //let queue:DispatchQueue	= DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
    
    let geoFireDispatchGroup = DispatchGroup()
    //    let feedDispatchGroup = DispatchGroup()
    //    let profileDispatchGroup = DispatchGroup()
    
    // MARK: - Model
    var cacheMemory =  NSCache<NSURL,UIImage>()
    let userDefault = UserDef()
    let context = AllContext.mainContext
    var myName: String?
    
    // MARK: - Search Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Location
    let locationManager = CLLocationManager()
    static var radousIsChanged: Bool = false
    
    // MARK: - GeoFire Variables
    static var circleQuery: GFCircleQuery?
    static var geoFireObserver: UInt?
    
    let geoFire: GeoFire = {
        let geofireReference = FIRDatabase.database().reference().child("GeoFireLocations")
        let geo = GeoFire(firebaseRef: geofireReference)
        return geo!
    }()
    
    // MARK: - Feeds
    var feeds: [Feed] = [Feed](){
        didSet{
            feeds = feeds.sorted{
                if let first = $0.date , let second = $1.date  {
                    return Int(first) > Int(second)
                }
                else { return false }
            }
            
            if isFiltered {
                filteredFeeds.removeAll()
                filteredFeeds = feeds.filter({ (feed) -> Bool in
                    return feed.category == HomeViewController.category
                })
            }
            
            collectionView?.reloadData()
        }
    }
    
    // MARK: - Filter Variables
    var filteredFeeds: [Feed] = [Feed]()
    
    static var category: String = "nofilter"
    
    var isFiltered = false {
        didSet{
            filteredFeeds.removeAll()
            filteredFeeds = feeds.filter({ (feed) -> Bool in
                return feed.category == HomeViewController.category
            })
            collectionView?.reloadData()
        }
    }
    
    // MARK: - Outlets
    var collectionView: UICollectionView?
    
    // MARK: - Overrided Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional setup...
        
        /** Search Controller Settings:                            **/
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        /**                                                        **/
        
        /** Navigation Item Settings                               **/
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "filter", style: UIBarButtonItemStyle.plain, target: self, action: #selector(presentActionSheet))
        navigationItem.titleView = searchController.searchBar
        /**                                                        **/
        
        
        /** Collection View Settings                               **/
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        collectionView?.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: "feed")
        collectionView?.register(newPostCollectionViewCell.self, forCellWithReuseIdentifier: "newFeed")
        collectionView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        setCollectionView()
        /**                                                        **/
        
        /** Retrive my position                                    **/
        let center = CLLocation(latitude: MyLocationInfo.myLocation.latitude ?? /*userDefault.returnCenter().0! */ 0, longitude: MyLocationInfo.myLocation.longitude ?? /*userDefault.returnCenter().1! */0)
        
        HomeViewController.circleQuery = geoFire.query(at: center, withRadius: Double(userDefault.returnDistance()!))
        /**                                                        **/
        
        /** Retrive Feed from Firebase                             **/
        firebaseFeedQuery()
        /**                                                        **/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isFiltered = false
        
        if HomeViewController.radousIsChanged {
            let center = CLLocation(latitude: MyLocationInfo.myLocation.latitude ?? userDefault.returnCenter().0!, longitude: MyLocationInfo.myLocation.longitude ?? userDefault.returnCenter().1!)
            
            HomeViewController.circleQuery?.removeAllObservers()
            HomeViewController.circleQuery = geoFire.query(at: center, withRadius: Double(userDefault.returnDistance()!))
            firebaseFeedQuery()
            HomeViewController.radousIsChanged = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print("Memory warning!")
    }
    
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if searchController.isActive && searchController.searchBar.text != "" { return filteredFeeds.count }
            if isFiltered{ return filteredFeeds.count }else{ return feeds.count }
        default:
            return 0
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            if let firstItem = collectionView.dequeueReusableCell(withReuseIdentifier: "newFeed", for: indexPath) as? newPostCollectionViewCell{
                firstItem.delegateForMoveToPageOne = self
                return firstItem
            }
            
        case 1:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "feed", for: indexPath) as! FeedCollectionViewCell
            item.delegate = self
            item.presentationDelegate = self
            let context = AllContext.mainContext
            
            if isFiltered{
                item.feed = filteredFeeds[indexPath.item]
            }else{
                item.feed = feeds[indexPath.item]
            }
            
            if let _ =  Chat.chatExisting(hashtag: (item.feed?.chatID)!, context: context!) {
                let color =  UIColor(red: 25/255, green: 130/255, blue: 255/255, alpha: 1)
                item.goToChat.setTitleColor(color, for: .normal)
                item.chatImageView.image = UIImage(named: "Speech_Bubble")?.withRenderingMode(.alwaysTemplate)
                item.chatImageView.tintColor = color
                
                item.goToChat.titleLabel?.font = UIFont.init(name: "AppleGothic", size: 16)
            } else {
                item.goToChat.setTitleColor(.lightGray, for: .normal)
                item.goToChat.titleLabel?.font = UIFont.init(name: "AppleGothic", size: 16)
                item.chatImageView.image = UIImage(named: "Speech_Bubble")?.withRenderingMode(.alwaysTemplate)
                item.chatImageView.tintColor = .lightGray
                
            }
            return item
            
        default:
            break
            
        }
        return UICollectionViewCell()
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: view.frame.width, height: 80)
            
        case 1:
            let defaultSize = CGSize(width: view.frame.width - 20, height: 50000)
            var thisFeed: Feed?
            var text = ""
            
            if isFiltered {
                thisFeed = filteredFeeds[indexPath.item]
                text = filteredFeeds[indexPath.item].text!
            }else{
                thisFeed = feeds[indexPath.item]
                text = feeds[indexPath.item].text!
            }
            
            var constant: CGFloat = 0
            
            switch (thisFeed?.media)! {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFeedCVC = SelectedFeedController()
        selectedFeedCVC.feed = feeds[indexPath.item]
        selectedFeedCVC.cacheDelegate = self
        
        navigationController?.pushViewController(selectedFeedCVC, animated: true)
    }
    
    // MARK: - Public Implementations
    func setCollectionView(){
        view.addConstraintsWithFormat("H:|[v0]|", views: collectionView!)
        view.addConstraintsWithFormat("V:|[v0]|", views: collectionView!)
    }
    
    func createNewPost() {
        let categorySelectionVc = CategorySelectionViewController()
        let navVC = UINavigationController(rootViewController: categorySelectionVc)
        navigationController?.title = "Category"
        present(navVC,animated: true, completion: nil)
    }
    
    func presentActionSheet(){
        let actionSheet = UIAlertController()
        
        let sportFilter = UIAlertAction(title: "Sport", style: .default) { (action) in
            self.applyFilter(forCategory: action.title!)
        }
        
        let instructionFilter = UIAlertAction(title: "Istruzione", style: .default) { (action) in
            self.applyFilter(forCategory: action.title!)
        }
        
        let jobFilter = UIAlertAction(title: "Lavoro", style: .default) { (action) in
            self.applyFilter(forCategory: action.title!)
        }
        
        let hobbyFilter = UIAlertAction(title: "Hobby", style: .default) { (action) in
            self.applyFilter(forCategory: action.title!)
        }
        
        let musicFilter = UIAlertAction(title: "Musica", style: .default) { (action) in
            self.applyFilter(forCategory: action.title!)
        }
        
        let travelFilter = UIAlertAction(title: "Viaggi e Vacanze", style: .default) { (action) in
            self.applyFilter(forCategory: action.title!)
        }
        
        let cateringFilter = UIAlertAction(title: "Ristorazione", style: .default) { (action) in
            self.applyFilter(forCategory: action.title!)
        }
        
        let noFilter = UIAlertAction(title: "Nessun Filtro", style: .default) { (action) in
            HomeViewController.category = "nofilter"
            self.isFiltered = false
        }
        
        let healthFilter = UIAlertAction(title: "Salute e Benessere", style: .default) { (action) in
            self.applyFilter(forCategory: action.title!)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let actions = [noFilter, sportFilter, instructionFilter, jobFilter, hobbyFilter, musicFilter, travelFilter, cateringFilter, healthFilter, cancel]
        
        for action in actions{
            actionSheet.addAction(action)
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func applyFilter(forCategory category: String){
        HomeViewController.category = category
        isFiltered = true
    }
    
    func filterContentForSearchText(searchText: String){
        if searchText != ""{
            isFiltered = true
            if HomeViewController.category == "nofilter"{
                filteredFeeds = feeds.filter({ (feed) -> Bool in
                    return ((feed.chatName?.lowercased().contains(searchText.lowercased()))! || (feed.text?.lowercased().contains(searchText.lowercased()))!)
                })
            }else{
                filteredFeeds = filteredFeeds.filter({ (feed) -> Bool in
                    if feed.category == HomeViewController.category {
                        return ((feed.chatName?.lowercased().contains(searchText.lowercased()))! || (feed.text?.lowercased().contains(searchText.lowercased()))!)
                    }
                    // Se feed non appartiene alla categoria precedentemente settata non lo considero
                    return false
                })
            }
        }else{
            if HomeViewController.category == "nofilter"{
                isFiltered = false
            }else{
                filteredFeeds = feeds.filter({ (feed) -> Bool in
                    return feed.category == HomeViewController.category
                })
            }
        }
        collectionView?.reloadData()
    }
    
    // MARK: - Private Implementations
    private func firebaseFeedQuery(){
        var count = 0
        
        filteredFeeds.removeAll()
        feeds.removeAll()
        HomeViewController.geoFireObserver = HomeViewController.circleQuery?.observe(.keyEntered, with: { (key, location) in
            count = count + 1
            if count < 10 {
            FIRDatabase.database().reference().child("Feeds").child(key!).observeSingleEvent(of: .value, with: { (snapshot) in
                let retrived = snapshot.value as? [String: Any]
                
                // Feed infos
                let feedId = snapshot.key
                let feedText = retrived?["feedText"] as! String
                let authorID = retrived?["authorID"] as! String
                let timeInterval = retrived?["PublicationData"] as! TimeInterval
                let media = retrived?["Media"] as! String
                let mediaItemUrl = retrived?["MediaItemsUrl"] as? [String]
                let likes = retrived?["Likes"] as? [String:String] ?? [:]
                let chatID = retrived?["chatReference"] as! String
                let category = retrived?["type"] as! String
                let chatName = retrived?["chatName"] as! String
                let locationInfo = retrived?["locationInfo"] as! NSDictionary
                
                // User Info
                var avatarUrl: String?
                var name: String?
                
                let myPath = FIRDatabase.database().reference().child("users").child(authorID)
                
                myPath.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // Get User Value from Firebase
                    guard let dict = snapshot.value as? [String:Any]  else {return}
                    avatarUrl = dict["profilePhoto"] as? String
                    name = dict["displayName"] as? String
                    
                    // Creation of a new feed object
                    let newFeed = Feed(feedWithId: feedId, InsertionistName: name!, profileImageUrl: avatarUrl!, publicaionDate: timeInterval, forCategory: category ,media: media, mediasUrl: mediaItemUrl, feedText: feedText, likeList: likes, chatID: chatID, chatName: chatName, locationInfo: locationInfo, authorId: authorID)
                    
                    self.feeds.insert(newFeed, at: 0)
                })
            })
            }
        })
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
        popOver.chatId = idChat
        
        popOver.removeFeedDelegation = self
        
        present(popOver, animated: true, completion: nil)
    }
    
    func removeFeed(withID idFeed: String,  idChat: String) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let observePath = FIRDatabase.database().reference().child("Feeds").child(idFeed)
        let authorPath = FIRDatabase.database().reference().child("UsersPublicationsReference").child(userID!).child("Publications").child(idFeed)
        
        observePath.removeValue()
        authorPath.removeValue()
        
        geoFire.removeKey(idFeed)
        feeds = feeds.filter { (feed) -> Bool in
            return feed.feedId != idFeed
        }
        // cancello chat dal core database
        let context = AllContext.mainContext
        if let chat = Chat.chatExisting(hashtag: idChat, context: context!){
            context?.delete(chat)
            do {
                try context?.save()
            }catch {
                
            }
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
    
    // MARK: - CustomDelegate Methods
    func goToSelectedChat(chatID: String, chatName: String){
        
        let chatvc = ChatViewController()
        
        guard let context = AllContext.mainContext  else {print ("error core data"); return }
        if let chat = Chat.chatExisting(hashtag: chatID, context: context){
            
            chatvc.context = AllContext.mainContext
            chatvc.title = chat.nameChat!
            
            chatvc.chat = chat
            chatvc.isSubscribed = true
            
            chatvc.senderId = UserDefaults.standard.object(forKey: "uid") as! String
            chatvc.senderDisplayName = UserDefaults.standard.object(forKey: "displayName") as! String
            chatvc.messageRef = AllFirebasePaths.firebase(pathName: "pathChats")?.child(chatID).child("messages")
            
            let navVC = UINavigationController(rootViewController: chatvc)
            present(navVC, animated: true, completion: nil)
        }
        else
        {
            guard let context = AllContext.mainContext else {return}
            let chat = Chat.newChat(hashtag: chatID, nameChat: chatName, context: context)
            
            chat?.userID =  (UserDefaults.standard.object(forKey: "uid") as! String)
            
            Observers.observer.observeThisChat(chat: chat!, context: context)

            FIRDatabase.database().reference().child("Chats").child(chatID).child("Info").observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: String] {
                    let groupPhotoUrl = dict["groupPhoto"] 
                    
                    let photoGroupData = try? Data(contentsOf: URL(string: groupPhotoUrl!)!)
                    chat?.photoChat = photoGroupData as NSData?
                    
                    context.performAndWait {
                        do {
                            try context.save()
                        }catch {
                            print("Errore Core Data")
                        }
                    }
                    
                    chatvc.title = chat?.nameChat!
                    chatvc.context = context
                    chatvc.chat = chat
                    chatvc.isSubscribed = false
                    
                    chatvc.senderId = UserDefaults.standard.object(forKey: "uid") as! String
                    chatvc.senderDisplayName = UserDefaults.standard.object(forKey: "displayName") as! String
                    
                    chatvc.messageRef = AllFirebasePaths.firebase(pathName: "pathChats")?.child(chatID).child("messages")
                    let navVC = UINavigationController(rootViewController: chatvc)
                            
                    self.present(navVC, animated: true, completion: nil)
                }
            })
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
    
    
    func moveToSelectedProfile(withID id: String, profilePhoto: UIImage?, withName: String) {
        let profileVC = ProfileViewController()
        profileVC.userID = id
        if let photoProfile = profilePhoto {
            profileVC.profileImage = photoProfile
        }
        profileVC.name = withName
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    // MARK: - Search Result Updating Method
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

// MARK: - Extensions
extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController){
        
    }
}
