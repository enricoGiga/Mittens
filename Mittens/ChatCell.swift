//
//  ChatCell.swift
//  Mittens
//
//  Created by enrico  gigante on 03/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()
//        isMyChatLabel.removeFromSuperview()
        
    }
    //MARK: - Outlet

    let chatNameLabel = UILabel()
    let lastSenderNameLabel = UILabel()
    let lastMessageLabel = UILabel()
    let partecipantsLabel = UILabel()
    
    //photo gruppo
    let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        partecipantsLabel.textAlignment = .right
        chatNameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)
        lastSenderNameLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightLight)
        lastMessageLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightLight)
        partecipantsLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightLight)
        lastMessageLabel.textColor = UIColor.gray
        let labels = [chatNameLabel, lastSenderNameLabel, lastMessageLabel, partecipantsLabel]
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
        }
    
        photoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoView)
    
        let constrains: [NSLayoutConstraint] = [
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            photoView.widthAnchor.constraint(equalToConstant: 60),
            photoView.heightAnchor.constraint(equalToConstant: 60),
            
            chatNameLabel.leadingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: 10),
            chatNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            chatNameLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            lastSenderNameLabel.topAnchor.constraint(equalTo: chatNameLabel.bottomAnchor),
            lastSenderNameLabel.leadingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: 10),
            lastSenderNameLabel.heightAnchor.constraint(equalTo: chatNameLabel.heightAnchor),
            
            partecipantsLabel.topAnchor.constraint(equalTo: chatNameLabel.bottomAnchor),
            partecipantsLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            partecipantsLabel.heightAnchor.constraint(equalTo: lastSenderNameLabel.heightAnchor),
            partecipantsLabel.leadingAnchor.constraint(equalTo: lastSenderNameLabel.trailingAnchor),
            
            lastMessageLabel.topAnchor.constraint(equalTo: lastSenderNameLabel.bottomAnchor),
            lastMessageLabel.leadingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: 10),
            lastMessageLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            lastMessageLabel.heightAnchor.constraint(equalTo: chatNameLabel.heightAnchor),
        ]
        
        NSLayoutConstraint.activate(constrains)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
