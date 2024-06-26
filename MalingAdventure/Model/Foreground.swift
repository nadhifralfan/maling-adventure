//
//  Foreground.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 23/06/24.
//

import Foundation
import SpriteKit
import GameController

class Foreground: SKSpriteNode {
    var textureNode: SKSpriteNode
    var visible: Bool = true
    var isDynamic: Bool = false
    
    init(imageNamed: String, isDynamic: Bool, position: CGPoint, size: CGSize){
        let texture = SKTexture(imageNamed: imageNamed)
        textureNode = SKSpriteNode(texture: texture)
        textureNode.size = size
        
        self.isDynamic = isDynamic
        
        super.init(texture: texture, color: .clear, size: size)
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.size = size
        self.position = position
        
        self.physicsBody = SKPhysicsBody(rectangleOf: size, center: CGPoint(x: self.size.width / 2, y: self.size.height / 2))
//        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.categoryBitMask = PhysicsCategory.foreground
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.isDynamic = false
    }
    
    func makeVisible() {
        self.visible = true
        self.alpha = 1.0
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let visible = SKAction.run {
            self.isHidden = false
        }
        let sequence = SKAction.sequence([fadeOut, visible])
        self.run(sequence)
    }
        
    func makeInvisible() {
        self.visible = false
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let hide = SKAction.run {
            self.isHidden = true
        }
        let sequence = SKAction.sequence([fadeOut, hide])
        self.run(sequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyB.categoryBitMask == PhysicsCategory.player && contact.bodyA.categoryBitMask == PhysicsCategory.foreground && self.isDynamic {
            if visible{
                makeInvisible()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
