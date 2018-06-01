//
//  ViewController.swift
//  BuddyV2
//
//  Created by Alexa Rockwell on 5/31/18.
//  Copyright © 2018 Alexa Rockwell. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet var actionButtons: [UIButton]!
    
    var enviorment = ARController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene = SCNScene()
        sceneView.scene.rootNode.name = "world"
        sceneView.showsStatistics = true
        addTapGestureToSceneView()
        addSwipeGestureToSceneView()
    }
    
    /* Gesture Regonizers for Scene View */
    @objc func addTreatToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let treat = enviorment.generateTreat(touch: recognizer, scene: sceneView)
        if treat != nil {
            sceneView.scene.rootNode.addChildNode((treat?.get())!)
            //move buddy to treat
            enviorment.buddyTreatInteraction(treat: treat!)
        }
    }
    
    @objc func throwBallInSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
    }
    
    
    
    
    /* UIKit Recongizers */
    @IBAction func clickActionButton(_ sender: UIButton) {
        let index = actionButtons.index(of: sender)
        if index == 2 {
            enviorment.mode = InteractionMode.defaultMode
            //TODO: Other animations to make it clear that the user can now interact with Buddy
        } else {
            enviorment.mode = nil
            //segue to other views
        }
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addTreatToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addSwipeGestureToSceneView() {
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(throwBallInSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    
    
    
    
    
    
    
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = enviorment.generatePlane(anchor: planeAnchor)
        if enviorment.buddy == nil {
            node.name = "plane"
            node.addChildNode(planeNode)
            
            // TODO: Load all the DAE animations
            
            let coor = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
            enviorment.setBuddy(position: coor)
            
            sceneView.scene.rootNode.addChildNode(enviorment.getBuddy())
            
            //TODO: add anchor to the ARController
            //activeAnchor = planeAnchor
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
