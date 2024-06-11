import SpriteKit
import GameplayKit
import GameController

class LevelSelectScene: SKScene {
    public var levels: [String: Level] = [:]
    private var currentLevel: Level?
    private var isPlaying: Bool = false
    private var selectedButtonIndex: Int = 0
    private var buttons: [SKLabelNode] = []
    private var isLevelSelected: Bool = false
    var gameControllerManager: GameControllerManager?

    override func didMove(to view: SKView) {
        guard !levels.isEmpty else { return }

        gameControllerManager = GameControllerManager()

        // Setup the controllers and their inputs
        for controller in gameControllerManager?.controllers ?? [] {
            setupControllerInputs(controller: controller)
        }

        createLevelButtons()
    }

    func createLevelButtons() {
        for (index, _) in levels.enumerated() {
            let button = SKLabelNode(text: "Level \(index + 1)")
            button.name = "levelButton\(index)"
            button.fontSize = 24
            button.fontColor = SKColor.white
            button.position = CGPoint(x: 0, y: 0 - CGFloat(50 * (index + 1)))
            self.addChild(button)
            buttons.append(button)
        }
        
        highlightButton(at: selectedButtonIndex)
    }

    func highlightButton(at index: Int) {
        for (i, button) in buttons.enumerated() {
            button.fontColor = i == index ? SKColor.yellow : SKColor.white
        }
    }

    func setupControllerInputs(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, element) in
            self?.handleGameControllerInput(gamepad: gamepad)
        }
    }

    func handleGameControllerInput(gamepad: GCExtendedGamepad) {
        print("checked")
        if gamepad.leftThumbstick.up.isPressed {
            selectedButtonIndex = max(selectedButtonIndex - 1, 0)
            highlightButton(at: selectedButtonIndex)
        } else if gamepad.leftThumbstick.down.isPressed {
            selectedButtonIndex = min(selectedButtonIndex + 1, buttons.count - 1)
            highlightButton(at: selectedButtonIndex)
        } else if gamepad.buttonA.isPressed {
            if !isLevelSelected {
                isLevelSelected = true
                currentLevel = levels[String(selectedButtonIndex + 1)]
                if let level = currentLevel {
                    switchToGameScene(level: level)
                }
            }
        }
    }

    func switchToGameScene(level: Level) {
        let reveal = SKTransition.fade(withDuration: 3)
        let newScene = GameScene(size: self.size, level: level, section: 1, isPlaying: false, controllers: gameControllerManager?.controllers ?? [])
        self.view?.presentScene(newScene, transition: reveal)
    }

    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if let nodeName = node.name, nodeName.starts(with: "levelButton") {
                if let index = Int(nodeName.dropFirst("levelButton".count)) {
                    currentLevel = levels[String(index + 1)]
                    if let level = currentLevel {
                        switchToGameScene(level: level)
                    }
                }
            }
        }
    }

    override func keyDown(with event: NSEvent) {}

    override func update(_ currentTime: TimeInterval) {}
}
