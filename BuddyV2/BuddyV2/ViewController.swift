//
//  ViewController.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 5/31/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.showsStatistics = true
        let scene = SCNScene()
        self.sceneView.scene = scene
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func click(_ sender: UIButton) {
        print("Click")
    }
}

