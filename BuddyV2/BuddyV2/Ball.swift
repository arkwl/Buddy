//
//  Ball.swift
//  Buddy
//
//  Created by Alexa Rockwell on 5/25/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class  Ball {
    
    let node: SCNNode
    let radius: Float
    
    init(){
        self.node = SCNNode()
        self.radius = 0
    }
    
    init(x: Float, y: Float, z:Float){
        
        let sphereNode = SCNNode()
        
        //var sphere = SCNSphere(radius: 0.01)
        //var sphere = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 1.0)
        //sphere.firstMaterial?.diffuse.contents = UIColor.green
        //sphereNode.addChildNode(SCNNode(geometry: sphere))
        
        self.radius = 0.05
        //sphere = SCNSphere(radius: CGFloat(self.radius))
        let sphere = SCNBox(width: 0.06, height: 0.06, length: 0.06, chamferRadius: 1.0)
        sphere.firstMaterial?.diffuse.contents = UIColor.green
        sphereNode.addChildNode(SCNNode(geometry: sphere))
        
        sphereNode.position = SCNVector3(x, y, z)
        sphereNode.name = "treatParent"
        self.node = sphereNode
        
        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry:sphere, options:nil))
        //self.node.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.
        self.node.physicsBody?.categoryBitMask = Int(CategoryMask.ball.rawValue)
        self.node.physicsBody?.collisionBitMask = Int(CategoryMask.ball.rawValue) | Int(CategoryMask.plane.rawValue)
        self.node.physicsBody?.friction = 1
        self.node.physicsBody?.mass = 2.0
        
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
    
    func setPosition(coor: SCNVector3) {
        self.node.position = coor
    }
    
    func getDistanceX(origin:Float) -> Float{
        return self.node.position.x - origin
    }
    
    func getDistanceZ(origin:Float) -> Float{
        return self.node.position.z - origin
    }
    
    func applyForce(f:SCNVector3){
        //node.physicsBody?.applyForce(SCNVector3(x: 0,y: 0, z: -1*f), asImpulse: false)
        node.physicsBody?.applyForce(f, asImpulse: false)
    }
}
