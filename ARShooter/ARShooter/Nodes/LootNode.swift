//
//  LootNode.swift
//  ARShooter
//
//  Created by igor on 6/27/18.
//  Copyright © 2018 igor. All rights reserved.
//

import UIKit
import ARKit

final class LootNode: SCNNode {
    
    override init() {
        super.init()
        let sphere = SCNSphere(radius: 0.06)
        
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = true
        
        self.physicsBody?.categoryBitMask = CollisionCategory.mobs.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "sweeborg")
        material.selfIllumination.contents = UIColor.red
        self.geometry?.materials = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
