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
    public var levels: [String: Level] = [:]
    private var currentLevel: Level?
    private var selectedButtonIndex: Int = 0
    private var buttons: [SKLabelNode] = []
    var gameControllerManager: GameControllerManager?
    var hapticsManager: HapticsManager?
    var background1: SKSpriteNode!
    var background2: SKSpriteNode!
    var foreground1: SKSpriteNode!
    var foreground2: SKSpriteNode!
    var langitOffset: CGFloat = 0
    

    override func didMove(to view: SKView) {
        setupBackgrounds()
        startScrollingBackgrounds()
        setupLogo()
        setupPlayer(playerNumber: 1, startX: -600, startY: -250, endX: -450)
        setupPlayer(playerNumber: 2, startX: -600, startY: -250, endX: 450)
        setupPlayer(playerNumber: 3, startX: -600, startY: -250, endX: 400)
        setupPlayer(playerNumber: 4, startX: -600, startY: -250, endX: 350)
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.setupButton()
        }
        
        guard !levels.isEmpty else { return }
        
        if let gameControllerManager = gameControllerManager {
            gameControllerManager.isSelectingLevel = true
            
            // Create a repeating timer that checks for controllers
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                if gameControllerManager.controllers.count > 0 {
                    timer.invalidate()
                    
                    for controller in gameControllerManager.controllers {
                        controller.extendedGamepad?.valueChangedHandler = nil
                        self?.setupControllerInputs(controller: controller)
                    }
                } else {
                    print("Waiting for controllers to connect...")
                }
            }
        }
    }
    
    func setupControllerInputs(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, element) in
            guard let self = self else {return}
            SoundManager.playClick()
            if gamepad.buttonA.isPressed && gameControllerManager!.isSelectingLevel == true {
                currentLevel = levels["1"]
                if let level = currentLevel {
                    switchToGameScene(level: level)
                }
            }
        }
    }
    
    func switchToGameScene(level: Level) {
        for controller in gameControllerManager!.controllers {
            controller.extendedGamepad?.valueChangedHandler = nil
        }
        let reveal = SKTransition.fade(withDuration: 0.5)
        gameControllerManager?.isSelectingLevel = false
        gameControllerManager?.isStoryMode = true
        SoundManager.playBackground()
        let newScene = GameScene(size: self.size, level: level, section: 1, gameControllerManager: gameControllerManager!, spawn : level.sections[0].spawnEntry, hapticsManager: hapticsManager!, coins: 0)
        self.view?.presentScene(newScene, transition: reveal)
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 && gameControllerManager!.isSelectingLevel == true{
            currentLevel = levels[String(selectedButtonIndex + 1)]
            if let level = currentLevel {
                SoundManager.playClick()
                switchToGameScene(level: level)
            }
        }
    }

    func setupBackgrounds() {
        let texture = SKTexture(imageNamed: "skies")
        background1 = SKSpriteNode(texture: texture)
        background2 = SKSpriteNode(texture: texture)
        background1.size = self.size
        background2.size = self.size

        background1.position = CGPoint(x: 0, y: 0)
        background2.position = CGPoint(x: background1.size.width, y: 0)
        background1.zPosition = 0
        background2.zPosition = 0
        
        let textureForeground = SKTexture(imageNamed: "foregroundMenu")
        foreground1 = SKSpriteNode(texture: textureForeground)
        foreground2 = SKSpriteNode(texture: textureForeground)
        foreground1.size = self.size
        foreground2.size = self.size
        
        foreground1.position = CGPoint(x: 0, y: 0)
        foreground2.position = CGPoint(x: foreground1.size.width, y: 0)
        foreground1.zPosition = 1
        foreground2.zPosition = 1

        addChild(background1)
        addChild(background2)
        addChild(foreground1)
        addChild(foreground2)
    }
    
    func setupLogo() {
        let texture = SKTexture(imageNamed: "logo")
        let logo = SKSpriteNode(texture: texture)
        logo.size = CGSize(width: texture.size().width / 8, height: texture.size().height / 8)
        
        // Initial position above the screen
        logo.position = CGPoint(x: 0, y: size.height / 2 + logo.size.height / 2)
        logo.zPosition = 3
        
        addChild(logo)
        
        // Move down to the middle of the screen
        let moveDown = SKAction.moveTo(y: 100, duration: 2)
        logo.run(moveDown)
    }
    
    func setupButton(){
        let button = SKLabelNode(text: "")
        button.name = "start"
        button.text = "PRESS ANY BUTTON TO START"
        button.fontName = "Test"
        button.fontColor = SKColor.white
        button.fontSize = 32
        button.position = CGPoint(x: 0, y: 0 - CGFloat(100))
        button.zPosition = 4
        addChild(button)
    }

    
    func setupPlayer(playerNumber: Int, startX: CGFloat, startY: CGFloat, endX: CGFloat) {
        let texture = SKTexture(imageNamed: "player\(playerNumber)Image1")
        let player = SKSpriteNode(texture: texture)
        player.size = CGSize(width: 35, height: 40)
        
        let walkTextures = (1...3).map { SKTexture(imageNamed: "player\(playerNumber)Image\($0)") }
        let walkAction = SKAction.animate(with: walkTextures, timePerFrame: 0.1)
        let repeatAction = SKAction.repeatForever(walkAction)
        player.run(repeatAction)
        
        player.position = CGPoint(x: startX, y: startY)
        player.zPosition = 4
        
        addChild(player)
        
        var duration = 0
        if playerNumber == 1{
            duration = 4
        } else {
            duration = 3
        }
        let moveRight = SKAction.moveTo(x: endX, duration: TimeInterval(duration))
        player.run(moveRight)
    }

    func startScrollingBackgrounds() {
        let moveLeft = SKAction.moveBy(x: -background1.size.width, y: 0, duration: 16)
        let resetPosition = SKAction.moveBy(x: background1.size.width, y: 0, duration: 0)
        let moveForever = SKAction.repeatForever(SKAction.sequence([moveLeft, resetPosition]))
        
        let moveLeftForeground = SKAction.moveBy(x: -background1.size.width, y: 0, duration: 9)
        let resetPositionForeground = SKAction.moveBy(x: background1.size.width, y: 0, duration: 0)
        let moveForeverForeground = SKAction.repeatForever(SKAction.sequence([moveLeftForeground, resetPositionForeground]))
        
        background1.run(moveForever)
        background2.run(moveForever)
        foreground1.run(moveForeverForeground)
        foreground2.run(moveForeverForeground)
    }

    func playBackgroundMusic() {
        let backgroundMusic = SKAudioNode(fileNamed: "slowMusic.mp3")
        addChild(backgroundMusic)
        backgroundMusic.run(SKAction.play())
    }

    override func update(_ currentTime: TimeInterval) {}
    
}
