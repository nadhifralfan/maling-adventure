//
//  NodeComponent.swift
//  MalingAdventure
//
//  Created by Sigit Academy on 20/06/24.
//

import SpriteKit
import GameplayKit

class NodeComponent: GKComponent {
    // MARK: Properties
    
    /// A reference to the box in the scene that the entity controls.
    let node: SKSpriteNode
    
    // MARK: Initialization
    
    init(node: SKSpriteNode) {
        self.node = node
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    /// Applies an upward impulse to the entity's box node, causing it to jump.
    func applyImpulse(_ vector: CGVector) {
        node.physicsBody?.applyImpulse(vector)
    }
}
