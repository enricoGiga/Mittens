//
//  FeedCollectionViewCell.swift
//  Home
//
//  Created by Cristian Turetta on 10/09/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MBProgressHUD
class FeedCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate{
    
    weak var delegate: CustomDelegate?
    weak var presentationDelegate: PresentationDelegate?

    var obs = UInt()
    var observePath = FIRDatabaseReference()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Remove all labels
        for label in labels{
            label.removeFromSuperview()
        }
        
        // Reset profile image
        profileImageView.image = nil
        insertionImageView.image = nil
        
        // Default values for like button and label
        like.setTitle("Like", for: .normal)
        like.setTitleColor(.lightGray, for: .normal)
        likeCountLabel.setTitle("0", for: .normal)
        likeCountLabel.setTitleColor(.lightGray, for: .normal)
        likeImageView.image = UIImage(named: "Thumb_Up")?.withRenderingMode(.alwaysTemplate)
        likeImageView.tintColor = .lightGray
        goToChat.setTitleColor(.lightGray, for: .normal)
        chatImageView.image =  UIImage(named: "Speech_Bubble")?.withRenderingMode(.alwaysTemplate)
        chatImageView.tintColor = .lightGray
        // Remove observer
        observePath.removeObserver(withHandle: obs)
        label.removeFromSuperview()
        cancelView.removeFromSuperview()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cancelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeThisFeed)))
        
        //come aggiungere una gesture ad una view:
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToSelectedProfile))
        tap.delegate = self
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tap)
    }
    
    func goToSelectedProfile() {
        let profileImage = profileImageView.image
        delegate?.moveToSelectedProfile!(withID: (feed?.authorId)!, profilePhoto : profileImage, withName: (feed?.name)!)
    }
    
    func removeThisFeed(){
        presentationDelegate?.presentPopoverForFeed!(withID: (feed?.feedId)!,idChat: (feed?.chatID)! , sender: cancelView)
    }
    
    func observeIfAddCancelView() {
        let observePath = FIRDatabase.database().reference().child("Feeds").child((feed?.feedId)!)
        observePath.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let me = UserDefaults.standard.object(forKey: "uid") as? String
                if let authorID = dict["authorID"] as? String {
                    if authorID == me {
                        self.addCancelView()
                        
                        //approfittiamone per settare anche che è una mia chat nel core data
                        let context = AllContext.mainContext
                        let chat = Chat.chatExisting(hashtag: (self.feed?.chatID)!, context: context!)
                        if chat?.isMyChat != true {
                            do {
                                try context?.save()
                            }catch {
                                print("error")
                            }
                        }
                    }
                }
            }
        })
        
    }
    
    let label: UILabel = {
        let label = UILabel()
        // label.font = .boldSystemFont(ofSize: 20)
        label.text = "⌄"
        label.textColor = UIColor.lightGray
        return label
        
    }()
    //viene aggiunta una view in alto a sinistra per cancellare il post
    func addCancelView() {
        contentView.addSubview(cancelView)
 
        let label: UILabel = {
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 20)
            label.text = "⌄"
            label.textColor = UIColor.lightGray
            return label
            
        }()
        
        cancelView.addSubview(label)
        
        addConstraintsWithFormat("H:[v0(24)]-0-|", views: cancelView)
        addConstraintsWithFormat("V:|-5-[v0(30)]", views: cancelView)
        
        cancelView.addConstraintsWithFormat("H:|[v0]|", views: label)
        cancelView.addConstraintsWithFormat("V:|[v0]|", views: label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Inizializzati come piaccino a te ;)
    var constrainsForMedia = [NSLayoutConstraint]()
    var constrainsForTextOnly = [NSLayoutConstraint]()
    var labels = [UIView]()
    

    let me = UserDefaults.standard.object(forKey: "uid") as? String
    
    var feed: Feed?{
        didSet{
            observeIfAddCancelView()
            setUpFeed()
        }
    }
    
    // MARK: - Outlets
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let insertionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let insertionisName: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 12)
        return label
    }()
    
    let feedTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)
        return label
    }()
    
    let date: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.init(name: "AppleGothic", size: 9)
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.init(name: "AppleGothic", size: 12)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .right
        return label
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 14)
        label.numberOfLines = 30
        return label
    }()
    
    let pages: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        return pageControl
    }()
    
    let likeCountLabel: UIButton = {
        let label = UIButton()
        label.setTitle("0", for: .normal)
        label.setTitleColor(.lightGray, for: .normal)
        label.titleLabel?.font = UIFont.init(name: "AppleGothic", size: 16)
        return label
    }()
    
    let likeImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "Thumb_Up")?.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = .lightGray
        return imgView
    }()
    
    let chatImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "Speech_Bubble")?.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = .lightGray
        return imgView
    }()
    
    let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let like: UIButton = {
        let button = UIButton()
        button.setTitle("Like", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "AppleGothic", size: 16)
        return button
    }()
    
    let goToChat: UIButton = {
        let button = UIButton()
        button.setTitle("Join Chat", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        return button
    }()
    
    let cancelView = UIView()
    
    
    // MARK: - Private Implementatios
    
    private func addLikeObserver(){
        observePath = FIRDatabase.database().reference().child("Feeds").child((feed?.feedId)!)
        obs = observePath.observe(.value, with: { (snapshot) in
            let changed = snapshot.value as? [String: Any]
            if let likes = changed?["Likes"] as? [String:String]{
                self.feed?.likes = likes
                //self.likeCountLabel.text = String((self.feed?.likes?.count)!)
         
                    if (self.feed?.likes?[self.me!]) != nil {
                        self.like.setTitleColor(UIColor(red: 25/255, green: 130/255, blue: 255/255, alpha: 1), for: .normal)
                        self.like.setTitle("Like", for: .normal)
                        self.likeCountLabel.setTitle(String((self.feed?.likes?.count)!), for: .normal)
                        self.likeCountLabel.setTitleColor(UIColor(red: 25/255, green: 130/255, blue: 255/255, alpha: 1), for: .normal)
                        self.likeImageView.image = UIImage(named: "Thumb_Up")?.withRenderingMode(.alwaysTemplate)
                        self.likeImageView.tintColor = UIColor(red: 25/255, green: 130/255, blue: 255/255, alpha: 1)
                    }else{
                        self.like.setTitleColor(.lightGray, for: .normal)
                        self.like.setTitle("Like", for: .normal)
                        self.likeCountLabel.setTitle(String((self.feed?.likes?.count)!), for: .normal)
                        self.likeCountLabel.setTitleColor(.lightGray, for: .normal)
                        self.likeImageView.image = UIImage(named: "Thumb_Up")?.withRenderingMode(.alwaysTemplate)
                        self.likeImageView.tintColor = .lightGray
                    }
                
            }else{
                self.feed?.likes = [:]
                self.likeCountLabel.setTitle("0", for: .normal)
            }
        })
    }

    func showAllLikes(){
        print("show likers...")
        presentationDelegate?.presentLikersForFeed!(whitLikes: feed?.likes ?? [:])
    }
    
    private func setUpFeed(){
        // Gesture Recognizers
        goToChat.addTarget(self, action: #selector(buttonDelegateFunc), for: UIControlEvents.touchUpInside)
        like.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(likeIt)))
        likeCountLabel.addTarget(self, action: #selector(showAllLikes), for: .touchUpInside)
        
        // Default item's background color
        contentView.backgroundColor = .white
        
        setConstraints()
        
        feedTitle.text = feed?.chatName
        
        insertionisName.text = feed?.name
        
        let  timeInterval = feed?.date
        let date2 = Date(timeIntervalSince1970: timeInterval!/10000000)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd' 'HH:mm")
        let stringDate = dateFormatter.string(from: date2)
        let city = feed?.locationInfo?["city"] as? String ?? ""
        let state = feed?.locationInfo?["state"] as? String ?? ""
        date.text = "\(stringDate) • \(city), \(state)"
        date.sizeToFit()
        textLabel.text = feed?.text
        likeCountLabel.setTitle(String((feed?.likes?.count)!), for: .normal)
        
        categoryLabel.text = feed?.category
        categoryLabel.textColor = setColor(forCategory: (feed?.category)!)
        
        //categoryLabel.backgroundColor = setColor(forCategory: (feed?.category)!)
        
        //let hud = MBProgressHUD.showAdded(to: profileImageView, animated: true)
        //hud.label.text = "Loading..."
        let fileUrl = NSURL(string: (feed?.profileImageUrl)!)
        if let image = delegate?.restoreImage!(urlOfImage: fileUrl!){
            profileImageView.image = image
            
        }else {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                if let data = try? Data(contentsOf: fileUrl! as URL){
                    DispatchQueue.main.async {
                        let image: UIImage = UIImage(data: data)!
                        self.profileImageView.image = image
                        self.delegate?.finishFatchImage?(obj: image, key: fileUrl! , cost: data.count)
                    }
                }
            }
        }
        
        if feed?.mediaItemsUrl?.count != nil{
            let numberOfPages = (feed?.mediaItemsUrl?.count)!
            pages.numberOfPages = numberOfPages
            loadFirstPageImage()
        }
        
        addLikeObserver()
        
    }
    
    func buttonDelegateFunc(){
        delegate?.goToSelectedChat!(chatID: (feed?.chatID)!, chatName: (feed?.chatName)!)
    }
    
    func loadFirstPageImage(){
        //pages.currentPage = 0
        //let hud = MBProgressHUD.showAdded(to: insertionImageView, animated: true)
        //hud.label.text = "Loading..."
        let mediaUrl = NSURL(string: (feed?.mediaItemsUrl?[0])!)
        if let image = delegate?.restoreImage!(urlOfImage: mediaUrl! as NSURL){
            insertionImageView.image = image
        }else {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                if let data = try? Data(contentsOf: mediaUrl! as URL){
                    DispatchQueue.main.async {
                        let image: UIImage = UIImage(data: data)!
                        //MBProgressHUD.hide(for: self.insertionImageView, animated: true)
                        
                        self.insertionImageView.image = image
                        self.delegate?.finishFatchImage?(obj: image, key: mediaUrl! , cost: data.count)
                    }
                }
            }
        }
        
        for url in (feed?.mediaItemsUrl)! {
            let mediaUrl = NSURL(string: (url))
            if (delegate?.restoreImage!(urlOfImage: mediaUrl! as NSURL)) != nil {
                // Don't do nothings
            }else {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    if let data = try? Data(contentsOf: mediaUrl! as URL){
                        DispatchQueue.main.async {
                            let image: UIImage = UIImage(data: data)!
                            self.delegate?.finishFatchImage?(obj: image, key: mediaUrl! , cost: data.count)
                        }
                    }
                }
            }
        }
        
    }
    
    func rightSwipe(){
        if (pages.currentPage + 1) < (feed?.mediaItemsUrl?.count)! {
            pages.currentPage = pages.currentPage + 1
            let mediaUrl = URL(string: (feed?.mediaItemsUrl?[pages.currentPage])!)
            if let data = try? Data(contentsOf: mediaUrl!){
                let image: UIImage = UIImage(data: data)!
                self.insertionImageView.image = image
            }
        }
    }
    
    func leftSwipe(){
        if (pages.currentPage - 1) >= 0 {
            pages.currentPage = pages.currentPage - 1
            let mediaUrl = URL(string: (feed?.mediaItemsUrl?[pages.currentPage])!)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                if let data = try? Data(contentsOf: mediaUrl!){
                    DispatchQueue.main.async {
                        
                        let image: UIImage = UIImage(data: data)!
                        self.insertionImageView.image = image
                    }
                }
            }
        }
    }
   // UserDefaults.standard.set(user!.uid, forKey: "uid")

    func likeIt(){
        if let me = UserDefaults.standard.object(forKey: "uid") as? String{
            if (feed?.likes?[me]) != nil {
                // I have already left a like, i want remove it
                FIRDatabase.database().reference().child("Feeds").child("\((feed?.feedId)!)").child("Likes").child(me).removeValue()
                self.like.setTitleColor(.lightGray, for: .normal)
                self.like.setTitle("Like", for: UIControlState.normal)
                self.likeCountLabel.setTitleColor(.lightGray, for: .normal)
                self.likeImageView.image = UIImage(named: "Thumb_Up")?.withRenderingMode(.alwaysTemplate)
                self.likeImageView.tintColor = .lightGray
            }else{
                // I don't have left a like, i want leave one
                feed?.likes?[me] = "1"
                FIRDatabase.database().reference().child("Feeds").child("\((feed?.feedId)!)").child("Likes").updateChildValues((feed?.likes)!)
                self.like.setTitleColor(UIColor(red: 25/255, green: 130/255, blue: 255/255, alpha: 1), for: .normal)
                self.like.setTitle("Like", for: UIControlState.normal)
                self.likeCountLabel.setTitleColor(UIColor(red: 25/255, green: 130/255, blue: 255/255, alpha: 1), for: .normal)
                self.likeImageView.image = UIImage(named: "Thumb_Up_Filled")?.withRenderingMode(.alwaysTemplate)
                self.likeImageView.tintColor = UIColor(red: 25/255, green: 130/255, blue: 255/255, alpha: 1)
            }
        }
    }
    
    private func setConstraints(){
        
        constrainsForTextOnly = [
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            feedTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            feedTitle.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            insertionisName.topAnchor.constraint(equalTo: feedTitle.bottomAnchor, constant: 4),
            insertionisName.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            date.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            date.topAnchor.constraint(equalTo: insertionisName.bottomAnchor, constant: 4),
            
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 34),
            categoryLabel.widthAnchor.constraint(equalToConstant: 130),
            categoryLabel.heightAnchor.constraint(equalToConstant: 20),
            
            textLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            likeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            likeImageView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 7),
            likeImageView.widthAnchor.constraint(equalToConstant: 20),
            likeImageView.heightAnchor.constraint(equalToConstant: 20),
            
            likeCountLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 4),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeImageView.leadingAnchor, constant: 15),
            likeCountLabel.widthAnchor.constraint(equalToConstant: 44),
            likeCountLabel.heightAnchor.constraint(equalToConstant: 30),
            
            like.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 5),
            like.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 4),
            like.widthAnchor.constraint(equalToConstant: 30),
            like.heightAnchor.constraint(equalToConstant: 30),
            
            chatImageView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 7),
            chatImageView.trailingAnchor.constraint(equalTo: goToChat.leadingAnchor, constant: 10),
            chatImageView.widthAnchor.constraint(equalToConstant: 20),
            chatImageView.heightAnchor.constraint(equalToConstant: 20),
            
            goToChat.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 4),
            goToChat.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            goToChat.widthAnchor.constraint(equalToConstant: 100)
            
        ]
        
        constrainsForMedia = [
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            feedTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            feedTitle.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            insertionisName.topAnchor.constraint(equalTo: feedTitle.bottomAnchor, constant: 4),
            insertionisName.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            
            date.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            date.topAnchor.constraint(equalTo: insertionisName.bottomAnchor, constant: 4),
            
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 34),
            categoryLabel.widthAnchor.constraint(equalToConstant: 130),
            categoryLabel.heightAnchor.constraint(equalToConstant: 20),
            
            textLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            insertionImageView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 7),
            insertionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            insertionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            insertionImageView.heightAnchor.constraint(equalToConstant: 200),
            
            likeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            likeImageView.topAnchor.constraint(equalTo: insertionImageView.bottomAnchor, constant: 7),
            likeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            likeImageView.widthAnchor.constraint(equalToConstant: 20),
            likeImageView.heightAnchor.constraint(equalToConstant: 20),
            
            likeCountLabel.topAnchor.constraint(equalTo: insertionImageView.bottomAnchor, constant: 4),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeImageView.leadingAnchor, constant: 15),
            likeCountLabel.widthAnchor.constraint(equalToConstant: 44),
            likeCountLabel.heightAnchor.constraint(equalToConstant: 30),
            
            like.topAnchor.constraint(equalTo: insertionImageView.bottomAnchor, constant: 5),
            like.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 4),
            like.widthAnchor.constraint(equalToConstant: 30),
            like.heightAnchor.constraint(equalToConstant: 30),
            
            chatImageView.topAnchor.constraint(equalTo: insertionImageView.bottomAnchor, constant: 7),
            chatImageView.trailingAnchor.constraint(equalTo: goToChat.leadingAnchor, constant: 10),
            chatImageView.widthAnchor.constraint(equalToConstant: 20),
            chatImageView.heightAnchor.constraint(equalToConstant: 20),
            
            goToChat.topAnchor.constraint(equalTo: insertionImageView.bottomAnchor, constant: 4),
            goToChat.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            goToChat.widthAnchor.constraint(equalToConstant: 100)

            
        ]
        switch (feed?.media)! {
        case "txt":
            labels = [profileImageView, insertionisName, date,categoryLabel,textLabel, chatImageView, likeCountLabel, likeImageView,like,goToChat, feedTitle]
            
            //NSLayoutConstraint.deactivate(constrainsForMedia)
            
            for label in labels {
                
                label.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(label)
            }
            
            NSLayoutConstraint.activate(constrainsForTextOnly)
            
        case "img":
            labels = [profileImageView, insertionisName, date,categoryLabel,textLabel, chatImageView, likeCountLabel, likeImageView,like,goToChat, insertionImageView, feedTitle]
            
            //NSLayoutConstraint.deactivate(constrainsForTextOnly)
            
            for label in labels {
                
                label.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(label)
            }
            
            NSLayoutConstraint.activate(constrainsForMedia)
        case "mov":
            break
        default:
            break
        }
    }
}
