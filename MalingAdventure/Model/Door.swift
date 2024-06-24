//
//  Door.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import Foundation
import SpriteKit

class Door : SKNode {
    var doorType : DoorType = DoorType(doorImageName: "playerImage")
    var doorPosition : CGPoint = CGPoint()
}

enum DoorTypeEnum {
    case type1
    case type2
    
    init?(from string: String) {
        switch string {
        case "type1":
            self = .type1
        case "type2":
            self = .type2
        default:
            return nil
        }
    }
}


class DoorType: SKSpriteNode {
    var doorImageName: String = ""
    
    init(doorImageName: String) {
        self.doorImageName = doorImageName
        
//        super.init(texture: SKTexture(imageNamed: doorImageName), color: .red, size: CGSize(width: 50, height: 50))
        super.init(texture: nil, color: .clear, size: CGSize(width: 50, height: 50))
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.position = CGPoint(x: 0, y: 0)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: self.size.width/2, y: self.size.height/2))
        self.physicsBody?.categoryBitMask = PhysicsCategory.door
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.zPosition = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func createDoorType(for type: DoorTypeEnum) -> DoorType {
    switch type {
    case .type1:
        return DoorType(doorImageName: "doorType1Image")
    case .type2:
        return DoorType(doorImageName: "doorType1Image")
    }
}
