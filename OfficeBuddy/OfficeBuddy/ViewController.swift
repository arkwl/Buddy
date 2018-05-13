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
    
    var bubbleNode: SCNNode!
    var textNode: SCNNode!
    
    
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
        
        //load animations for buddy
        loadAnimations()
        
        
        
        
        /*
         //how images are added dynamically to the ARSceneView
        let image = UIImage(named: "art.scnassets/logo.png")
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 20, y: 35, width: 200, height: 40)
        sceneView.addSubview(imageView)
        */
 
        
    }
    
    
    
    
    
    /*
     * HORIZONTAL PLANE DETECTION
     */
    func initWithAnchor(anchor:ARPlaneAnchor){
        let planeGeometry = SCNPlane(width:CGFloat(anchor.extent.x), height:CGFloat(anchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/tron_grid.png")
        planeGeometry.materials = [material]
        
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
        //setGridTextureScale(geometry:planeGeometry)
        
        sceneView.scene.rootNode.addChildNode(planeNode)
        print("it worked")
    }
    
    func setGridTextureScale (geometry: SCNPlane){
        let width = Float(geometry.width)
        let height = Float(geometry.height)
        
        let material = geometry.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1)
        material?.diffuse.wrapS = SCNWrapMode(rawValue: 2)!
        material?.diffuse.wrapT = SCNWrapMode(rawValue: 2)!
    }
    
    @objc func addObjectToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer, node: SCNNode) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        //guard let shipScene = SCNScene(named: "ship.scn"),
        //    let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
        //    else { return }
        
        
        node.position = SCNVector3(x,y,z)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    
    
    
    /*
    * ANIMATIONS
    */
    func loadAnimations () {
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
        node.position = SCNVector3(0, -1, -2)
        node.scale = SCNVector3(0.01, 0.01, 0.01)
        
        //ANIMATIONS FOR IDLE
        //TODO:// edit the forward animation to move in it's directon
        let forward = SCNAction.moveBy(x: 0, y: 0, z: 0.00025, duration: 4)
        //let forward = SCNAction.move(to: SCNVector3(x:0, y:0, z:0.00025), duration: 4)
        let rotate = SCNAction.rotate(by: CGFloat(0.88), around: SCNVector3(x:0, y:1, z:0), duration: 2)
        forward.timingMode = .easeInEaseOut
        rotate.timingMode = .easeInEaseOut
        let moveSequence = SCNAction.sequence([forward,rotate])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        node.runAction(moveLoop)
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // Load all the DAE animations
        loadAnimation(withKey: "excited", sceneName: "art.scnassets/excited1Fixed", animationIdentifier: "excited1Fixed-1")
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
    
    
    
    
    
    
    
    
    
    
    // DEPRICATED
    
    /*

    func bubbleScaleUp (){
        //bubbleNode.scale = SCNVector3(x: 8, y: 8, z: 1)
        bubbleNode.scale = SCNVector3(x: 150, y: 150, z: 1)
        //addTextToBubble()
    }
    
    func bubbleScaleDown (){
        //bubbleNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        bubbleNode.scale = SCNVector3(x: 0.125, y: 0.125, z: 1)
    }
    
    func addBubble() {
        bubbleNode.position = SCNVector3(0, 0, -2)
        bubbleNode.name = "bubble"
        sceneView.scene.rootNode.addChildNode(bubbleNode)
    }
    
    func createBubble() -> SCNNode{
        //let geometry = SCNPlane(width: 0.1, height: 0.1)
        let geometry = SCNPlane(width: 0.005, height: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/bubble2.png")
        geometry.materials = [material]
        
        return SCNNode(geometry: geometry)
    }
    
    
    
    
    
    
    func textScaleUp (){
        //bubbleNode.scale = SCNVector3(x: 8, y: 8, z: 1)
        textNode.scale = SCNVector3(x: 150, y: 150, z: 1)
        //addTextToBubble()
    }
    
    func textScaleDown (){
        //bubbleNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        textNode.scale = SCNVector3(x: 0.125, y: 0.125, z: 1)
    }
    
    func addText() {
        textNode.position = SCNVector3(0, 0, -1.5)
        textNode.name = "text"
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func createText() -> SCNNode{
        let geometry = SCNPlane(width: 0.4, height: 0.4)
        //let geometry = SCNPlane(width: 0.005, height: 0.005)
        
        
        let skScene = SKScene(size: CGSize(width: 200, height: 200))
        skScene.backgroundColor = UIColor.clear
        activeText = goodText()
        
        let labelNode = SKMultilineLabel(text: activeText, labelWidth: 200,  pos: CGPoint(x: 0, y: 80), fontName:"Helvetica-Light", fontSize:CGFloat(20))
        labelNode.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //labelNode.fontName = "San Fransisco"
        labelNode.position = CGPoint(x:100,y:100)
        skScene.addChild(labelNode)
        
        let material = SCNMaterial()
        material.diffuse.contents = skScene
        material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(-1, 1, 1), 1, 0, 0)
        material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        
        geometry.materials = [material]
        
        return SCNNode(geometry: geometry)
    }
    
    func goodText() -> String{
        let randomNumber = Int(arc4random_uniform(UInt32(positivities.count)))
        return positivities2[randomNumber]
    }
    */
    
    
    
    
    
    
    
    
    
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
        
        node.addChildNode(planeNode)
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
