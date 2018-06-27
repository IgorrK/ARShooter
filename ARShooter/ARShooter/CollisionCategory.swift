//
//  CollisionCategory.swift
//  ARShooter
//
//  Created by igor on 6/27/18.
//  Copyright © 2018 igor. All rights reserved.
//

import Foundation

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullets  = CollisionCategory(rawValue: 1 << 0)
    static let mobs = CollisionCategory(rawValue: 1 << 1)
    static let floor = CollisionCategory(rawValue: 1 << 2)
    static let loot = CollisionCategory(rawValue: 1 << 3)

}
