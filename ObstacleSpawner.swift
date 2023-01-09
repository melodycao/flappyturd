//
//  ObstacleSpawner.swift
//  FlappyTurd
//
//  Created by Melody Cao and Kevin Gu on 12/2/22.
//

import Foundation
import SpriteKit

// Defines the node to spawn obstacles
class ObstacleSpawner: SKSpriteNode {
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var timeSpace: CFTimeInterval?
    let scrollSpeed = 0.3
    var columnPointer = 0
    var currentScheme: [[Int]] = []
}
