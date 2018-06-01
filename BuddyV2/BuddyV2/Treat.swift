//
//  Treat.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 5/31/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import Foundation

import UIKit
import SceneKit
import ARKit

class Treat {
    
    let node: SCNNode
    let radius: Float
    
    init(position: SCNVector3){
        
        let sphereNode = SCNNode()
        
        var sphere = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
        sphere.firstMaterial?.diffuse.contents = UIColor.purple
        sphere.name = "purpleTreat"
        sphereNode.addChildNode(SCNNode(geometry: sphere))
        
        self.radius = 0.06
        sphere = SCNBox(width: 0.06, height: 0.06, length: 0.06, chamferRadius: 0)
        sphere.firstMaterial?.diffuse.contents = UIColor.clear
        sphere.name = "invisibleTreat"
        sphereNode.addChildNode(SCNNode(geometry: sphere))
        
        sphereNode.position = position
        sphereNode.name = "treatParent"
        self.node = sphereNode
    }
    
    func get() -> SCNNode {
        return self.node
    }
    
    func getName() -> String{
        return self.node.name!
    }
    
    func setName(name: String){
        self.node.name = name
    }
    
    func getPosition() -> SCNVector3{
        return self.node.position
    }
    
    func getDistanceX(origin:Float) -> Float{
        return self.node.position.x - origin
    }
    
    func getDistanceZ(origin:Float) -> Float{
        return self.node.position.z - origin
    }
}

