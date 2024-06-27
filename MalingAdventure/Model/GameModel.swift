//
//  GameModel.swift
//  MalingAdventure
//
//  Created by Sigit Academy on 27/06/24.
//

import Foundation

class GameModel : NSObject {
    var size: CGSize
    var level: Level
    var section: Int
    var gameControllerManager: GameControllerManager
    var spawn: CGPoint
    var hapticsManager: HapticsManager
    var coins: Int
    var boxPositions: [CGPoint]
    var buttonsPressed: Int
    
    init(size: CGSize, level: Level, section: Int, gameControllerManager: GameControllerManager, spawn: CGPoint, hapticsManager: HapticsManager, coins: Int, boxPositions: [CGPoint], buttonsPressed: Int) {
        self.size = size
        self.level = level
        self.section = section
        self.gameControllerManager = gameControllerManager
        self.spawn = spawn
        self.hapticsManager = hapticsManager
        self.coins = coins
        self.boxPositions = boxPositions
        self.buttonsPressed = buttonsPressed
    }
}
