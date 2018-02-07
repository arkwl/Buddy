//
//  MessageViewController.swift
//  OfficeBuddy
//
//  Created by Alexa Rockwell on 2/7/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    var message:String?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //messageText.text = message
    }
}
