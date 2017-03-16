//
//  MyProfileViewController.swift
//  Mittens
//
//  Created by enrico  gigante on 02/10/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit
import MapKit
import QBImagePickerController

class MyProfileViewController: ProfileViewController, QBImagePickerControllerDelegate{
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Retrive profile photo
        let myUid = UserDefaults.standard.object(forKey: "uid") as? String
        let contact = Contact.isContactExisting(withId: myUid!, inContext: context!)
        let data = contact?.profilePhoto as! Data
        let image = UIImage(data: data)
        collectionView?.register(SettingsCell.self, forCellWithReuseIdentifier: "settings")
        
        name = contact?.displayName
        profileImage = image!
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        case 2:
            return feeds.count
        default:
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile", for: indexPath) as? FirstCollectionViewCell
            cell?.delegate = self
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
        case 1: let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settings", for: indexPath) as? SettingsCell
        return cell!
        case 2:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "feed", for: indexPath) as! FeedCollectionViewCell
            item.profileImageView.isUserInteractionEnabled = false
            item.delegate = self
            item.presentationDelegate = self
            item.presentationDelegate = self
            item.feed = feeds[indexPath.item]
            return item
            
        default : break
            
        }
        return UICollectionViewCell()

    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: view.bounds.width, height: 270)
        case 1:
            return CGSize(width: view.bounds.width, height: 50)
        
        case 2:
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
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let settingVC = SettingsCollectionVC()
            navigationController?.pushViewController(settingVC, animated: true)
        }
    }

    // MARK: - PresentationDelegate Methods
    func presentPickerController(){
        setCoverImage()
    }
    
    func setCoverImage(){
        let pickerCointroller = QBImagePickerController()
        pickerCointroller.delegate = self
        pickerCointroller.allowsMultipleSelection = false
        pickerCointroller.maximumNumberOfSelection = 1
        pickerCointroller.showsNumberOfSelectedAssets = true
        
        present(pickerCointroller, animated: true, completion: nil)
    }
    
    // MARK: - PickerControllerDelegate Methods
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didSelect asset: PHAsset!) {
        print("selected: \(asset)\n\n")
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        
        if !assets.isEmpty {
            for asset in assets{
                guard let metadata = asset as? PHAsset else{return}
                manager.requestImage(for: metadata, targetSize: CGSize(width: Double(metadata.pixelWidth), height: Double(metadata.pixelHeight)), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    
                })
            }
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        dismiss(animated: true, completion: nil)
    }


}
