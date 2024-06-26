//
//  Coin.swift
//  MalingAdventure
//
//  Created by Sigit Academy on 25/06/24.
//

import Foundation
import SpriteKit

class Coin : NSObject {
    var type : String
    var position : CGPoint = CGPoint()
    var value: Int
    var hasReceived : Bool
    var size: CGSize
    var sizeBody: CGSize
    
    init(position: CGPoint, type: String){
        self.position = position
        self.type = type
        self.hasReceived = false
        
        if self.type == "diamond"{
            self.value = 50
            self.size = CGSize(width: 68, height: 80)
            self.sizeBody = CGSize(width: 60, height: 70)
        } else {
            self.value = 10
            self.size = CGSize(width: 34, height: 40)
            self.sizeBody = CGSize(width: 30, height: 35)
        }
        
        super.init()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CoinNode: SKSpriteNode {
    
    var value: Int
    
    init(texture: SKTexture?, coin: Coin) {
        self.value = coin.value
    
        super.init(texture: texture, color:.clear, size: coin.size)
        
        name = "coin"
        self.position = CGPoint(x: coin.position.x, y: coin.position.y)
        physicsBody = SKPhysicsBody(rectangleOf: coin.sizeBody)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.coin
        physicsBody?.collisionBitMask = 0
        physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.platform
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        zPosition = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CoinType: SKSpriteNode {
    var coinImageName: String = ""
    
    init(coinImageName: String, size: CGSize) {
        self.coinImageName = coinImageName
        
        super.init(texture: SKTexture(imageNamed: coinImageName), color: .red, size: size)
        self.name = "coin"
        self.position = CGPoint(x: position.x, y: position.y + self.size.height)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 35))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.coin
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.platform
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.zPosition = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
