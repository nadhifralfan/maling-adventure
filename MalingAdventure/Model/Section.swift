//
//  Section.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import SpriteKit

class Section : SKNode {
    var background : SKSpriteNode = SKSpriteNode()
    var spawnEntry: CGPoint = CGPoint(x: 0, y: 0)
    var spawnExit: CGPoint = CGPoint(x:0, y:0)
    var platforms : [[String : Any]] = []
    var doorEntry : Door = Door()
    var doorExit : Door = Door()
    var finalDoor : Door = Door()
    var coins : [Coin] = []
    var hazzards : [Hazzard] = []
    var transitionNext: String = "right"
    var transitionBack: String = "left"
}
