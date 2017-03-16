//
//  AdMobCollectionViewCell.swift
//  mittens
//
//  Created by Cristian Turetta on 19/10/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdMobCollectionViewCell: UICollectionViewCell {
    var adView: GADBannerView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Configuration
        adView = GADBannerView()
        contentView.addSubview(adView!)
        
        // Constraint
        addConstraintsWithFormat("H:|[v0]|", views: adView!)
        addConstraintsWithFormat("V:|[v0]|", views: adView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
