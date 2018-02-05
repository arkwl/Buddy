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
    var positivities: [String] = ["you can do it", "im proud of you", "keep moving forward", "dont let anything stop you"]
    var positivities2: [String] = ["Love yourself. It is important to stay positive because beauty comes from the inside out.", "Your positive action combined with positive thinking results in success.","Yesterday is not ours to recover, but tomorrow is ours to win or lose.", "Keep your face to the sunshine and you cannot see a shadow.", "You're pretty great!","Adopting the right attitude can convert a negative stress into a positive one.", "Every day brings new choices.", "It's amazing. Life changes very quickly, in a very positive way, if you let it."
    ]
    
    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        bubbleNode = createBubble()
        loadAnimations()
        addBubble()
        
        //Adding buttons programatically over ARSCNView
        let button = UIButton()
        button.frame = CGRect(x:320, y:35, width:80, height:20)
        button.setTitle("Settings", for: [])
        button.setTitleColor(UIColor.white, for: [])
        sceneView.addSubview(button)
        
        let image = UIImage(named: "art.scnassets/logo.png")
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 20, y: 35, width: 200, height: 40)
        sceneView.addSubview(imageView)
 
        
    }
    
    func loadAnimations () {
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/idleFixed.dae")!
        
        // This node will be parent of all the animation models
        let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // Set up some properties
        node.position = SCNVector3(0, -1, -2)
        node.scale = SCNVector3(0.005, 0.005, 0.005)
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // Load all the DAE animations
        loadAnimation(withKey: "dancing", sceneName: "art.scnassets/sambaFixed", animationIdentifier: "sambaFixed-1")
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        // Let's test if a 3D Object was touch
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        
        
        
        
        
        if hitResults.first != nil {
            if hitResults.first?.node.name == bubbleNode.name || ( textNode != nil && hitResults.first?.node.name == textNode.name) {
                //if (hitResults.first?.node.name == textNode.name){
                    performSegue(withIdentifier: "mySegueID", sender: nil)
                //}
            }
            else {
            
            if(idle) {
                playAnimation(key: "dancing")
                bubbleScaleUp()
                textNode = createText()
                addText()
            } else {
                stopAnimation(key: "dancing")
                bubbleScaleDown()
                textNode.removeFromParentNode()
            }
            idle = !idle
            return
            }
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
        
        //let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 200))
        //rectangle.lineWidth = 5
        //rectangle.alpha = 0.4
        //let labelNode = SKLabelNode(text: "bush did 9/11 \n lololol")
        let labelNode = SKMultilineLabel(text: goodText(), labelWidth: 200,  pos: CGPoint(x: 0, y: 80), fontName:"Helvetica-Light", fontSize:CGFloat(20))
        labelNode.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //labelNode.fontName = "San Fransisco"
        labelNode.position = CGPoint(x:100,y:100)
        //skScene.addChild(multiLabel)
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
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
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
    
/*
    // Override to create and configure nodes for anchors added to the view's session.*/
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
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
