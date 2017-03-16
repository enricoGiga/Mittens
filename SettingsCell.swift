//
//  SettingsCell.swift
//  mittens
//
//  Created by enrico  gigante on 21/10/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit

class SettingsCell: UICollectionViewCell {
    let title = UILabel()
    let impostazioni = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        contentView.backgroundColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
          title.font = .boldSystemFont(ofSize: 20)
        title.text = "Impostazioni"
        
        impostazioni.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(impostazioni)
        impostazioni.image = UIImage(named: "settings")
        let constrains: [NSLayoutConstraint] = [
            impostazioni.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            impostazioni.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
     
            impostazioni.widthAnchor.constraint(equalToConstant: 40),
            impostazioni.heightAnchor.constraint(equalToConstant: 40),
            impostazioni.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            title.heightAnchor.constraint(equalTo: impostazioni.heightAnchor),
            title.leadingAnchor.constraint(equalTo: impostazioni.trailingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            
        ]
        NSLayoutConstraint.activate(constrains)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
