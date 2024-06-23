//
//  MenuScene.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 23/06/24.
//

import SpriteKit
import GameplayKit
import GameController

class MenuScene: SKScene{
    
    private var selectedButtonIndex: Int = 0
    private var buttons: [SKLabelNode] = []
    
    override func didMove(to view: SKView) {
        
        let backgroundNode = SKSpriteNode(imageNamed: "menuBackground")
        backgroundNode.size = self.size
        backgroundNode.position = CGPoint(x: 0, y: 0)
        backgroundNode.zPosition = -1
        self.addChild(backgroundNode)
        
        let button1 = SKLabelNode(text: "Play")
        button1.position = CGPoint(x: 0, y: 0 - 50)
        let button2 = SKLabelNode(text: "Settings")
        button2.position = CGPoint(x: 0, y: 0 - 100)
        let button3 = SKLabelNode(text: "Quit")
        button3.position = CGPoint(x: 0, y: 0 - 150)
        
        
        buttons.append(button1)
        buttons.append(button2)
        buttons.append(button3)
        
        self.addChild(button1)
        self.addChild(button2)
        self.addChild(button3)
    }
    
    
}
