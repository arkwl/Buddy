//
//  ViewController.swift
//  OfficeBuddy
//
//  Created by Alexa Rockwell on 1/31/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate{

    @IBOutlet var sceneView: ARSCNView!
    
    var activeAnchor: ARPlaneAnchor!
    var globalBuddyNode: Buddy!
    var lastTreat: Treat!
    
    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    var treatStack = Stack<Treat>()
    
    var swipeCoor = CGPoint()
    var latestTranslatePos = CGPoint()
    
    var totalTreats = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.rootNode.name = "world"
        sceneView.scene.physicsWorld.contactDelegate = self
        
        addTapGestureToSceneView()
        addSwipeGestureToSceneView()
    }
    
    @objc func addObjectToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        globalBuddyNode.get().removeAllActions()
        
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        print("hit result count from UIGestureRecognizer: " + String(hitTestResults.count))
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(tapLocation, options: hitTestOptions)
        
        //check to see what's in hitresults
        print("")
        print("****************** TAP DETECTED ********************")
        print(hitTestResults) //ARHitTestResult
        print(hitResults)     //SCNHitTestResult
        
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        let radius = Float(0.06)//Treat.radius - future constant
        for node in sceneView.scene.rootNode.childNodes {
            if (node.position.x < x + radius && node.position.x > x - radius &&
                node.position.y < y + radius && node.position.y > y - radius &&
                node.position.z < z + radius && node.position.z > z - radius) {
                if (node.name == nil || node.name != "plane"){
                    if !(node.name == "Buddy" || node.name == "Corgi") {
                        node.removeFromParentNode()
                    }
                    else {
                        //do something with Buddy
                    }
                }
                return
            }
        }
        
        
        let treat = Treat(x:x, y:y, z:z)
        treat.setName(name: "treat-"+String(sceneView.scene.rootNode.childNodes.count))

        print("pushed:" + treat.getName())
        sceneView.scene.rootNode.addChildNode(treat.get())
        //lastTreat = treat
        treatStack.push(treat)
        totalTreats += 1
        
        //make buddy move to sphere
        let moveSequence = globalBuddyNode.moveBuddyTo(node: treat)
        globalBuddyNode.get().runAction(moveSequence, completionHandler: walkDone)
     
        
    }
    
    func walkDone() {
        let poppedTreat = treatStack.pop()
        print("popped:" + (poppedTreat?.getName())!)
        poppedTreat?.get().removeFromParentNode()
        totalTreats -= 1
        
        if treatStack.count != totalTreats {
            print("we have a problem")
            print (totalTreats)
            print (treatStack.count)
        }
        else {
            print("we're good")
        }
        
        
        
        //if queue is not empty, walk to that one next
        if treatStack.count > 0 {
            print ("lets take care of the others")
            
            //make buddy move to sphere
            let moveSequence = globalBuddyNode.moveBuddyTo(node: treatStack.top!)
            globalBuddyNode.get().runAction(moveSequence, completionHandler: walkDone)
        }
        else {
            print("none left")
        }
    }
    
    
    @objc func throwBall(withGestureRecognizer sender: UIPanGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizerState.began) {
            print("swipe recognized")
            
            swipeCoor = sender.location(in: self.view)
            latestTranslatePos = swipeCoor
        }
        else if (sender.state == UIGestureRecognizerState.ended) {
            let stopLocation = sender.location(in: self.view);
            let dx = stopLocation.x - swipeCoor.x
            let dy = stopLocation.y - swipeCoor.y
            let distance = sqrt(dx*dx + dy*dy)
            
            //let projectedOrigin = sceneView.projectPoint(SCNVector3Zero)
            let vpWithDepth = SCNVector3Make(Float(stopLocation.x), Float(stopLocation.y), 0)
            let scenePoint = sceneView.unprojectPoint(vpWithDepth)
            
            let ball = Ball(x:scenePoint.x, y:scenePoint.y, z:0)
            
            sceneView.scene.rootNode.addChildNode(ball.get())
            ball.applyForce(f: SCNVector3(dx, -1*dy, -0.5*distance))
            
            
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("-> didBeginContact")
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        print("-> didUpdateContact")
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("-> didEndContact")
    }
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addObjectToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addSwipeGestureToSceneView() {
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(throwBall(withGestureRecognizer:)))
        //swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.up
        sceneView.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    
    /*
    * ANIMATIONS
    */
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            // The animation will only play once
            animationObject.repeatCount = 1
            // To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            // Store the animation for later use
            animations[withKey] = animationObject
        }
    }
    
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    
    
    
    /*
     * Touch detection
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
        let location = touches.first!.location(in: sceneView)
        
        // Let's test if a 3D Object was touch
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        print("hit result count: " + String(hitResults.count))
        
        if hitResults.first != nil {
            if hitResults.first?.node.name == "Bubble" {
                performSegue(withIdentifier: "mySegueID", sender: nil)
            }
            else if hitResults.first?.node.name == "Buddy" || hitResults.first?.node.name == "Corgi" {
                if(idle) {
                    playAnimation(key: "excited")
                } else {
                    stopAnimation(key: "excited")
                }
                idle = !idle
                addActionButtons()
                return
            }
            //TODO: VERY HACKY, FIX THIS LATER
            else if (hitResults.first?.node.name)?.range(of: "treat") != nil || (hitResults.first?.node.parent?.name)?.range(of: "treat") != nil {
                //globalBuddyNode.get().removeAllActions()
                hitResults.first?.node.parent?.removeFromParentNode()
                return
            } else if (hitResults.first?.node.name == "plane") {
                globalBuddyNode.get().removeAllActions()
                
                
                let translation = hitResults.first?.worldCoordinates
                let x = translation?.x
                let y = translation?.y
                let z = translation?.z
                
                let treat = Treat(x:x!, y:y!, z:z!)
                treat.setName(name: "treat-"+String(sceneView.scene.rootNode.childNodes.count))
                
                print("pushed:" + treat.getName())
                sceneView.scene.rootNode.addChildNode(treat.get())
                treatStack.push(treat)
                
                //make buddy move to sphere
                let moveSequence = globalBuddyNode.moveBuddyTo(node: treat)
                globalBuddyNode.get().runAction(moveSequence, completionHandler: walkDone)
            }
        } else {
        }
 */
    }
 
   */

    //function used to pass information through segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mySegueID") {
            
            if let destinationViewController = segue.destination as? MessageViewController {
                // how to pass variable and data to MessageViewController.swift
                destinationViewController.message = "yeah bitch! fucking great news!"
            }
        }
    }
    
    
    func addActionButtons() {
        //Interact Button
        var button = UIButton()
        button.center.x = self.view.center.x
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        button.frame = CGRect(x:30, y:608, width:46, height:30)
        button.setTitle("Play!", for: [])
        button.setTitleColor(UIColor.white, for: [])
        sceneView.addSubview(button)
        
        //Help Button
        button = UIButton()
        button.center.x = self.view.center.x
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        button.frame = CGRect(x:163, y:608, width:46, height:30)
        button.setTitle("Help!", for: [])
        button.setTitleColor(UIColor.white, for: [])
        sceneView.addSubview(button)
        
        //News Button
        button = UIButton()
        button.center.x = self.view.center.x
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        button.frame = CGRect(x:299, y:608, width:46, height:30)
        button.setTitle("News!", for: [])
        button.setTitleColor(UIColor.white, for: [])
        button.addTarget(self, action: #selector(ViewController.newsButtonClicked(_:)), for: .touchUpInside)
        sceneView.addSubview(button)
        
    }
    
    @IBAction func newsButtonClicked(_ sender: UIButton) {
        print("tapped")
        performSegue(withIdentifier: "mySegueID", sender: nil)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let length = CGFloat(planeAnchor.extent.z)
        let planeHeight = CGFloat(0.01)
        
        let plane = SCNBox(width: width, height:planeHeight, length:length, chamferRadius: 0)
        
        plane.materials.first?.diffuse.contents = UIColor.orange //Change this to clear for the future
        let planeNode = SCNNode(geometry: plane)
        
        
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        
        planeNode.physicsBody = SCNPhysicsBody(type:.kinematic, shape: SCNPhysicsShape(geometry:plane, options:nil))
        planeNode.physicsBody?.categoryBitMask = Int(CategoryMask.plane.rawValue)
        planeNode.physicsBody?.collisionBitMask = Int(CategoryMask.ball.rawValue) | Int(CategoryMask.plane.rawValue)
        
        //self.node.physicsBody?.categoryBitMask = CollisionCategory.plane.rawValue
        //self.node.physicsBody?.collisionBitMask = CollisionCategory.ball.rawValue | CollisionCategory.plane.rawValue
        
        // TODO: now it only
        if (globalBuddyNode == nil) {
            planeNode.name = "plane"
            node.addChildNode(planeNode)
        
            // Load all the DAE animations
            loadAnimation(withKey: "excited", sceneName: "art.scnassets/excited1Fixed", animationIdentifier: "excited1Fixed-1")
            globalBuddyNode = Buddy()
        
        
            globalBuddyNode.setPosition(coor: SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z))
        
            sceneView.scene.rootNode.addChildNode(globalBuddyNode.get())
        
            activeAnchor = planeAnchor
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNBox
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let length = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.length = length
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        
        planeNode.physicsBody = SCNPhysicsBody(type:.kinematic, shape: SCNPhysicsShape(geometry:plane, options:nil))
        planeNode.physicsBody?.categoryBitMask = Int(CategoryMask.plane.rawValue)
        planeNode.physicsBody?.collisionBitMask = Int(CategoryMask.ball.rawValue) | Int(CategoryMask.plane.rawValue)

    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
