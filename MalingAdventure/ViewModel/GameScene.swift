import SpriteKit
import GameplayKit
import GameController

class GameScene: SKScene {
    private var level: Level
    private var isPlaying: Bool = false
    private var currentStoryIndex: Int = 0
    private var currentSection: Int = 0
    private var player: Player!
    private var controllers: [GCController] = []

    init(size: CGSize, level: Level, section: Int, isPlaying: Bool, controllers: [GCController]) {
        self.level = level
        self.isPlaying = isPlaying
        self.currentSection = section
        self.controllers = controllers
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        guard !level.stories.isEmpty else {
            print("Error: No stories available in the level.")
            return
        }
        
        if isPlaying {
            createLevelContent()
        } else {
            displayCurrentStory()
        }
    }
    
    func displayCurrentStory() {
        self.removeAllChildren()
        
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
        
        let descriptionBackground = SKShapeNode(rectOf: CGSize(width: storyDescriptionNode.preferredMaxLayoutWidth, height: 100), cornerRadius: 10)
        descriptionBackground.fillColor = SKColor.black.withAlphaComponent(0.5)
        descriptionBackground.position = CGPoint(x: self.size.width / 2, y: 100)
        
        storyDescriptionNode.position = CGPoint(x: 0, y: -descriptionBackground.frame.height / 2)
        descriptionBackground.addChild(storyDescriptionNode)
        descriptionBackground.zPosition = 1
        self.addChild(descriptionBackground)
        
        let nextButton = SKLabelNode(text: "Next")
        nextButton.name = "nextButton"
        nextButton.fontSize = 24
        nextButton.fontColor = SKColor.blue
        nextButton.position = CGPoint(x: self.size.width - 50, y: 50)
        nextButton.zPosition = 1
        self.addChild(nextButton)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 1.0)
        storyImageNode.run(fadeInAction)
        descriptionBackground.run(fadeInAction)
        nextButton.run(fadeInAction)
    }
    
    func transitionToNextStory() {
        currentStoryIndex += 1
        
        if currentStoryIndex < level.stories.count {
            let transition = SKTransition.fade(withDuration: 1.0)
            let nextScene = GameScene(size: self.size, level: level, section: currentSection, isPlaying: false, controllers: controllers)
            nextScene.currentStoryIndex = currentStoryIndex
            self.view?.presentScene(nextScene, transition: transition)
        } else {
            createLevelContent()
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
        
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.size = self.size
        backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        backgroundNode.zPosition = -1
        self.addChild(backgroundNode)
        
        print(self.size.height)
        print(self.size.width)
        
        var position = CGPoint(x: 0, y: 0)
        
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
        
        for platformData in section.platforms {
            if let coordinates = platformData["coordinate"] as? [String: CGFloat],
               let size = platformData["size"] as? [String: CGFloat],
               let x = coordinates["x"],
               let y = coordinates["y"],
               let width = size["width"],
               let height = size["height"] {

                let platformNode = SKSpriteNode(color: .lightGray, size: CGSize(width: width, height: height))
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
        
        if currentSection == 1 {
            player = Player(imageNamed: "playerImage", position: CGPoint(x: 130, y: 180))
        } else if currentSection == 2 {
            player = Player(imageNamed: "playerImage", position: CGPoint(x: 0, y: 420))
        }
        player.zPosition = 4
        self.addChild(player)
        
        isPlaying = true
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
        if isPlaying {
            player.update(currentTime)
            if player.position.x >= 1020 && player.position.y >= 419 {
                let reveal = SKTransition.push(with: .left, duration: 1)
                self.removeChildren(in: [player])
                let newScene = GameScene(size: self.size, level: level, section: currentSection + 1, isPlaying: true, controllers: controllers)
                self.view?.presentScene(newScene, transition: reveal)
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if isPlaying {
            player.keyDown(with: event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if isPlaying {
            player.keyUp(with: event)
        }
    }
}
