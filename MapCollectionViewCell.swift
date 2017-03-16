//
//  MapCollectionViewCell.swift
//  Mittens
//
//  Created by Cristian Turetta on 06/10/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit
import MapKit

class MapCollectionViewCell: UICollectionViewCell, MKMapViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
