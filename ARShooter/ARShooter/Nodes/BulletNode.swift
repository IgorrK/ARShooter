//
//  BulletNode.swift
//  ARShooter
//
//  Created by igor on 6/27/18.
//  Copyright © 2018 igor. All rights reserved.
//

import UIKit
import ARKit

final class BulletNode: SCNNode {
    
    override init() {
        super.init()
        let sphere = SCNSphere(radius: 0.01)
        
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.bullets.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.mobs.rawValue
        self.physicsBody?.velocityFactor = SCNVector3(5.0, 5.0, 5.0)
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "gnum")
        self.geometry?.materials = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
