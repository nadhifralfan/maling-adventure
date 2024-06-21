import SpriteKit
import GameplayKit
import GameController

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var level: Level
    private var currentStoryIndex: Int = 0
    private var currentSection: Int = 0
    private var players: [Player]! = []
    private var entities: [GKEntity]! = []
    var playersAtDoorEntry: Set<Player> = []
    var playersAtDoorExit: Set<Player> = []
    var spawn: CGPoint = CGPoint(x: 0, y: 0)
    let jumpComponentSystem = GKComponentSystem(componentClass: JumpForeverComponent.self)
    var gameControllerManager: GameControllerManager?
    var coins: Int = 0
    let coinScoreNode = SKLabelNode(text: "Coins: 0")
    var previousUpdateTime: TimeInterval = 0

    init(size: CGSize, level: Level, section: Int, gameControllerManager: GameControllerManager, spawn: CGPoint) {
        self.level = level
        self.currentSection = section
        self.gameControllerManager = gameControllerManager
        self.spawn = spawn
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        guard !level.stories.isEmpty else {
            print("Error: No stories available in the level.")
            return
        }
        
        if let gameControllerManager = gameControllerManager {
            if gameControllerManager.isPlaying {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                    if gameControllerManager.controllers.count > 0 {
                        timer.invalidate()
                        
                        for controller in gameControllerManager.controllers {
                            controller.extendedGamepad?.valueChangedHandler = nil
                            self?.setupControllerInputsPlaying(controller: controller)
                        }
                    } else {
                        print("Waiting for controllers to connect...")
                    }
                }
                createLevelContent()
            } else {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                    if gameControllerManager.controllers.count > 0 {
                        timer.invalidate()
                        
                        for controller in gameControllerManager.controllers {
                            controller.extendedGamepad?.valueChangedHandler = nil
                            self?.setupControllerInputsScene(controller: controller)
                        }
                    } else {
                        print("Waiting for controllers to connect...")
                    }
                }
                displayCurrentStory()
//                createLevelContent()
//                gameControllerManager.isPlaying = true
            }
        }
    }
    
    func setupControllerInputsScene(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, element) in
            guard let self = self else { return }
            
            if gamepad.buttonA.isPressed {
                self.transitionToNextStory()
            } else if gamepad.buttonX.isPressed {
                self.currentStoryIndex = self.level.stories.count - 1
                self.transitionToNextStory()
            }
        }
    }
    
    func setupControllerInputsPlaying(controller: GCController) {
        controller.extendedGamepad?.leftThumbstick.left.pressedChangedHandler = { [weak self] (button, value, pressed) in
            guard let self = self else { return }
            if pressed {
                self.players[controller.playerIndex.rawValue].keysPressed.insert(123)
            } else {
                self.players[controller.playerIndex.rawValue].keysPressed.remove(123)
            }
        }
        controller.extendedGamepad?.leftThumbstick.right.pressedChangedHandler = { [weak self] (button, value, pressed) in
            guard let self = self else { return }
            if pressed {
                self.players[controller.playerIndex.rawValue].keysPressed.insert(124)
            } else {
                self.players[controller.playerIndex.rawValue].keysPressed.remove(124)
            }
        }
        controller.extendedGamepad?.buttonA.pressedChangedHandler = { [weak self] (button,value,pressed) in
            guard let self = self else { return }
            if pressed {
                self.players[controller.playerIndex.rawValue].keysPressed.insert(126)
            } else {
                self.players[controller.playerIndex.rawValue].keysPressed.remove(126)
            }
        }
    }
    
    func displayCurrentStory() {
        
        let story = level.stories[currentStoryIndex]
        
        let storyImageNode = SKSpriteNode(texture: story.image.texture)
        storyImageNode.size = self.size
        storyImageNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        storyImageNode.zPosition = 0
        self.addChild(storyImageNode)
        
        let storyDescriptionNode = SKLabelNode(text: story.desc)
        storyDescriptionNode.fontSize = 24
        storyDescriptionNode.fontColor = SKColor.white
        storyDescriptionNode.numberOfLines = 0
        storyDescriptionNode.preferredMaxLayoutWidth = self.size.width - 40
        storyDescriptionNode.verticalAlignmentMode = .center
        storyDescriptionNode.horizontalAlignmentMode = .center
        
        let nextButton = SKLabelNode(text: "Next")
        nextButton.name = "nextButton"
        nextButton.fontSize = 24
        nextButton.fontColor = SKColor.blue
        nextButton.position = CGPoint(x: self.size.width - 50, y: 50)
        nextButton.zPosition = 1
        self.addChild(nextButton)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 1.0)
        storyImageNode.run(fadeInAction)
        nextButton.run(fadeInAction)
    }
    
    func transitionToNextStory() {
        
        currentStoryIndex += 1
        
        if currentStoryIndex < level.stories.count {
            let transition = SKTransition.fade(withDuration: 0.5)
            let nextScene = GameScene(size: self.size, level: level, section: currentSection, gameControllerManager: gameControllerManager!, spawn : level.sections[currentSection-1].spawnEntry)
            nextScene.currentStoryIndex = currentStoryIndex
            self.view?.presentScene(nextScene, transition: transition)
        } else {
            gameControllerManager?.isPlaying = true
            gameControllerManager?.isStoryMode = false
            let transition = SKTransition.fade(withDuration: 0.5)
            let nextScene = GameScene(size: self.size, level: level, section: currentSection, gameControllerManager: gameControllerManager!, spawn : level.sections[currentSection-1].spawnEntry)
            nextScene.currentStoryIndex = currentStoryIndex
            self.view?.presentScene(nextScene, transition: transition)
        }
    }
    
    func createLevelContent() {
        
        guard currentSection <= level.sections.count else {
            print("Error: No more sections available in the level.")
            return
        }
        
        self.removeAllChildren()
        
        print(currentSection)
        
        let section = level.sections[currentSection-1]
        
        guard let backgroundTexture = section.background.texture else {
            print("Error: Section background texture is nil.")
            return
        }
        
        //Background
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.size = self.size
        backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        backgroundNode.zPosition = -1
        self.addChild(backgroundNode)
        var position = CGPoint(x: 0, y: 0)

        //Coordinate Position
        for _ in 0..<20 {
            for _ in 0..<30 {
                let text = SKLabelNode(text: position.debugDescription)
                let platformNode = SKSpriteNode(color: .red, size: CGSize(width: 3, height: 3))
                platformNode.position = position
                self.addChild(platformNode)
                text.fontSize = 5
                text.fontColor = SKColor.black
                text.scene?.anchorPoint = CGPoint(x: 0.5, y: 0)
                text.position = position
                text.zPosition = 2
                position = CGPoint(x: position.x + 35, y: position.y)
                self.addChild(text)
            }
            position = CGPoint(x: 0, y: position.y + 40)
        }
        
        //Platforms
        for platformData in section.platforms {
            if let coordinates = platformData["coordinate"] as? [String: CGFloat],
               let size = platformData["size"] as? [String: CGFloat],
               let x = coordinates["x"],
               let y = coordinates["y"],
               let width = size["width"],
               let height = size["height"] {
                
                let platformNode = SKSpriteNode(color: .clear, size: CGSize(width: width, height: height))
                platformNode.anchorPoint = CGPoint(x: 0, y: 0)
                platformNode.position = CGPoint(x: x, y: y)
                platformNode.physicsBody = SKPhysicsBody(rectangleOf: platformNode.size, center: CGPoint(x: platformNode.size.width / 2, y: platformNode.size.height / 2))
                platformNode.physicsBody?.isDynamic = false
                platformNode.physicsBody?.categoryBitMask = PhysicsCategory.platform
                platformNode.physicsBody?.collisionBitMask = PhysicsCategory.player
                platformNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
                platformNode.zPosition = 2
                self.addChild(platformNode)
            } else {
                print("Error: Invalid platform data: \(platformData)")
            }
        }
        
        //Coins
        coinScoreNode.fontSize = 24
        coinScoreNode.fontColor = SKColor.black
        coinScoreNode.numberOfLines = 0
        coinScoreNode.position.x = 945
        coinScoreNode.position.y = 740
        coinScoreNode.zPosition = 100
        
        self.addChild(coinScoreNode)
        
        for coinData in section.coins {
            let x = coinData.x
            let y = coinData.y
            
            if x == 0 || y == 0 {
                print("Error: Invalid coin data: \(coinData)")
            }
            
            let coinEntity = makeCoinEntity(name: "coin", position: CGPoint(x: x, y: y), scene: self)
            entities.append(coinEntity)

        }
        
        for entity in entities {
            jumpComponentSystem.addComponent(foundIn: entity)
        }
        
        //Hazzards
        for hazzardData in section.hazzards {
            let hazzardNode = SKSpriteNode(color: .red, size: CGSize(width: hazzardData.size.width, height: hazzardData.size.height))
            hazzardNode.anchorPoint = CGPoint(x: 0, y: 0)
            hazzardNode.position = CGPoint(x: hazzardData.startPosition.x, y: hazzardData.startPosition.y)
            hazzardNode.physicsBody = SKPhysicsBody(rectangleOf: hazzardNode.size, center: CGPoint(x: hazzardNode.size.width / 2, y: hazzardData.size.height / 2))
            hazzardNode.physicsBody?.isDynamic = false
            hazzardNode.physicsBody?.categoryBitMask = PhysicsCategory.hazzard
            hazzardNode.physicsBody?.collisionBitMask = PhysicsCategory.player
            hazzardNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
            hazzardNode.zPosition = 2
            self.addChild(hazzardNode)
            let destination = CGPoint(x: hazzardData.endPosition.x, y: hazzardData.endPosition.y)
            let moveDuration: TimeInterval = 2.0
            
            var moveAction: SKAction?
            
            if hazzardData.startPosition.x != destination.x && hazzardData.startPosition.y == destination.y {

                let moveRight = SKAction.moveTo(x: destination.x, duration: moveDuration)
                let moveLeft = SKAction.moveTo(x: hazzardData.startPosition.x, duration: moveDuration)
                moveAction = SKAction.sequence([moveRight, moveLeft])
            } else if hazzardData.startPosition.y != destination.y && hazzardData.startPosition.x == destination.x {
                let moveUp = SKAction.moveTo(y: destination.y, duration: moveDuration)
                let moveDown = SKAction.moveTo(y: hazzardData.startPosition.y, duration: moveDuration)
                moveAction = SKAction.sequence([moveUp, moveDown])
            }
            
            if let moveAction = moveAction {
                let repeatAction = SKAction.repeatForever(moveAction)
                hazzardNode.run(repeatAction)
            }
        }
        
        //Doors
        let doorEntry = section.doorEntry.doorType
        doorEntry.position = section.doorEntry.doorPosition
        doorEntry.zPosition = 2
        self.addChild(doorEntry)
        let doorExit = section.doorExit.doorType
        doorExit.position = section.doorExit.doorPosition
        doorExit.zPosition = 2
        self.addChild(doorExit)
        

        //Players
        if gameControllerManager?.controllers.count == 0 {
            let player = Player(imageNamed: "playerImage", spawn: spawn, name: "P1")
            players.append(player)
        } else {
            for i in 0..<(gameControllerManager?.controllers.count ?? 0) {
                let player = Player(imageNamed: "playerImage", spawn: spawn, name: "P\(i+1)")
                players.append(player)
            }
        }
        
        for player in players {
            player.zPosition = 4
            self.addChild(player)
        }
        
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "nextButton" {
                transitionToNextStory()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let gameControllerManager = gameControllerManager {
            if gameControllerManager.isPlaying {
                for player in players {
                    player.update(currentTime)
                }
            }
            
            let timeSincePreviousUpdate = currentTime - previousUpdateTime
            jumpComponentSystem.update(deltaTime: timeSincePreviousUpdate)
            previousUpdateTime = currentTime
            coinScoreNode.text = "Coins: \(coins)"
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let gameControllerManager = gameControllerManager {
            if gameControllerManager.isPlaying {
                for player in players {
                    player.keyDown(with: event)
                }
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let gameControllerManager = gameControllerManager {
            if gameControllerManager.isPlaying {
                for player in players {
                    player.keyUp(with: event)
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        for player in players {
            player.didBegin(contact)
        }
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        if (bodyA.categoryBitMask == PhysicsCategory.coin && bodyB.categoryBitMask == PhysicsCategory.player) || (bodyB.categoryBitMask == PhysicsCategory.coin && bodyA.categoryBitMask == PhysicsCategory.player) {
            contact.bodyA.node?.physicsBody?.contactTestBitMask = 0
            contact.bodyA.node?.removeFromParent()
            coins += 10
        }

        if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.door) || (bodyB.categoryBitMask == PhysicsCategory.player && bodyA.categoryBitMask == PhysicsCategory.door) {
            let playerNode = (bodyA.categoryBitMask == PhysicsCategory.player) ? bodyA.node as! Player : bodyB.node as! Player
            let doorNode = (bodyA.categoryBitMask == PhysicsCategory.door) ? bodyA.node as! DoorType : bodyB.node as! DoorType

            if doorNode == level.sections[currentSection-1].doorExit.doorType {
                playersAtDoorExit.insert(playerNode)

                if playersAtDoorExit.count == players.count {
                    print("exit")
                    let reveal = SKTransition.push(with: .left, duration: 1)
                    self.removeAllChildren()
                    let newScene = GameScene(size: self.size, level: level, section: currentSection + 1, gameControllerManager: gameControllerManager!, spawn : level.sections[currentSection].spawnEntry)
                    self.view?.presentScene(newScene, transition: reveal)
                }
            } else if doorNode == level.sections[currentSection-1].doorEntry.doorType {
                playersAtDoorEntry.insert(playerNode)
                
                if playersAtDoorEntry.count == players.count && currentSection != 1 {
                    let reveal = SKTransition.push(with: .left, duration: 1)
                    self.removeAllChildren()
                    let newScene = GameScene(size: self.size, level: level, section: currentSection - 1, gameControllerManager: gameControllerManager!, spawn : level.sections[currentSection-1].spawnExit)
                    self.view?.presentScene(newScene, transition: reveal)
                }
            }
        }
    }

    
    func didEnd(_ contact: SKPhysicsContact) {
            let bodyA = contact.bodyA
            let bodyB = contact.bodyB

            if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.door) || (bodyB.categoryBitMask == PhysicsCategory.player && bodyA.categoryBitMask == PhysicsCategory.door) {
                let playerNode = (bodyA.categoryBitMask == PhysicsCategory.player) ? bodyA.node as! Player : bodyB.node as! Player
                let doorNode = (bodyA.categoryBitMask == PhysicsCategory.door) ? bodyA.node as! DoorType : bodyB.node as! DoorType

                if doorNode == level.sections[currentSection-1].doorExit.doorType {
                    playersAtDoorExit.remove(playerNode)
                } else if doorNode == level.sections[currentSection-1].doorEntry.doorType {
                    playersAtDoorEntry.remove(playerNode)
                }
            }
        }
    
    func makeCoinEntity(name: String, position: CGPoint, scene: SKScene) -> GKEntity {
        let coinEntity = GKEntity()
        
        let texture = SKTexture(imageNamed: "coins")
        let coinNode = SKSpriteNode(texture: texture)
        coinNode.size = CGSize(width: 35, height: 40)
        coinNode.name = "coin"
        coinNode.position = CGPoint(x: position.x, y: position.y+coinNode.size.height)
        coinNode.physicsBody = SKPhysicsBody(texture: texture, size: CGSize(width: 35, height: 40))
        coinNode.physicsBody?.isDynamic = true
        coinNode.physicsBody?.allowsRotation = false
        coinNode.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coinNode.physicsBody?.collisionBitMask = 0
        coinNode.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.platform
        coinNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
        coinNode.zPosition = 10
        scene.addChild(coinNode)
        
        let coinComponent = NodeComponent(node: coinNode)
        coinEntity.addComponent(coinComponent)
        
        let jumpComponent = JumpForeverComponent(vector: CGVector(dx: 0, dy: 30), duration: 0.5)
        coinEntity.addComponent(jumpComponent)
        
        return coinEntity
    }
}
