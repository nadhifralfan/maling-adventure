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
    var hapticsManager: HapticsManager?
    var coins: Int = 0
    let coinScoreNode = SKLabelNode(text: "Coins: 0")
    var previousUpdateTime: TimeInterval = 0
    
    init(size: CGSize, level: Level, section: Int, gameControllerManager: GameControllerManager, spawn: CGPoint, hapticsManager: HapticsManager, coins: Int) {
        self.level = level
        self.currentSection = section
        self.gameControllerManager = gameControllerManager
        self.spawn = spawn
        self.hapticsManager = hapticsManager
        self.coins = coins
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
        let player = self.players[controller.playerIndex.rawValue]
        controller.extendedGamepad?.leftThumbstick.left.pressedChangedHandler = { [weak self] (button, value, pressed) in
            guard self != nil else { return }
            if pressed {
                player.keysPressed.insert(123)
            } else {
                player.keysPressed.remove(123)
            }
        }
        controller.extendedGamepad?.leftThumbstick.right.pressedChangedHandler = { [weak self] (button, value, pressed) in
            guard self != nil else { return }
            if pressed {
                player.keysPressed.insert(124)
            } else {
                player.keysPressed.remove(124)
            }
        }
        controller.extendedGamepad?.buttonA.pressedChangedHandler = { [weak self] (button,value,pressed) in
            guard self != nil else { return }
            if pressed {
                player.keysPressed.insert(126)
            } else {
                player.keysPressed.remove(126)
            }
        }
        
        controller.extendedGamepad?.buttonB.pressedChangedHandler = { [weak self] (button,value,pressed) in
            guard let self = self else { return }
            if pressed && player.canInteract {
                if player.contactWith == level.sections[currentSection-1].doorExit.doorType {
                    playersAtDoorExit.insert(player)
                    player.isHidden = true
                    player.physicsBody?.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard | PhysicsCategory.box
                    if playersAtDoorExit.count == players.count {
                        let reveal = SKTransition.push(with: getTransition(to: level.sections[currentSection-1].transitionNext), duration: 1)
                        let newScene = GameScene(size: self.size, level: level, section: currentSection + 1, gameControllerManager: gameControllerManager!, spawn : level.sections[currentSection].spawnEntry, hapticsManager: hapticsManager!, coins: self.coins)
                        self.view?.presentScene(newScene, transition: reveal)
                    }
                } else if player.contactWith == level.sections[currentSection-1].doorEntry.doorType && currentSection != 1 {
                    player.isHidden = true
                    playersAtDoorEntry.insert(player)
                    player.physicsBody?.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard | PhysicsCategory.box
                    if playersAtDoorEntry.count == players.count {
                        let reveal = SKTransition.push(with: getTransition(to: level.sections[currentSection-1].transitionBack), duration: 1)
                        let newScene = GameScene(size: self.size, level: level, section: currentSection - 1, gameControllerManager: gameControllerManager!, spawn : level.sections[currentSection-2].spawnExit, hapticsManager: hapticsManager!, coins: self.coins)
                        self.view?.presentScene(newScene, transition: reveal)
                    }
                } else if let contactJoint = player.contactJoint, contactJoint is InteractableBox {
                    let box = contactJoint as! InteractableBox
                    if player.joint == nil {
                        player.joint = SKPhysicsJointPin.joint(withBodyA: player.physicsBody!, bodyB: contactJoint.physicsBody!, anchor: player.position)
                        physicsWorld.add(player.joint!)
                        player.position.y += 1
                        box.isInteracting = true
                    } else {
                        physicsWorld.remove(player.joint!)
                        box.isInteracting = false
                        player.joint = nil
                        player.buttonInteract.isHidden = true
                        player.canInteract = false
                        player.contactJoint = nil
                    }
                } else {
                    //TODO: Interact for other components
                }
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
            let nextScene = GameScene(size: self.size, level: level, section: currentSection, gameControllerManager: gameControllerManager!, spawn : level.sections[currentSection-1].spawnEntry, hapticsManager: hapticsManager!, coins: self.coins)
            nextScene.currentStoryIndex = currentStoryIndex
            self.view?.presentScene(nextScene, transition: transition)
        } else {
            gameControllerManager?.isPlaying = true
            gameControllerManager?.isStoryMode = false
            let transition = SKTransition.fade(withDuration: 0.5)
            let nextScene = GameScene(size: self.size, level: level, section: currentSection, gameControllerManager: gameControllerManager!, spawn : level.sections[currentSection-1].spawnEntry, hapticsManager: hapticsManager!, coins: self.coins)
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
        
//        var position = CGPoint(x: 0, y: 0)
//
//        //Coordinate Position
//        for _ in 0..<20 {
//            for _ in 0..<30 {
//                let text = SKLabelNode(text: position.debugDescription)
//                let platformNode = SKSpriteNode(color: .red, size: CGSize(width: 3, height: 3))
//                platformNode.position = position
//                self.addChild(platformNode)
//                text.fontSize = 5
//                text.fontColor = SKColor.white
//                text.scene?.anchorPoint = CGPoint(x: 0.5, y: 0)
//                text.position = position
//                text.zPosition = 2
//                position = CGPoint(x: position.x + 35, y: position.y)
//                self.addChild(text)
//            }
//            position = CGPoint(x: 0, y: position.y + 40)
//        }
        
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
                platformNode.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.box
                platformNode.zPosition = 2
                self.addChild(platformNode)
            } else {
                print("Error: Invalid platform data: \(platformData)")
            }
        }
        
        //Coins
        coinScoreNode.fontSize = 24
        coinScoreNode.fontColor = SKColor.white
        coinScoreNode.numberOfLines = 0
        coinScoreNode.position.x = 945
        coinScoreNode.position.y = 740
        coinScoreNode.zPosition = 100
        
        self.addChild(coinScoreNode)
        
        for coinData in section.coins {
            let x = coinData.position.x
            let y = coinData.position.y
            
            print("coinData",coinData, x, y)
            
            if x == 0 || y == 0 {
                print("Error: Invalid coin data: \(coinData)")
            }
            
            if !coinData.hasReceived {
                let coinEntity = makeCoinEntity(name: "coin", coin: coinData, scene: self)
    
                entities.append(coinEntity)
            }
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
                
                // Buat animasi maju
                let texturesForward = (1...3).map { SKTexture(imageNamed: "\(hazzardData.hazzardType)\($0)") }
                let animateForward = SKAction.animate(with: texturesForward, timePerFrame: 0.2)
                let animateForwardLoop = SKAction.repeatForever(animateForward)
                
                // Buat animasi mundur (membalik urutan texture)
                let texturesBackward = texturesForward.reversed()
                let animateBackward = SKAction.animate(with: Array(texturesBackward), timePerFrame: 0.2)
                let animateBackwardLoop = SKAction.repeatForever(animateBackward)

                // Tentukan durasi gerakan
                let moveDuration: TimeInterval = 2.0

                // Buat aksi gerakan
                let moveRight = SKAction.moveTo(x: hazzardData.endPosition.x, duration: moveDuration)
                let moveLeft = SKAction.moveTo(x: hazzardData.startPosition.x, duration: moveDuration)
                let moveUp = SKAction.moveTo(y: hazzardData.endPosition.y, duration: moveDuration)
                let moveDown = SKAction.moveTo(y: hazzardData.startPosition.y, duration: moveDuration)
                
                // Aksi untuk membalik skala secara horizontal dengan penyesuaian posisi
                let flipHorizontal = SKAction.run {
                    if hazzardData.startPosition.x != hazzardData.endPosition.x {
                        hazzardNode.xScale *= -1
                    }
                }
                
                // Gabungkan animasi, gerakan, dan pembalikan skala dalam aksi grup
                let moveAction: SKAction
                if hazzardData.startPosition.x != hazzardData.endPosition.x && hazzardData.startPosition.y == hazzardData.endPosition.y {
                    let forwardAction = SKAction.group([moveRight, animateForward])
                    let backwardAction = SKAction.group([moveLeft, animateBackward])
                    moveAction = SKAction.sequence([forwardAction, flipHorizontal, backwardAction, flipHorizontal])
                } else if hazzardData.startPosition.y != hazzardData.endPosition.y && hazzardData.startPosition.x == hazzardData.endPosition.x {
                    let forwardAction = SKAction.group([moveUp, animateForward])
                    let backwardAction = SKAction.group([moveDown, animateBackward])
                    moveAction = SKAction.sequence([forwardAction, flipHorizontal, backwardAction, flipHorizontal])
                } else {
                    let forwardAction = SKAction.group([moveRight, animateForward])
                    let backwardAction = SKAction.group([moveLeft, animateBackward])
                    moveAction = SKAction.sequence([forwardAction, flipHorizontal, backwardAction, flipHorizontal])
                }

                // Jalankan aksi berulang
                let repeatAction = SKAction.repeatForever(moveAction)
                hazzardNode.run(SKAction.group([repeatAction, animateForwardLoop]))
                
                self.addChild(hazzardNode)
                
            }
        
        //MARK: Interactable Box
        if currentSection == 1 {
            let box = InteractableBox(imageNamed: "box1", position: CGPoint(x: 210, y: 120), size: CGSize(width: 35, height: 40))
            box.zPosition = 3
            self.addChild(box)
            let box2 = InteractableBox(imageNamed: "box2", position: CGPoint(x: 210, y: 160), size: CGSize(width: 35, height: 40))
            box2.zPosition = 3
            self.addChild(box2)
            let box3 = InteractableBox(imageNamed: "box3", position: CGPoint(x: 210, y: 200), size: CGSize(width: 35, height: 40))
            box3.zPosition = 3
            
            self.addChild(box3)
        }
        
        //MARK: Foreground
        if currentSection == 2 {
            let foreground = Foreground(imageNamed: "foreground", isDynamic: true, position: CGPoint(x: 0, y: 340), size: CGSize(width: 105, height: 428))
            foreground.zPosition = 5
            self.addChild(foreground)
        }
        
        if currentSection == 4 {
            let box = InteractableBox(imageNamed: "trampoline3", position: CGPoint(x: 140, y: 120), size: CGSize(width: 70, height: 20))
            box.zPosition = 3
            self.addChild(box)
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
            let player = Player(imageNamed: "player1Image", spawn: spawn, name: "P1")
            players.append(player)
        } else {
            for i in 0..<(gameControllerManager?.controllers.count ?? 0) {
                let player = Player(imageNamed: "player\(i+1)Image", spawn: spawn, name: "P\(i+1)")
                player.setController(gameControllerManager?.controllers[i])
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
                if gameControllerManager.isStoryMode{
                    if event.keyCode == 36 {
                        transitionToNextStory()
                    }
                }
                if gameControllerManager.isPlaying {
                    if event.keyCode == 36 && players.count == 1 && players[0].canInteract {
                        let player = players[0]
                        if player.contactWith == level.sections[currentSection-1].doorExit.doorType {
                            playersAtDoorExit.insert(player)
                            player.isHidden = true
                            if playersAtDoorExit.count == players.count {
                                let reveal = SKTransition.push(with: getTransition(to: level.sections[currentSection-1].transitionNext), duration: 1)
                                let newScene = GameScene(size: self.size, level: level, section: currentSection + 1, gameControllerManager: gameControllerManager, spawn : level.sections[currentSection].spawnEntry, hapticsManager: hapticsManager!, coins: self.coins)
                                self.view?.presentScene(newScene, transition: reveal)
                            }
                        } else if player.contactWith == level.sections[currentSection-1].doorEntry.doorType {
                            player.isHidden = true
                            playersAtDoorEntry.insert(player)
                            
                            if playersAtDoorEntry.count == players.count && currentSection != 1 {
                                let reveal = SKTransition.push(with: getTransition(to: level.sections[currentSection-1].transitionBack), duration: 1)
                                let newScene = GameScene(size: self.size, level: level, section: currentSection - 1, gameControllerManager: gameControllerManager, spawn : level.sections[currentSection-2].spawnExit, hapticsManager: hapticsManager!, coins: self.coins)
                                self.view?.presentScene(newScene, transition: reveal)
                            }
                        } else if let contactJoint = player.contactJoint, contactJoint is InteractableBox {
                            let box = contactJoint as! InteractableBox
                            if player.joint == nil {
                                player.joint = SKPhysicsJointPin.joint(withBodyA: player.physicsBody!, bodyB: contactJoint.physicsBody!, anchor: player.position)
                                physicsWorld.add(player.joint!)
                                player.position.y += 1
                                box.isInteracting = true
                            } else {
                                physicsWorld.remove(player.joint!)
                                box.isInteracting = false
                                player.joint = nil
                                player.buttonInteract.isHidden = true
                                player.canInteract = false
                                player.contactJoint = nil
                            }
                        } else {
                            //TODO: Interact for other components
                        }
                    }
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
        
        func coinAndPlayerContact(_ contact: SKPhysicsContact){
            let bodyA = contact.bodyA
            let bodyB = contact.bodyB
            
            let coinAndPlayerContact = bodyA.categoryBitMask | bodyB.categoryBitMask == PhysicsCategory.player | PhysicsCategory.coin
            
            if (coinAndPlayerContact) {
                
                var node: SKNode?
                                
                if bodyA.categoryBitMask == PhysicsCategory.coin {
                    node = bodyA.node!
                } else {
                    node = bodyB.node!
                }
                
                
                let coinArray = level.sections[currentSection-1].coins
                
                print(level.sections[currentSection-1].coins)
                
                for i in 0..<coinArray.count {
                    let coinData = coinArray[i]
                                        
                    if coinData.position.x < (node?.position.x)! + 10 && coinData.position.x > (node?.position.x)! - 10 &&
                        coinData.position.y + 40 < (node?.position.y)! + 10 && coinData.position.y + 40 > (node?.position.y)! - 10 {
                        coins += coinData.value
                        
                        level.sections[currentSection-1].coins.remove(at: i)
                    }
                }
                
                node?.removeFromParent()

                
                print(level.sections[currentSection-1].coins)

                
                
            }
        }
        
        func getTransition(to direction: String) -> SKTransitionDirection {
            if direction == "up"{
                return SKTransitionDirection.up
            } else if direction == "down"{
                return SKTransitionDirection.down
            }else if direction == "left"{
                return SKTransitionDirection.left
            }else{
                return SKTransitionDirection.right
            }
        }
        
        func didBegin(_ contact: SKPhysicsContact) {
            
            let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            for player in players {
                if contactMask == (PhysicsCategory.player | PhysicsCategory.hazzard) {
                    // Reset player position and¸ stop its movement
                    player.position = spawn
                    player.createPhysicBody()
                    
                    //add haptic
                    if let controller = player.controller {
                        hapticsManager!.playHapticsFileController(named: "Boing", controller: controller)
                    }
                    
                    if playersAtDoorExit.contains(player){
                        playersAtDoorExit.remove(player)
                    }
                    if playersAtDoorEntry.contains(player){
                        playersAtDoorExit.remove(player)
                    }
                    
                    player.buttonInteract.isHidden = true
                    player.contactWith = nil
                    player.canInteract = false
                    player.isHidden = false
                    
                }
            }
            
            //Coin Player
            coinAndPlayerContact(contact)
            
            let bodyA = contact.bodyA
            let bodyB = contact.bodyB
            
            if bodyB.node == nil || bodyA.node == nil { return }
            
            //Box & Player
            if bodyA.categoryBitMask == PhysicsCategory.box || bodyB.categoryBitMask == PhysicsCategory.box {
                let box = (bodyA.categoryBitMask == PhysicsCategory.box) ? bodyA.node as! InteractableBox : bodyB.node  as! InteractableBox
                let playerNode = (bodyA.categoryBitMask == PhysicsCategory.player) ? bodyA.node as! Player : bodyB.node as! Player
                
                if playerNode.position.y <= box.position.y + 10 && box.isInteracting == false {
                    playerNode.buttonInteract.isHidden = false
                    playerNode.contactJoint = box
                    playerNode.canInteract = true
                }
                
                if playerNode.position.y >= box.position.y + box.size.height - 10 && box.isInteracting == false && currentSection == 4 {
                    playerNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 67))
                    let texture: [SKTexture] = (1...3).map { SKTexture(imageNamed: "trampoline\($0)")}
                    let action = SKAction.animate(with: texture, timePerFrame: 0.1)
                    box.textureNode.run(action)
                    
                }
            }
            
            
            if bodyA.categoryBitMask == PhysicsCategory.foreground || bodyB.categoryBitMask == PhysicsCategory.foreground {
                let foregroundNode = (bodyA.categoryBitMask == PhysicsCategory.foreground) ? bodyA.node as! Foreground : bodyB.node as! Foreground
                foregroundNode.didBegin(contact)
            }
            
            //Door
            if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.door) || (bodyB.categoryBitMask == PhysicsCategory.player && bodyA.categoryBitMask == PhysicsCategory.door) {
                let playerNode = (bodyA.categoryBitMask == PhysicsCategory.player) ? bodyA.node as! Player : bodyB.node as! Player
                let doorNode = (bodyA.categoryBitMask == PhysicsCategory.door) ? bodyA.node as! DoorType : bodyB.node as! DoorType
                
                if playerNode.contactJoint != nil { return }
                
                playerNode.physicsBody?.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard | PhysicsCategory.box
                
                playerNode.isHidden = false
                
                if doorNode == level.sections[currentSection-1].doorExit.doorType {
                    playerNode.buttonInteract.isHidden = false
                    playerNode.contactWith = doorNode
                    playerNode.canInteract = true
                } else if doorNode == level.sections[currentSection-1].doorEntry.doorType && currentSection != 1 {
                    playerNode.buttonInteract.isHidden = false
                    playerNode.contactWith = doorNode
                    playerNode.canInteract = true
                }
            }
        }
        
        
        func didEnd(_ contact: SKPhysicsContact) {
            let bodyA = contact.bodyA
            let bodyB = contact.bodyB
            
            if bodyB.node == nil || bodyA.node == nil { return }
            
            if (bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.door) || (bodyB.categoryBitMask == PhysicsCategory.player && bodyA.categoryBitMask == PhysicsCategory.door) {
                let playerNode = (bodyA.categoryBitMask == PhysicsCategory.player) ? bodyA.node as! Player : bodyB.node as! Player
                let doorNode = (bodyA.categoryBitMask == PhysicsCategory.door) ? bodyA.node as! DoorType : bodyB.node as! DoorType
                
                if playerNode.contactJoint != nil { return }
                
                
                playerNode.physicsBody?.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard | PhysicsCategory.box | PhysicsCategory.player
                
                playerNode.buttonInteract.isHidden = true
                playerNode.contactWith = nil
                playerNode.canInteract = false
                playerNode.isHidden = false
                
                if doorNode == level.sections[currentSection-1].doorExit.doorType {
                    playersAtDoorExit.remove(playerNode)
                } else if doorNode == level.sections[currentSection-1].doorEntry.doorType {
                    playersAtDoorEntry.remove(playerNode)
                }
                
                playerNode.physicsBody?.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.ground | PhysicsCategory.hazzard | PhysicsCategory.box | PhysicsCategory.player
            }
            
            if bodyA.categoryBitMask == PhysicsCategory.box || bodyB.categoryBitMask == PhysicsCategory.box {
                let playerNode = (bodyA.categoryBitMask == PhysicsCategory.player) ? bodyA.node as! Player : bodyB.node as! Player
                
                if playerNode.joint != nil { return}
                
                playerNode.buttonInteract.isHidden = true
                playerNode.contactJoint = nil
                playerNode.canInteract = false
            }
        }
        
        func makeCoinEntity(name: String, coin: Coin, scene: SKScene) -> GKEntity {
            let coinEntity = GKEntity()
            
            let texture = SKTexture(imageNamed: "coins")
            let coinNode = SKSpriteNode(texture: texture)
            coinNode.size = CGSize(width: 35, height: 40)
            coinNode.name = "coin"
            coinNode.position = CGPoint(x: coin.position.x, y: coin.position.y+coinNode.size.height)
            coinNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 35))
            coinNode.physicsBody?.isDynamic = true
            coinNode.physicsBody?.allowsRotation = false
            coinNode.physicsBody?.affectedByGravity = false
            coinNode.physicsBody?.categoryBitMask = PhysicsCategory.coin
            coinNode.physicsBody?.collisionBitMask = 0
            coinNode.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.platform
            coinNode.physicsBody?.contactTestBitMask = PhysicsCategory.player
            coinNode.zPosition = 10
            scene.addChild(coinNode)
            
            let coinComponent = NodeComponent(node: coinNode)
            coinEntity.addComponent(coinComponent)
            
//            let jumpComponent = JumpForeverComponent(vector: CGVector(dx: 0, dy: 40), duration: 0.5)
//            coinEntity.addComponent(jumpComponent)
            
            return coinEntity
        }
    }
    
