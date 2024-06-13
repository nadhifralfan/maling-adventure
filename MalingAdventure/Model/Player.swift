//
//  Player.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import Foundation
import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let platform: UInt32 = 0b10
    static let ground: UInt32 = 0b100
    static let hazzard: UInt32 = 0b1000
}

class Player: SKSpriteNode {
    
    private var keysPressed: Set<UInt16> = []
    var isJumping: Bool = false
    var isWalking: Bool = false
    var isFacingRight: Bool = true
    private var textureNode: SKSpriteNode // Child node to hold the texture
    
    init(imageNamed: String, position: CGPoint) {
        let texture = SKTexture(imageNamed: imageNamed)
        textureNode = SKSpriteNode(texture: texture)
        textureNode.size = CGSize(width: 60, height: 70)
        textureNode.anchorPoint = CGPoint(x: 0, y: 0)
        
        super.init(texture: nil, color: .clear, size: textureNode.size)
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.size = CGSize(width: 60, height: 70)
        self.position = position
        self.name = "player"
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: self.size.width / 2, y: self.size.height / 2))
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard
        self.physicsBody?.contactTestBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        
        // Add the texture node as a child
        self.addChild(textureNode)
    }
    
    override func keyDown(with event: NSEvent) {
        keysPressed.insert(event.keyCode)
    }
    
    override func keyUp(with event: NSEvent) {
        keysPressed.remove(event.keyCode)
    }
    
    func update(_ currentTime: TimeInterval) {
        if keysPressed.contains(126) { // Up arrow key
            jump()
        }
        if keysPressed.contains(123) { // Left arrow key
            self.position.x -= CGFloat(3.0)
            if isFacingRight {
                isFacingRight = false
                textureNode.xScale = -1 // Flip the texture horizontally
                textureNode.position = CGPoint(x: self.size.width, y: 0) // Adjust the position to match the flip
            }
        }
        if keysPressed.contains(124) { // Right arrow key
            self.position.x += CGFloat(3.0)
            if !isFacingRight {
                isFacingRight = true
                textureNode.xScale = 1 // Reset the texture to normal
                textureNode.position = CGPoint(x: 0, y: 0) // Reset the position
            }
        }
    }
    
    func jump() {
        guard isPlayerOnGround() else { return }
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 130))
        isJumping = true
    }
    
    func isPlayerOnGround() -> Bool {
        return self.physicsBody?.velocity.dy == 0
    }
  
    
   
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (PhysicsCategory.player | PhysicsCategory.ground) {
            isJumping = false
        }
        if contactMask == (PhysicsCategory.player | PhysicsCategory.hazzard) {
            // Reset player position and stop its movement
            self.position = CGPoint(x: 120, y: 210)
            self.anchorPoint = CGPoint(x: 0, y: 0)
            self.size = CGSize(width: 60, height: 70)
            self.name = "player"
            self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: self.size.width / 2, y: self.size.height / 2))
            self.physicsBody?.categoryBitMask = PhysicsCategory.player
            self.physicsBody?.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard
            self.physicsBody?.contactTestBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard
            self.physicsBody?.affectedByGravity = true
            self.physicsBody?.allowsRotation = false

            // Also reset the textureNode position to ensure consistency
            textureNode.position = CGPoint(x: 0, y: 0)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
