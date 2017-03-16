//
//  MediaCollectionViewCell.swift
//  Mittens
//
//  Created by Cristian Turetta on 30/09/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
    
    var imageSet: UIImage?{
        didSet{
            setupCell()
        }
    }
    var FeedImage = UIImageView()
        
    override func prepareForReuse() {
        FeedImage.image = nil
    }
    
    func setupCell(){
        contentView.backgroundColor = .white
        FeedImage.image = imageSet
        FeedImage.contentMode = .scaleAspectFit
        contentView.addSubview(FeedImage)        
        addConstraintsWithFormat("H:|[v0]|", views: FeedImage)
        addConstraintsWithFormat("V:|[v0]|", views: FeedImage)
    }
    
}
