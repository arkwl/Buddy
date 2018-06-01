//
//  ARController.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 5/31/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import Foundation

import SceneKit
import ARKit

enum CategoryMask: UInt32 {
    case ball = 0b01 // 1
    case plane = 0b11 // 2
}

enum InteractionMode: Int {
    case defaultMode = 0
    case treat = 1
    case catchBall = 2
    case touch = 3
}

func generatePlane(anchor: ARPlaneAnchor) -> SCNNode {
    let width = CGFloat(anchor.extent.x)
    let length = CGFloat(anchor.extent.z)
    let planeHeight = CGFloat(0.01)
    
    let plane = SCNBox(width: width, height:planeHeight, length:length, chamferRadius: 0)
    
    plane.materials.first?.diffuse.contents = UIColor.orange //Change this to clear for the future
    let planeNode = SCNNode(geometry: plane)
    let x = CGFloat(anchor.center.x)
    let y = CGFloat(anchor.center.y)
    let z = CGFloat(anchor.center.z)
    planeNode.position = SCNVector3(x,y,z)
    
    planeNode.physicsBody = SCNPhysicsBody(type:.kinematic, shape: SCNPhysicsShape(geometry:plane, options:nil))
    planeNode.physicsBody?.categoryBitMask = Int(CategoryMask.plane.rawValue)
    planeNode.physicsBody?.collisionBitMask = Int(CategoryMask.ball.rawValue) | Int(CategoryMask.plane.rawValue)
    return planeNode
}

class ARController {

    public var buddy: Buddy!
    public var mode: InteractionMode!
    
    init(){
        
    }
    
    func setBuddy(position: SCNVector3){
        buddy = Buddy(position: position)
    }
    
    func getBuddy() -> SCNNode{
        return buddy.get()
    }
}
