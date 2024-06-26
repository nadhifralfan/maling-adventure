//
//  Player.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import Foundation
import SpriteKit
import GameController

struct PhysicsCategory {
    static let none: UInt32 = 1 << 1
    static let player: UInt32 = 1 << 2
    static let platform: UInt32 = 1 << 3
    static let ground: UInt32 = 1 << 4
    static let coin: UInt32 = 1 << 5
    static let scene: UInt32 = 1 << 6
    static let hazzard: UInt32 = 1 << 7
    static let door: UInt32 = 1 << 8
    static let foreground: UInt32 = 1 << 9
    static let box: UInt32 = 1 << 10
    static let button: UInt32 = 1 << 11
}

class Player: SKSpriteNode {
    var imageName : String
    var keysPressed: Set<UInt16> = []
    var isJumping: Bool = false
    var isWalking: Bool = false
    var isFacingRight: Bool = true
    private var textureNode: SKSpriteNode
    var thumbstickTimer: Timer?
    var jumpTimer: Timer?
    var isThumbstickActive = false
    var goingToSection = 0
    var spawn : CGPoint = CGPoint(x: 0, y: 0)
    var controller: GCController?
    var buttonInteract: SKSpriteNode
    var canInteract: Bool = false
    var contactWith: SKNode?
    var contactJoint: SKNode?
    var joint: SKPhysicsJointPin?
    
    private var walkTextures: [SKTexture] = []
    
    init(imageNamed: String, spawn: CGPoint, name: String) {
        imageName = imageNamed
        let texture = SKTexture(imageNamed: imageNamed)
        textureNode = SKSpriteNode(texture: texture)
        textureNode.size = CGSize(width: 35, height: 40)
        textureNode.anchorPoint = CGPoint(x: 0, y: 0)
        
        let symbolImage = NSImage(systemSymbolName: "o.circle.fill", accessibilityDescription: nil)
        let textureSymbol = SKTexture(image: symbolImage!)
        self.buttonInteract = SKSpriteNode(texture: textureSymbol)
        
        
        super.init(texture: nil, color: .clear, size: textureNode.size)
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.size = CGSize(width: 35, height: 40)
        self.spawn = spawn
        self.position = spawn
        self.name = name
        
        createPhysicBody()
        
        
        self.buttonInteract.position.y = self.buttonInteract.position.y + size.height + 20
        self.buttonInteract.position.x = self.buttonInteract.position.x + size.width/2
        
        let nameNode = SKLabelNode(text: name)
        nameNode.fontSize = 10
        nameNode.position.y = nameNode.position.y + size.height
        nameNode.position.x = nameNode.position.x + size.width/2
        
        self.addChild(buttonInteract)
        self.buttonInteract.isHidden = true
        self.addChild(nameNode)
        self.addChild(textureNode)
        loadTextures()
    }
    
    func setController(_ controller: GCController?){
        self.controller = controller
    }
    
    func createPhysicBody(){
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: self.size.width / 2, y: self.size.height / 2))
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard | PhysicsCategory.player | PhysicsCategory.box
        self.physicsBody?.contactTestBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard | PhysicsCategory.door | PhysicsCategory.foreground | PhysicsCategory.box | PhysicsCategory.button
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.restitution = 0
    }
    
    func updatePosition(to position: CGPoint) {
        self.position = position
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    }
    
    private func loadTextures() {
        // Assuming you have images named walk1.png, walk2.png, etc. and jump.png
        walkTextures = (1...3).map { SKTexture(imageNamed: "\(imageName)\($0)") }
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
            moveLeft()
            startWalkingAnimation()
        }
        if keysPressed.contains(124) { // Right arrow key
            moveRight()
            startWalkingAnimation()
        }
        
        if keysPressed.contains(36) { //Enter to Interact
            
        }
        
        if !keysPressed.contains(123) && !keysPressed.contains(124) {
            stopMoving()
        }
   
    }
    
    func moveLeft() {
        self.position.x -= CGFloat(3.0)
        if isFacingRight {
            isFacingRight = false
            textureNode.xScale = -1 // Flip the texture horizontally
            textureNode.position = CGPoint(x: self.size.width, y: 0) // Adjust the position to match the flip
        }
        
    }
    
    func moveRight() {
        self.position.x += CGFloat(3.0)
        if !isFacingRight {
            isFacingRight = true
            textureNode.xScale = 1 // Reset the texture to normal
            textureNode.position = CGPoint(x: 0, y: 0) // Reset the position
        }
    }
    
    func startMoving(){
        startWalkingAnimation()
    }
    
    func stopMoving() {
        stopWalkingAnimation()
    }
    
    func jump() {
        guard isPlayerOnGround() else { return }
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
        isJumping = true
    }
    
    func isPlayerOnGround() -> Bool {
        return self.physicsBody?.velocity.dy == 0
    }
    
    func startWalkingAnimation() {
        if isWalking == false {
            let walkAction = SKAction.animate(with: self.walkTextures, timePerFrame: 0.1)
            let repeatAction = SKAction.repeatForever(walkAction)
            self.textureNode.run(repeatAction, withKey: imageName)
            self.isWalking = true
        }
    }
    
    func stopWalkingAnimation() {
        if isWalking {
            self.textureNode.removeAction(forKey: imageName)
            self.isWalking = false
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (PhysicsCategory.player | PhysicsCategory.ground) {
            isJumping = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
