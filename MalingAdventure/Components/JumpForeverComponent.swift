//
//  JumpForeverComponent.swift
//  MalingAdventure
//
//  Created by Sigit Academy on 20/06/24.
//

import SpriteKit
import GameplayKit

class JumpForeverComponent: GKComponent {
    // MARK: Properties
    
    /// A reference to the box in the scene that the entity controls.
    var nodeComponent: NodeComponent? {
        return entity?.component(ofType: NodeComponent.self)
    }
    
    var vector: CGVector!
    var duration: TimeInterval!
    var nodeHasJumpAction = false
    
    // MARK: Initialization
    
    init(vector: CGVector, duration: TimeInterval) {
        self.vector = vector
        self.duration = duration
        
        super.init()
    }

    override func update(deltaTime _: TimeInterval) {
        /*
            Ensure that the particle system and light will properly attach when
            the geometry node is added, even if it is not available when the
            component is constructed.
        */
        updateJumpComponent()
    }
    
    func updateJumpComponent(){
        
        if let nodeComponent = nodeComponent, !nodeHasJumpAction {
            
            let rotateAction = SKAction.applyForce(self.vector, duration: self.duration)
            let repeatAction = SKAction.repeatForever(rotateAction)
            let node = nodeComponent.node
            node.run(repeatAction, withKey: node.name ?? "")
        }
        
        nodeHasJumpAction = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
