//
//  Constants.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 6/4/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import Foundation
import Firebase

struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
        static let databaseUsers = databaseRoot.child("users")
        static let databaseMessages = databaseRoot.child("messages")
    }
}

struct API{
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_CLIENT_ID = "587ffdb411e4444db03e5e5eccc2e5e2"
    static let INSTAGRAM_CLIENTSERCRET = "6b4a0129eca9446ca4cb05e99cefdd15"
    static let INSTAGRAM_REDIRECT_URI = "http://buddyios.com"
    static let INSTAGRAM_ACCESS_TOKEN = "access_token"
    static let INSTAGRAM_SCOPE = "follower_list+public_content" /* add whatever scope you need https://www.instagram.com/developer/authorization/ */
}
