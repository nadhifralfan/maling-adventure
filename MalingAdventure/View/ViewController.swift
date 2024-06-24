//
//  ViewController.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 07/06/24.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    //TURN ON DEBUG MODE FOR DATEBASE
    var debugMode : Bool = true
    
    let gameControllerManager = GameControllerManager()
    let hapticsManager = HapticsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            if let scene = LevelSelectScene(fileNamed: "LevelSelectScene") {
                
                insertDataToScene(scene: scene, debugMode: debugMode)
                
                scene.scaleMode = .aspectFill
                scene.gameControllerManager = gameControllerManager
                scene.hapticsManager = hapticsManager

                // Present the scene
                view.presentScene(scene)
            }
//            if let scene = MenuScene(fileNamed: "MenuScene") {
//                scene.scaleMode = .aspectFill
//                view.presentScene(scene)
//            }
            
            view.ignoresSiblingOrder = true
            
            view.showsPhysics = true
            view.showsDrawCount = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}


