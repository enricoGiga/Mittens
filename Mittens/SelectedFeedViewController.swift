//
//  SelectedFeedCollectionViewController.swift
//  Mittens
//
//  Created by Cristian Turetta on 29/09/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import GoogleMobileAds

private let reuseIdentifier = "Cell"

class SelectedFeedController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CustomDelegate{
    
    // MARK: - Variables
    var feed: Feed?
    var isWhithMediaItem = false
    
    // MARK: - ImageDelegation
    weak var cacheDelegate: CustomDelegate?
    
    // MARK: - Outlets
    var collectionView: UICollectionView?
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let insertionisName: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 18)
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 12)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    let date: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.init(name: "AppleGothic", size: 9)
        return label
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 14)
        label.numberOfLines = 30
        return label
    }()
    
    // MARK: - Overrided Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        view.addSubview(collectionView!)
        view.addConstraintsWithFormat("H:|[v0]|", views: collectionView!)
        view.addConstraintsWithFormat("V:|[v0]|", views: collectionView!)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(MediaCollectionViewCell.self, forCellWithReuseIdentifier: "mediaCell")
        self.collectionView!.register(AdMobCollectionViewCell.self, forCellWithReuseIdentifier: "ad")
        
        // looking for media items
        if feed?.mediaItemsUrl != nil{
            isWhithMediaItem = true
        }
        
        // Set Title
        title = feed?.chatName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isWhithMediaItem {return 3 + (feed?.mediaItemsUrl?.count)!} else {return 3}
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = .white
        
        switch indexPath.item {
        case 0:
            // In the first row: name and prifile pic of the insertionist
            cell.contentView.addSubview(profileImageView)
            cell.contentView.addSubview(insertionisName)
            
            // Adding constraints
            cell.addConstraintsWithFormat("H:|-10-[v0(60)]", views: profileImageView)
            cell.addConstraintsWithFormat("V:|-10-[v0(60)]", views: profileImageView)
            
            cell.addConstraintsWithFormat("H:[v0]-10-[v1]", views: profileImageView, insertionisName)
            cell.addConstraintsWithFormat("V:|-30-[v0]", views: insertionisName)
            
            // Setting values
            profileImageView.image = cacheDelegate?.restoreImage!(urlOfImage: NSURL(string: (feed?.profileImageUrl)!)!)
            insertionisName.text = feed?.name
            
            return cell
        case 1:
            // In the second row: advertisment
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ad", for: indexPath) as! AdMobCollectionViewCell

            cell.adView?.adUnitID = "ca-app-pub-3940256099942544/2934735716" //example advetisment key
            cell.adView?.rootViewController = self
            cell.adView?.load(GADRequest())
            
            return cell
        case 2:
            // In the third row: feed's cerations date and feed text
            cell.contentView.addSubview(date)
            cell.contentView.addSubview(textLabel)
            
            // Adding constriants
            cell.addConstraintsWithFormat("H:[v0]-10-|", views: date)
            cell.addConstraintsWithFormat("V:|-10-[v0]", views: date)
            
            cell.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: textLabel)
            cell.addConstraintsWithFormat("V:[v0]-4-[v1]", views: date, textLabel)
            
            // Setting values
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
            
            return cell
        default:
            if isWhithMediaItem {
                // In the others row: Feed's images
                let mediaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as! MediaCollectionViewCell
                
                let mediaUrl = NSURL(string: (feed?.mediaItemsUrl?[(indexPath.item - 3)])!)
                if let feedImage = cacheDelegate?.restoreImage!(urlOfImage: mediaUrl!){
                    mediaCell.imageSet = feedImage
                    return mediaCell
                }else{
                    if let data = try? Data(contentsOf: URL(string: (self.feed?.mediaItemsUrl?[(indexPath.item - 3)])!)!){
                        DispatchQueue.main.async {
                            let image: UIImage = UIImage(data: data)!
                            mediaCell.imageSet = image
                            self.cacheDelegate?.finishFatchImage?(obj: image, key: mediaUrl!, cost: data.count)
                        }
                    }
                }
                
                return mediaCell
            }else{ break }
        }
        
        return cell
    }

    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.item {
        case 0:
            return CGSize(width: view.frame.width, height: 80)
        case 1:
            return CGSize(width: view.frame.width, height: 50)
        case 2:
            let defaultSize = CGSize(width: view.frame.width - 20, height: 50000)
            guard let text = feed?.text else { return defaultSize }
            let surroundings = NSString(string: text).boundingRect(
                with: defaultSize,
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)],
                context: nil)
            return CGSize(width: view.frame.width, height: surroundings.height + date.frame.height + 50)
        default:
            let mediaUrl = NSURL(string: (feed?.mediaItemsUrl?[(indexPath.item - 3)])!)
            if let feedImage = cacheDelegate?.restoreImage!(urlOfImage: mediaUrl!){
                let ratio = feedImage.size.width / feedImage.size.height
                
                let cellHeight = view.bounds.width / ratio
                return CGSize(width: view.frame.width, height: cellHeight)
            }
            return CGSize(width: view.frame.width, height: 0)
        }
    }
}
