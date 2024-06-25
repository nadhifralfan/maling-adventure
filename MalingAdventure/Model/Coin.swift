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
    
    init(position: CGPoint, type: String){
        self.position = position
        self.type = type
        self.hasReceived = false
        
        if self.type == "diamond"{
            self.value = 50
        } else {
            self.value = 10
        }
        
        super.init()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CoinType: SKSpriteNode {
    var coinImageName: String = ""
    
    init(coinImageName: String) {
        self.coinImageName = coinImageName
        
        super.init(texture: SKTexture(imageNamed: coinImageName), color: .red, size: CGSize(width: 34, height: 40))
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
