//
//  HeaderCell.swift
//  mittens
//
//  Created by enrico  gigante on 21/10/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit

class HeaderCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
