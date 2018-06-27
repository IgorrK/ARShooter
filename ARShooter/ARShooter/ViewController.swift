//
//  ViewController.swift
//  ARShooter
//
//  Created by igor on 6/27/18.
//  Copyright © 2018 igor. All rights reserved.
//

import UIKit

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLighting()
        addSphere()
        // Uncomment to configure lighting
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.showsStatistics = true
        configuration.isLightEstimationEnabled = true
        configuration.planeDetection = [ .horizontal, .vertical ]
        sceneView.session.run(configuration)
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print("PLANE FOUND:", planeAnchor)
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        if planeAnchor.alignment == .horizontal {
            plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        } else {
            plane.materials.first?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
        }
        
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        print("PLANE UPDATED:", planeAnchor)
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if anchor is ARPlaneAnchor {
                node.removeFromParentNode()
            }
        }
    }
    
    func addSphere(x: Float = 0.0, y: Float = 0.0, z: Float = -4.5) {
        
        let sphere = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "sweeborg")
        sphere.materials = [material]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(x, y, z)
        
        
        //        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        //
        //        let boxNode = SCNNode()
        //        boxNode.geometry = box
        //        boxNode.position = SCNVector3(x, y, z)
        //
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

