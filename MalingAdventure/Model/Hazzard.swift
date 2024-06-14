//
//  Hazzard.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import Foundation
import SpriteKit

class Hazzard : SKNode {
    var hazzardType : HazzardType = HazzardType(hazzardImageName: "")
    var startPosition : CGPoint = CGPoint()
    var endPosition : CGPoint = CGPoint()
    var size : CGSize = CGSize()
}



enum HazzardTypeEnum {
    case type1
    case type2
    case type3
    case type4
    
    init?(from string: String) {
        switch string {
        case "type1":
            self = .type1
        case "type2":
            self = .type4
        case "type3":
            self = .type3
        case "type4":
            self = .type4
        default:
            return nil
        }
    }
}

class HazzardType : SKSpriteNode {
    var hazzardImageName: String = ""
    
    init(hazzardImageName: String) {
        self.hazzardImageName = hazzardImageName
        super.init(texture: SKTexture(imageNamed: hazzardImageName), color: .clear, size: CGSize(width: 50, height: 50))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func createHazzardType(for type: HazzardTypeEnum) -> HazzardType {
    switch type {
    case .type1:
        return HazzardType(hazzardImageName: "spikesImage")
    case .type2:
        return HazzardType(hazzardImageName: "fireImage")
    case .type3:
        return HazzardType(hazzardImageName: "sawImage")
    case .type4:
        return HazzardType(hazzardImageName: "laserImage")
    }
}
