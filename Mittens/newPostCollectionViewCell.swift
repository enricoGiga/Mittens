//
//  newPostCollectionViewCell.swift
//  Mittens
//
//  Created by Cristian Turetta on 25/09/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class newPostCollectionViewCell: UICollectionViewCell {
    
    weak var delegateForMoveToPageOne: MoveToPageOneDelegate?
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .red
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "Inserisci un Annuncio..."
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(profileImageView)
        contentView.addSubview(label)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 90).isActive = true
        label.widthAnchor.constraint(equalToConstant: 250).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        getMyProfileImage()
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToNewFeedForm)))
        
    }
    
    func moveToNewFeedForm() {
        delegateForMoveToPageOne?.createNewPost!()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getMyProfileImage(){
        guard let context = AllContext.mainContext  else {print ("error core data"); return }
        guard let myUserID = UserDefaults.standard.object(forKey: "uid") as? String else {return}
        let mycontext = context
        let contact = Contact.isContactExisting(withId: myUserID , inContext: mycontext)
        guard let dataImg = contact?.profilePhoto as? Data else {return}
        self.profileImageView.image = UIImage(data: dataImg)
        //self.myName = contact?.displayName
        
    }
}
