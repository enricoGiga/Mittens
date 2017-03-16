//
//  PersonTableViewCell.swift
//  mittens
//
//  Created by Cristian Turetta on 19/10/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import CoreData

class PersonTableViewCell: UITableViewCell {

    var isGroupAdmin: Bool?
    var contact: Contact?{
        didSet{
            setupCell()
            if (isGroupAdmin ?? false) {
                addAdminTag()
            }
            profileImageView.image = UIImage(data: (contact?.profilePhoto)! as Data)
            displayName.text = contact?.displayName
        }
    }
    
    var person: Person?{
        didSet{
            setupCell()
            profileImageView.image = person?.profileImage
            displayName.text = person?.displayName
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let displayName: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 16)
        return label
    }()
    
    let adminLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGothic", size: 12)
        label.textColor = .lightGray
        label.text = "Admin"
        return label
    }()
    
    private func setupCell(){
        contentView.addSubview(profileImageView)
        contentView.addSubview(displayName)
        
        addConstraintsWithFormat("H:|-10-[v0(50)]", views: profileImageView)
        addConstraintsWithFormat("V:|-10-[v0(50)]-10-|", views: profileImageView)
        
        addConstraintsWithFormat("H:[v0]-10-[v1]", views: profileImageView, displayName)
        addConstraintsWithFormat("V:|-25-[v0]", views: displayName)
        
    }
    
    private func addAdminTag(){
        contentView.addSubview(adminLabel)
        adminLabel.translatesAutoresizingMaskIntoConstraints = false
        adminLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        adminLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
