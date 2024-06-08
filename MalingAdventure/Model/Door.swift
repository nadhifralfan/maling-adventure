//
//  Door.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import Foundation
import SpriteKit

class Door : SKNode {
    var doorType : DoorType = DoorType(doorImageName: "")
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
        super.init(texture: SKTexture(imageNamed: doorImageName), color: .clear, size: CGSize(width: 50, height: 50))
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
        return DoorType(doorImageName: "doorType2Image")
    }
}
