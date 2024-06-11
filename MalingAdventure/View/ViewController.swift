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
    var debugMode : Bool = false
    
    let gameControllerManager = GameControllerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = LevelSelectScene(fileNamed: "LevelSelectScene") {
                
                
                insertDataToScene(scene: scene, debugMode: debugMode)
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.gameControllerManager = gameControllerManager
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}


