//
//  FirstCollectionViewCell.swift
//  Mittens
//
//  Created by enrico  gigante on 29/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit
import CoreData

class FirstCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PresentationDelegate?
    let context = AllContext.mainContext
    
    let modifyCoverPhotoButton: UIButton = {
        let imageView = UIButton()
        let image = UIImage(named: "edit")?.withRenderingMode(.alwaysTemplate)
        imageView.setBackgroundImage(image, for: .normal)
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 18)
        label.textAlignment = .center
        return label
    }()
    
    let photoView: UIImageView = {
        let photoView = UIImageView()
        photoView.layer.borderWidth = 1.8
        photoView.layer.borderColor = UIColor.white.cgColor
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = 40
        photoView.contentMode = .scaleAspectFill
        return photoView
    }()
    
    let coverImage = UIView()
    
    let likeImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "Thumb_Up")?.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = .lightGray
        return imgView
    }()
    
    let totalLike: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 16)
        label.textColor = .lightGray
        label.text = "0 Likes ricevuti"
        return label
    }()
    
    let feedImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "feedIcon")?.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = .lightGray
        return imgView
    }()
    
    let totalFeed: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 16)
        label.textColor = .lightGray
        label.text = "0 Inserzioni pubblicate"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        modifyCoverPhotoButton.addTarget(self, action: #selector(setCoverImage), for: .touchUpInside)
        
        // settiamo i constrains
        let labels = [nameLabel, coverImage, totalLike, likeImageView, photoView, totalFeed, feedImageView, modifyCoverPhotoButton]
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }
        
        coverImage.backgroundColor = UIColor(patternImage: UIImage(named: "sfondo2")!)
    
        contentView.backgroundColor = UIColor.white
        let constraints: [NSLayoutConstraint] =
            
        [
            modifyCoverPhotoButton.topAnchor.constraint(equalTo: (contentView.topAnchor), constant: 5),
            modifyCoverPhotoButton.rightAnchor.constraint(equalTo: (contentView.rightAnchor), constant: -5),
            modifyCoverPhotoButton.heightAnchor.constraint(equalToConstant: 30),
            modifyCoverPhotoButton.widthAnchor.constraint(equalToConstant: 30),
            
            coverImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImage.heightAnchor.constraint(equalToConstant: 160),
            
            photoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100),
            photoView.heightAnchor.constraint(equalToConstant: 80),
            photoView.widthAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            totalLike.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            totalLike.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 15),
            
            likeImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            likeImageView.trailingAnchor.constraint(equalTo: totalLike.leadingAnchor, constant: -8),
            likeImageView.widthAnchor.constraint(equalToConstant: 20),
            likeImageView.heightAnchor.constraint(equalToConstant: 20),
            
            totalFeed.topAnchor.constraint(equalTo: totalLike.bottomAnchor, constant: 4),
            totalFeed.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
            
            feedImageView.topAnchor.constraint(equalTo: totalLike.bottomAnchor, constant: 3),
            feedImageView.trailingAnchor.constraint(equalTo: totalFeed.leadingAnchor, constant: -8),
            feedImageView.widthAnchor.constraint(equalToConstant: 20),
            feedImageView.heightAnchor.constraint(equalToConstant: 20)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK 
    func setCoverImage(){
        delegate?.presentPickerController!()
    }
}
