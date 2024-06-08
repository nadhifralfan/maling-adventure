import SpriteKit
import GameplayKit
import GameController

class GameScene: SKScene, SKPhysicsContactDelegate {
    var i = 0
    private var spinnyNode: SKShapeNode?
    var player: SKSpriteNode = SKSpriteNode()
    var player2: SKSpriteNode = SKSpriteNode()
    var sceneCamera: SKCameraNode = SKCameraNode()
    private var keysPressed: Set<UInt16> = []
    var controller1 : Int = -1
    var controller2 : Int = -1
    private var thumbstickTimer: Timer?
    private var thumbstickTimer2: Timer?
    private var isThumbstickActive = false
    private var isThumbstickActive2 = false
    private var isJumping = false
    private var isJumping2 = false
    
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let player: UInt32 = 0b1
        static let player2: UInt32 = 0b10
        static let ground: UInt32 = 0b100
    }
    
    override func didMove(to view: SKView) {
        // Enable gravity in the physics world
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
        
        // Set the physics body for the scene to act as boundaries
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        sceneCamera.position = CGPoint(x: 0, y: 0)
        self.addChild(sceneCamera)
        self.camera = sceneCamera
        
        // Setup player
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 0, y: 0)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.player2
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.player2
        self.addChild(player)
        
        // Setup player2
        player2 = SKSpriteNode(imageNamed: "player")
        player2.position = CGPoint(x: 0, y: 0)
        player2.physicsBody = SKPhysicsBody(rectangleOf: player2.size)
        player2.physicsBody?.affectedByGravity = true
        player2.physicsBody?.allowsRotation = false
        player2.physicsBody?.categoryBitMask = PhysicsCategory.player2
        player2.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.player
        player2.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.player
        self.addChild(player2)
        
        // Set the background image
        let background = SKSpriteNode(imageNamed: "background")
        background.size = CGSize(width: 3456, height: 1117)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 3)
        background.zPosition = -1
        self.addChild(background)
        
        // Add ground node
        let ground = SKSpriteNode(color: .brown, size: CGSize(width: background.size.width, height: 800))
        ground.position = CGPoint(x: self.size.width / 2, y: -self.size.height / 2 - 250)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.player2
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.player2
        self.addChild(ground)

        
        NotificationCenter.default.addObserver(self, selector: #selector(controllerConnected), name: .GCControllerDidConnect, object: nil)
        GCController.startWirelessControllerDiscovery(completionHandler: nil)
    }
    
    @objc func controllerConnected(notification: Notification) {
        if let controller = notification.object as? GCController {
            
            if controller1 == -1 && controller2 == -1 {
                controller.playerIndex = GCControllerPlayerIndex.index1
                controller1 = controller.playerIndex.rawValue
            } else if controller1 != -1 && controller2 == -1 && controller.playerIndex.rawValue != controller1 {
                controller.playerIndex = GCControllerPlayerIndex.index2
                controller2 = controller.playerIndex.rawValue
            }
            
            
            if let gamepad = controller.extendedGamepad {
                gamepad.leftThumbstick.valueChangedHandler = { [weak self] (dpad, xValue, yValue) in
                    // Update thumbstick status
                    if controller.playerIndex.rawValue == 0 {
                        self?.isThumbstickActive = !(xValue == 0 && yValue == 0 && controller.playerIndex.rawValue == 0)
                        self?.thumbstickTimer?.invalidate()
                        self?.thumbstickTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                            // Handle thumbstick input continuously
                            let index = controller.playerIndex.rawValue
                            self?.handleThumbstickInput(xValue: xValue, yValue: yValue, index: index)
                        })
                    } else {
                        self?.isThumbstickActive2 = !(xValue == 0 && yValue == 0 && controller.playerIndex.rawValue == 1)
                        self?.thumbstickTimer2?.invalidate()
                        self?.thumbstickTimer2 = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                            // Handle thumbstick input continuously
                            let index = controller.playerIndex.rawValue
                            self?.handleThumbstickInput(xValue: xValue, yValue: yValue, index: index)
                        })
                    }
                }

                gamepad.buttonA.pressedChangedHandler = { [weak self] (button, value, pressed) in
                    if pressed {
                        if controller.playerIndex.rawValue == 0 {
                            self?.jump(player: self?.player)
                        } else if controller.playerIndex.rawValue == 1 {
                            self?.jump(player: self?.player2)
                        }
                    }
                }
                
                gamepad.leftShoulder.pressedChangedHandler = { [weak self] (button, value, pressed) in
                    if pressed {
                        if controller.playerIndex.rawValue == 0 {
                            self?.player.position.x -= CGFloat(10.0)
                        } else if controller.playerIndex.rawValue == 1 {
                            self?.player2.position.x -= CGFloat(10.0)
                        }
                    }
                }
                
                gamepad.rightShoulder.pressedChangedHandler = { [weak self] (button, value, pressed) in
                    if pressed {
                        print("pressed")
                        if controller.playerIndex.rawValue == 0 {
                            self?.player.position.x += CGFloat(10.0)
                        } else if controller.playerIndex.rawValue == 1 {
                            self?.player2.position.x += CGFloat(10.0)
                        }
                    }
                }
            }
        }
    }
    
    func handleThumbstickInput(xValue: Float, yValue: Float, index: Int) {
        let speed: CGFloat = 10.0
        
        // Determine the movement direction based on thumbstick values
        var movementDirection = CGVector(dx: CGFloat(xValue), dy: CGFloat(yValue))
        // Normalize the movement direction to ensure consistent speed regardless of direction
        let magnitude = sqrt(movementDirection.dx * movementDirection.dx + movementDirection.dy * movementDirection.dy)
        if magnitude > 1 {
            movementDirection.dx /= magnitude
            movementDirection.dy /= magnitude
        }
        
        // Move the player continuously in the determined direction if thumbstick is active
        if isThumbstickActive && index == 0 {
            player.position.x += movementDirection.dx * speed
        } else if isThumbstickActive2 && index == 1 {
            player2.position.x += movementDirection.dx * speed
        } else {
            // Invalidate the timer when thumbstick is released to stop continuous movement
            thumbstickTimer?.invalidate()
            thumbstickTimer2?.invalidate()
        }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        if let n = self.spinnyNode?.copy() as? SKShapeNode {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos: CGPoint) {
        if let n = self.spinnyNode?.copy() as? SKShapeNode {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos: CGPoint) {
        if let n = self.spinnyNode?.copy() as? SKShapeNode {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        keysPressed.insert(event.keyCode)
        
        if event.keyCode == 126 { // Up arrow key
            jump(player: player)
        } else if event.keyCode == 13 { // W key
            jump(player: player2)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        keysPressed.remove(event.keyCode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if keysPressed.contains(126) {
            jump(player: player)
        }
        if keysPressed.contains(13) {
            jump(player: player2)
        }
        if keysPressed.contains(123) {
            player.position.x -= CGFloat(10.0)
        }
        if keysPressed.contains(124) {
            player.position.x += CGFloat(10.0)
        }
        if keysPressed.contains(0) {
            player2.position.x -= CGFloat(10.0)
        }
        if keysPressed.contains(2) {
            player2.position.x += CGFloat(10.0)
        }
        
        if player.position.x > 450 && player2.position.x > 450 && i == 0 {
            i += 1
            player.position.x += 100
            player2.position.x += 100
            if let camera = camera {
                let moveAction = SKAction.moveBy(x: 1100, y: 0, duration: 1.0)
                moveAction.timingMode = .easeIn
                camera.run(moveAction)
            }
        } else if player.position.x < 570 && player2.position.x < 570 && i == 1 {
            i -= 1
            if let camera = camera {
                let moveAction = SKAction.moveBy(x: -1100, y: 0, duration: 1.0)
                moveAction.timingMode = .easeIn
                camera.run(moveAction)
            }
            player.position.x -= 100
            player2.position.x -= 100
        }
    }

    
    func jump(player: SKSpriteNode?) {
        guard let player = player, isPlayerOnGround(player: player) else { return }
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
    }
    
    func isPlayerOnGround(player: SKSpriteNode) -> Bool {
        return player.physicsBody?.velocity.dy == 0
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (PhysicsCategory.player | PhysicsCategory.ground) {
            isJumping = false
        } else if contactMask == (PhysicsCategory.player2 | PhysicsCategory.ground) {
            isJumping2 = false
        }
    }
}
