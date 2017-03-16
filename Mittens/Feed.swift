//
//  File.swift
//  Home
//
//  Created by Cristian Turetta on 10/09/16.
//  Copyright © 2016 Cristian Turetta. All rights reserved.
//

import Foundation
import UIKit

class Feed{
    var feedId: String?
    var name: String?
    var profileImageUrl: String?
    var text: String?
    var date: TimeInterval?
    var category: String?
    var media: String?
    var mediaItemsUrl: [String]?
    var likes: [String:String]?
    var chatID: String?
    var chatName: String?
    var locationInfo: NSDictionary?
    var authorId: String?
    init(
        feedWithId id: String,
        InsertionistName insertionist: String,
        profileImageUrl url:String,
        publicaionDate date: TimeInterval,
        forCategory category: String,
        media item: String,
        mediasUrl mediaItemsUrl: [String]?,
        feedText txt: String,
        likeList likes: [String:String]?,
        chatID: String,
        chatName: String,
        locationInfo: NSDictionary,
        authorId: String?
        ) {
        
        self.feedId = id
        self.name = insertionist
        self.profileImageUrl = url
        self.category = category
        self.date = date
        self.text = txt
        self.media = item
        self.mediaItemsUrl = mediaItemsUrl
        self.likes = likes
        self.chatID = chatID
        self.chatName = chatName
        self.locationInfo = locationInfo
        self.authorId = authorId
    }
    
    init() {
        
    }
}
