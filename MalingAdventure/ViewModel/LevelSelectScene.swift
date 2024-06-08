//
//  GameScene.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import SpriteKit
import GameplayKit

class LevelSelectScene: SKScene {
    
    public var levels: [String: Level] = [:]
    private var currentLevel: Level?
    private var isPlaying: Bool = false
    
    override func didMove(to view: SKView) {
        // Ensure there is at least one level
        guard !levels.isEmpty else { return }
        
        createLevelButtons()
    }
    
    func createLevelButtons() {
        // Iterate through levels and create buttons
        for (index, _) in levels.enumerated() {
            let button = SKLabelNode(text: "Level \(index + 1)")
            button.name = "levelButton\(index)"
            button.fontSize = 24
            button.fontColor = SKColor.white
            button.position = CGPoint(x: 0, y: 0 - CGFloat(50 * (index + 1)))
            self.addChild(button)
        }
    }
    
    func switchToGameScene(level: Level) {
        let reveal = SKTransition.fade(withDuration: 3)
        let newScene = GameScene(size: self.size, level: level)
        self.view?.presentScene(newScene, transition: reveal)
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if let nodeName = node.name, nodeName.starts(with: "levelButton") {
                if let index = Int(nodeName.dropFirst("levelButton".count)){
                    currentLevel = levels[String(index+1)]
                    if let level = currentLevel {
                        switchToGameScene(level: level)
                    }
                }
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}
