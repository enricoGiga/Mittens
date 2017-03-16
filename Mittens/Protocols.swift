//
//  protocols.swift
//  Mittens
//
//  Created by enrico  gigante on 25/09/16.
//  Copyright © 2016 enrico  gigante. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CustomDelegate{
    @objc optional func goToSelectedChat(chatID: String, chatName: String)
    @objc optional func moveToSelectedProfile(withID id: String, profilePhoto: UIImage?, withName: String)
    @objc optional func finishFatchImage(obj: UIImage, key: NSURL, cost: Int)
    @objc optional func restoreImage(urlOfImage url: NSURL) -> UIImage?
}

@objc protocol PresentationDelegate{
    @objc optional func presentPickerController()
    @objc optional func presentPopoverForFeed(withID idFeed: String, idChat: String, sender: UIView)
    @objc optional func removeFeed(withID idFeed: String, idChat: String)
    @objc optional func presentLikersForFeed(whitLikes likes: [String:String])
}

@objc protocol MoveToPageOneDelegate{
    @objc optional func createNewPost()
}

@objc protocol isMyChat {
    @objc optional func isMy()
}
