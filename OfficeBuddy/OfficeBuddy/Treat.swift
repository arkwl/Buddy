//
//  Treat.swift
//  Buddy
//
//  Created by Alexa Rockwell on 5/22/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class Treat {
    
    let node: SCNNode
    
    init(x: Float, y: Float, z:Float){
        let sphere = SCNSphere(radius: 0.01)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(x, y, z)
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
