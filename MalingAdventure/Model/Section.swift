//
//  Section.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import SpriteKit

class Section : SKNode {
    var background : SKSpriteNode = SKSpriteNode()
    var platforms : [[String : Any]] = []
    var doorEntry : Door = Door()
    var doorExit : Door = Door()
    var coins : [CGPoint] = []
    var hazzards : [Hazzard] = []
}
