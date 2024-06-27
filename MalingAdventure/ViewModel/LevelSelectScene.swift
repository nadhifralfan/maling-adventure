import SpriteKit
import GameplayKit
import GameController

class LevelSelectScene: SKScene {
    public var levels: [String: Level] = [:]
    private var currentLevel: Level?
    private var selectedButtonIndex: Int = 0
    private var buttons: [SKLabelNode] = []
    var gameControllerManager: GameControllerManager?
    var hapticsManager: HapticsManager?

    let info = SKLabelNode(text: "Waiting for controllers to connect...")

    override func didMove(to view: SKView) {
        guard !levels.isEmpty else { return }
        
        if let gameControllerManager = gameControllerManager {
            gameControllerManager.isSelectingLevel = true
            
            self.info.position.x = 30
            self.info.position.y = 100
            self.addChild(self.info)
            
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
        self.createLevelButtons()
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
        
        info.removeFromParent()
        
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
            SoundManager.playClick()
            if gamepad.dpad.up.isPressed{
                selectedButtonIndex = max(selectedButtonIndex - 1, 0)
                highlightButton(at: selectedButtonIndex)
            } else if gamepad.dpad.down.isPressed {
                selectedButtonIndex = min(selectedButtonIndex + 1, buttons.count - 1)
                highlightButton(at: selectedButtonIndex)
            } else if gamepad.buttonA.isPressed && gameControllerManager!.isSelectingLevel == true {
                currentLevel = levels[String(selectedButtonIndex + 1)]
                if let level = currentLevel {
                    switchToGameScene(level: level)
                }
            }
        }
        controller.extendedGamepad?.leftThumbstick.up.pressedChangedHandler = { [weak self] (button, value, pressed) in
            guard let self = self else { return }
            if pressed {
                selectedButtonIndex = max(selectedButtonIndex - 1, 0)
                highlightButton(at: selectedButtonIndex)
                SoundManager.playClick()
            }
        }

        controller.extendedGamepad?.leftThumbstick.down.pressedChangedHandler = { [weak self] (button, value, pressed) in
            guard let self = self else { return }
            if pressed {
                selectedButtonIndex = min(selectedButtonIndex + 1, buttons.count - 1)
                highlightButton(at: selectedButtonIndex)
                SoundManager.playClick()
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
        let gameModel = GameModel(
            size: size,
            level: level,
            section: 1,
            gameControllerManager: gameControllerManager!,
            spawn: level.sections[0].spawnEntry,
            hapticsManager: hapticsManager!,
            coins: 0,
            boxPositions: [CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 0)],
            buttonsPressed: 0
        )
        let newScene = GameScene(gameModel)
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

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 126 {
            selectedButtonIndex = max(selectedButtonIndex - 1, 0)
            highlightButton(at: selectedButtonIndex)
        }
        if event.keyCode == 125 {
            selectedButtonIndex = min(selectedButtonIndex + 1, buttons.count - 1)
            highlightButton(at: selectedButtonIndex)
        }
        if event.keyCode == 36 && gameControllerManager!.isSelectingLevel == true{
            currentLevel = levels[String(selectedButtonIndex + 1)]
            if let level = currentLevel {
                SoundManager.playClick()
                switchToGameScene(level: level)
            }
        }
        if event.characters == "w"{
            SoundManager.play("diamond")
        }
        if event.characters == "a"{
            SoundManager.play("coin")
        }
    }

    override func update(_ currentTime: TimeInterval) {}
}
