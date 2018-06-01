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

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

class ARController {

    public var buddy: Buddy!
    public var mode: InteractionMode!
    var treatStack = Stack<Treat>()
    
    init(){
        
    }
    
    func setBuddy(position: SCNVector3){
        buddy = Buddy(position: position)
    }
    
    func getBuddy() -> SCNNode{
        return buddy.get()
    }
    
    func generatePlane(anchor: ARPlaneAnchor) -> SCNNode {
        let width = CGFloat(anchor.extent.x)
        let length = CGFloat(anchor.extent.z)
        let planeHeight = CGFloat(0.005)
        
        let plane = SCNBox(width: width, height:planeHeight, length:length, chamferRadius: 0)
        
        plane.materials.first?.diffuse.contents = UIColor.orange //Change this to clear for the future
        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(anchor.center.x)
        let y = CGFloat(anchor.center.y)
        let z = CGFloat(anchor.center.z)
        planeNode.position = SCNVector3(x,y-0.01,z)
        
        planeNode.physicsBody = SCNPhysicsBody(type:.kinematic, shape: SCNPhysicsShape(geometry:plane, options:nil))
        planeNode.physicsBody?.categoryBitMask = Int(CategoryMask.plane.rawValue)
        planeNode.physicsBody?.collisionBitMask = Int(CategoryMask.ball.rawValue) | Int(CategoryMask.plane.rawValue)
        return planeNode
    }
    
    func generateTreat(touch: UIGestureRecognizer, scene: ARSCNView) -> Treat? {
        buddy.get().removeAllActions()
        
        let tapLocation = touch.location(in: scene)
        let hitTestResults = scene.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return nil}
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let translation = hitTestResult.worldTransform.translation
        let touchPoint = SCNVector3(translation.x, translation.y, translation.z)
        
        //(delete|do something with) any other existent treats in the area
        if touchAction(mode:"Delete", touch: touchPoint, objs: scene.scene.rootNode.childNodes){
            return nil
        }
        
        let treat = Treat(position: touchPoint)
        treat.setName(name: "treat-"+String(scene.scene.rootNode.childNodes.count))
        
        return treat
    }
    
    func buddyTreatInteraction (treat: Treat) {
        treatStack.push(treat)
        
        //make buddy move to sphere
        let moveSequence = buddy.moveBuddyTo(node: treat)
        buddy.get().runAction(moveSequence, completionHandler: walkDone)
    }
    
    func walkDone() {
        let poppedTreat = treatStack.pop()
        poppedTreat?.get().removeFromParentNode()
    
        if treatStack.count > 0 {
            let moveSequence = buddy.moveBuddyTo(node: treatStack.top!)
            buddy.get().runAction(moveSequence, completionHandler: walkDone)
        }
    }
    
    // TODO: Retouch this!!
    private func touchAction(mode: String, touch: SCNVector3, objs: [SCNNode]) -> Bool {
        let radius = Float(0.06)
        for node in objs {
            if (node.position.x < touch.x + radius && node.position.x > touch.x - radius &&
                node.position.y < touch.y + radius && node.position.y > touch.y - radius &&
                node.position.z < touch.z + radius && node.position.z > touch.z - radius) {
                if (node.name == nil || node.name != "plane"){
                    if !(node.name == "Buddy" || node.name == "Corgi") {
                        node.removeFromParentNode()
                        return true
                    }
                    else {
                        //do something with Buddy
                    }
                }
                return false
            }
        }
        return false
    }
}
