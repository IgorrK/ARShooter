//
//  GameViewController.swift
//  ARShooter
//
//  Created by igor on 6/27/18.
//  Copyright © 2018 igor. All rights reserved.
//

import UIKit

import UIKit
import ARKit

final class GameViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLighting()
        // Uncomment to configure lighting
        sceneView.scene.physicsWorld.contactDelegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Setup
    
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
    
    // MARK: - Actions
    
    @IBAction private func addMobAction(_ sender: UIButton) {
        addMob()
    }
    
    @objc private func tapAction() {
        shoot()

//        switch state {
//        case .placing:
//            addMob()
//        case .shootting:
//            shoot()
        }
    }
    


extension GameViewController {
    func addMob() {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        let mobNode = MobNode()
        sceneView.scene.rootNode.addChildNode(mobNode)
        
        
    
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
//        translation = translation. //SCNMatrix4MakeRotation(-Float.pi / 2.0, 0.0, 0.0, 1.0)
        mobNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        mobNode.simdRotation = simd_float4.init(0.0, 0.0, 0.0, 0.0)
    }
    
    private func addLoot(from node: SCNNode) {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        let lootNode = LootNode()
        lootNode.position = node.position

        sceneView.scene.rootNode.addChildNode(lootNode)
        
        
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        //        translation = translation. //SCNMatrix4MakeRotation(-Float.pi / 2.0, 0.0, 0.0, 1.0)
//        mobNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
//        mobNode.simdRotation = simd_float4.init(0.0, 0.0, 0.0, 0.0)
    }
    
    private func shoot() {
        let bullet = BulletNode()
        
        let (direction, position) = cameraVector
        bullet.position = position
        
        
//        let orientation = bullet.orientation
//        var glQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
//
//        // Rotate around Z axis
//        let multiplier = GLKQuaternionMakeWithAngleAndAxis(0.0, 0, 0, 1)
//        glQuaternion = GLKQuaternionMultiply(glQuaternion, multiplier)
        
//        bullet.orientation = SCNQuaternion(x: glQuaternion.x, y: glQuaternion.y, z: glQuaternion.z, w: glQuaternion.w)
//        let constraint = SCNBillboardConstraint()
//        constraint.freeAxes = [.X, .Y, .Z]
//        bullet.constraints = [constraint]
        
        let bulletDirection = direction
        bullet.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bullet)
    }

}

// MARK: - Utils
extension GameViewController {
    
    fileprivate var cameraVector: (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, 0), SCNVector3(0, 0, 0))
    }
    
}


// MARK: - SKPhysicsContactDelegate
extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("didBegin")
        guard let nodeABitMask = contact.nodeA.physicsBody?.categoryBitMask,
            let nodeBBitMask = contact.nodeB.physicsBody?.categoryBitMask,
            nodeABitMask == CollisionCategory.mobs.rawValue,
            nodeBBitMask == CollisionCategory.bullets.rawValue else {
                return
        }
        
        contact.nodeB.removeFromParentNode()
        addLoot(from: contact.nodeA)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            contact.nodeA.removeFromParentNode()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            contact.nodeB.removeFromParentNode()
        })

        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        print("didUpdate")
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("didEnd")
    }
}

// MARK: - ARSKViewDelegate
extension GameViewController: ARSKViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("Session Failed - probably due to lack of camera access")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session resumed")
        sceneView.session.run(session.configuration!,
                              options: [.resetTracking, .removeExistingAnchors])
    }
}

// MARK: - ARSCNViewDelegate
extension GameViewController: ARSCNViewDelegate {
    
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
        
        
        
        
//        self.geometry = sphere
//        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        
        let physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node.childNodes.first ?? node))
        physicsBody.isAffectedByGravity = false
//
        physicsBody.categoryBitMask = CollisionCategory.floor.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.bullets.rawValue
        node.physicsBody = physicsBody
//        // add texture
//        let material = SCNMaterial()
//        material.diffuse.contents = #imageLiteral(resourceName: "sweeborg")
//        material.selfIllumination.contents = UIColor.red
//        self.geometry?.materials = [material]

        
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
        
        let physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: planeNode))
        physicsBody.isAffectedByGravity = false
        //
        physicsBody.categoryBitMask = CollisionCategory.floor.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.bullets.rawValue
        node.physicsBody = physicsBody

        planeNode.position = SCNVector3(x, y, z)
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if anchor is ARPlaneAnchor {
                node.removeFromParentNode()
            }
        }
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

