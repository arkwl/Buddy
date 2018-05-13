//
//  MessageViewController.swift
//  OfficeBuddy
//
//  Created by Alexa Rockwell on 2/7/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    @IBOutlet weak var messageText: UITextView!
    var message:String?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        messageText.text = message
    }
}
