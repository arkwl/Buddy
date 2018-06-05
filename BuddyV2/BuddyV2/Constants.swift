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
    }
}
