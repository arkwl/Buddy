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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var activeAnchor: ARPlaneAnchor!
    var activeSphereNode: SCNNode!
    var globalBuddyNode: SCNNode!
    
    
    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addTapGestureToSceneView()
    }
    
    
    @objc func addObjectToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        let sphere = SCNSphere(radius: 0.03)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(x, y, z)

        sceneView.scene.rootNode.addChildNode(sphereNode)
        activeSphereNode = sphereNode
        
        //make buddy move to sphere
        
        let forward = SCNAction.move(to: activeSphereNode.position, duration: 3)
        forward.timingMode = .easeInEaseOut
        
        
        let dx = activeSphereNode.position.x - globalBuddyNode.position.x
        let dy = activeSphereNode.position.y - globalBuddyNode.position.y
        let dz = activeSphereNode.position.z - globalBuddyNode.position.z
        
        let y_angle = atan2(dx, dz)
        //globalBuddyNode.rotation = SCNVector4(0.0, 1.0, 0.0, y_angle)
        
        let rotation = SCNAction.rotateTo(x: 0, y: CGFloat(y_angle), z: 0, duration: 1)
        rotation.timingMode = .easeInEaseOut
        
        //let con = SCNLookAtConstraint(target: sphereNode)
        //globalBuddyNode.constraints = [con]
        
        print(y_angle)
        
        let moveSequence = SCNAction.sequence([rotation, forward])
        globalBuddyNode.runAction(moveSequence)
        
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addObjectToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    /*
    * ANIMATIONS
    */
    func loadBuddy () -> SCNNode {
        // Load the character in the idle animation
        //let idleScene = SCNScene(named: "art.scnassets/bounceFixed.dae")!
        let idleScene = SCNScene(named: "art.scnassets/CorgiPointCache/CorgiDirectToOpenCollada.DAE")!
        
        
        // This node will be parent of all the animation models
        let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // Set up some properties
        node.name = "Buddy"
        node.position = SCNVector3(0, 0, 0)
        node.scale = SCNVector3(0.003, 0.003, 0.003)
        
        // Load all the DAE animations
        loadAnimation(withKey: "excited", sceneName: "art.scnassets/excited1Fixed", animationIdentifier: "excited1Fixed-1")
        
        return node
    }
    
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
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        // Let's test if a 3D Object was touch
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        
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
        } else {
        }
    }

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
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.orange
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.name = "plane"
        node.addChildNode(planeNode)
        
        
        let buddyNode = loadBuddy()
        globalBuddyNode = buddyNode
        
        buddyNode.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(buddyNode)
        
        activeAnchor = planeAnchor
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
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
