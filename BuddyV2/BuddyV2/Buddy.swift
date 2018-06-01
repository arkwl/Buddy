//
//  Buddy.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 5/31/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import Foundation

import UIKit
import SceneKit
import ARKit

class Buddy {
    let node: SCNNode
    
    init(position: SCNVector3) {
        // Load the character in the idle animation
        //let idleScene = SCNScene(named: "art.scnassets/bounceFixed.dae")!
        let idleScene = SCNScene(named: "art.scnassets/CorgiDirectToOpenCollada.DAE")!
        
        // This node will be parent of all the animation models
        self.node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            self.node.addChildNode(child)
        }
        
        // Set up some properties
        self.node.name = "Buddy"
        self.node.position = position
        self.node.scale = SCNVector3(0.002, 0.002, 0.002)
        
    }
    
    func get() -> SCNNode {
        return self.node
    }
    
    func getPosition() -> SCNVector3{
        return self.node.position
    }
    
    func setPosition(coor: SCNVector3){
        self.node.position = coor
    }
    
    func moveBuddyTo(node: Treat) -> SCNAction{
        let buddyPosition = self.node.position
        let dx = node.getDistanceX(origin: buddyPosition.x)
        let dz = node.getDistanceZ(origin: buddyPosition.z)
        let y_angle = atan2(dx, dz)
        
        let treatPosition = node.getPosition()
        let h = node.radius * cos(y_angle)
        let w = node.radius * sin(y_angle)
        
        
        //TODO:// IM ONTO SOMETHING WITH THIS, IMPROVE IT LATER
        let forward = SCNAction.move(to: SCNVector3(x: treatPosition.x+h, y: treatPosition.y, z:treatPosition.z+w), duration: 3)
        forward.timingMode = .easeInEaseOut
        
        let rotation = SCNAction.rotateTo(x: 0, y: CGFloat(y_angle), z: 0, duration: 1)
        rotation.timingMode = .easeInEaseOut
        
        let moveSequence = SCNAction.sequence([rotation, forward])
        return moveSequence
    }
}