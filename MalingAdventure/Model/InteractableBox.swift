//
//  InteractableBox.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 24/06/24.
//

import Foundation
import SpriteKit
import GameController

class InteractableBox: SKSpriteNode {
    var textureNode: SKSpriteNode
    var isInteracting: Bool = false
    
    init(imageNamed: String, position: CGPoint, size: CGSize){
        let texture = SKTexture(imageNamed: imageNamed)
        textureNode = SKSpriteNode(texture: texture, size: size)
        textureNode.anchorPoint = CGPoint(x: 0, y: 0)
        
        super.init(texture: nil, color: .clear, size: size)
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.size = size
        self.position = position
        
        self.physicsBody = SKPhysicsBody(rectangleOf: size, center: CGPoint(x: self.size.width / 2, y: self.size.height / 2))
        self.physicsBody?.categoryBitMask = PhysicsCategory.box
        self.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.box | PhysicsCategory.platform | PhysicsCategory.hazzard
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0
//        self.physicsBody?.mass = 0.1
        self.physicsBody?.linearDamping = 0
        
        self.addChild(textureNode)
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
