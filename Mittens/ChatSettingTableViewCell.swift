//
//  ChatSettingTableViewCell.swift
//  mittens
//
//  Created by Cristian Turetta on 21/10/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import UIKit
import Firebase

class ChatSettingTableViewCell: UITableViewCell {

    var chat: Chat?
    var status: Bool?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "AppleGhotic", size: 16)
        return label
    }()
    
    let switcher = UISwitch()
    
    var title: String?{
        didSet{
            switch title! {
            case "Notifications":
                // Check if notifications are active for this chat
                FIRDatabase.database().reference().child("Chats").child((chat?.hashtagID)!).child("joined").observeSingleEvent(of: .value, with: { (snapshot) in
                    let users = snapshot.value as! [String:String]
                    let me = UserDefaults.standard.object(forKey: "uid") as! String
                    if (users[me] != nil) {
                        self.switcher.isOn = true
                    }else{
                        self.switcher.isOn = false
                    }
                })
                
                switcher.addTarget(self, action: #selector(valueIsChanged(sender:)), for: .valueChanged)
                
                contentView.addSubview(titleLabel)
                contentView.addSubview(switcher)
                
                addConstraintsWithFormat("H:|-10-[v0]", views: titleLabel)
                addConstraintsWithFormat("V:|[v0]|", views: titleLabel)
                
                switcher.translatesAutoresizingMaskIntoConstraints = false
                switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
                switcher.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
                
                titleLabel.text = title
                
            case "Media item shared":
                contentView.addSubview(titleLabel)
                
                addConstraintsWithFormat("H:|-10-[v0]", views: titleLabel)
                addConstraintsWithFormat("V:|[v0]|", views: titleLabel)
                
                titleLabel.text = title
                
            default:
                break
            }
        }
    }
    
    func valueIsChanged(sender: UISwitch){
        let me = UserDefaults.standard.object(forKey: "uid") as! String
        if sender.isOn {
            // Active Notifications
            let userDefault = UserDef()
            let token = userDefault.returnMyToken()
            FIRDatabase.database().reference().child("Chats").child((chat?.hashtagID)!).child("joined").updateChildValues([me:token!])
        }else if !sender.isOn{
            // Mute Notifications
            FIRDatabase.database().reference().child("Chats").child((chat?.hashtagID)!).child("joined").child(me).removeValue()
        }
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
