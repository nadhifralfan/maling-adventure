import SpriteKit
import GameplayKit
import GameController

class LevelSelectScene: SKScene {
    public var levels: [String: Level] = [:]
    private var currentLevel: Level?
    private var selectedButtonIndex: Int = 0
    private var buttons: [SKLabelNode] = []
    var gameControllerManager: GameControllerManager?

    override func didMove(to view: SKView) {
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
                    
                    self?.createLevelButtons()
                } else {
                    print("Waiting for controllers to connect...")
                }
            }
        }
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
            guard let self = self else {return}
            if gamepad.leftThumbstick.up.isPressed || gamepad.dpad.up.isPressed{
                selectedButtonIndex = max(selectedButtonIndex - 1, 0)
                highlightButton(at: selectedButtonIndex)
            } else if gamepad.leftThumbstick.down.isPressed || gamepad.dpad.down.isPressed {
                selectedButtonIndex = min(selectedButtonIndex + 1, buttons.count - 1)
                highlightButton(at: selectedButtonIndex)
            } else if gamepad.buttonA.isPressed && gameControllerManager!.isSelectingLevel == true {
                currentLevel = levels[String(selectedButtonIndex + 1)]
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
        let reveal = SKTransition.fade(withDuration: 3)
        gameControllerManager?.isSelectingLevel = false
        gameControllerManager?.isStoryMode = true
        let newScene = GameScene(size: self.size, level: level, section: 1, gameControllerManager: gameControllerManager!)
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
