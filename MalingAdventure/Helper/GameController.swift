import SwiftUI
import GameController

class GameControllerManager: ObservableObject {
    var controllers: [GCController] = []
    var isSelectingLevel: Bool = false
    var isPlaying: Bool = false
    var isPaused: Bool = false
    var isGameOver: Bool = false
    var isGameWon: Bool = false
    var isStoryMode: Bool = false

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerConnected),
            name: .GCControllerDidConnect,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDisconnected),
            name: .GCControllerDidDisconnect,
            object: nil
        )

        GCController.startWirelessControllerDiscovery {
            print("Wireless controller discovery complete.")
        }
    }

    @objc func controllerConnected(notification: Notification) {
        if let controller = notification.object as? GCController {
            if !controllers.contains(controller) {
                controllers.append(controller)
            }
            if controller.playerIndex == .indexUnset {
                controller.playerIndex = GCControllerPlayerIndex(rawValue: controllers.count - 1) ?? .indexUnset
            }
        }
    }

    @objc func controllerDisconnected(notification: Notification) {
        if let disconnectedController = notification.object as? GCController {
            controllers.removeAll { $0 == disconnectedController }
            print("Controller disconnected: \(disconnectedController)")
        }
    }
    func resetGameState() {
        isSelectingLevel = true
        isPlaying = false
        isPaused = false
        isGameOver = false
        isGameWon = false
        isStoryMode = false
    }
    func setupControllerInputs(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, element) in
            guard let self = self else {return}
            if isSelectingLevel{
                print("in selecting Level")
                if gamepad.buttonA.isPressed {
                    print("Button A pressed")
                }
                if gamepad.leftThumbstick.valueChangedHandler != nil {
                    print("leftThumbstick value changed")
                }
            } else if self.isStoryMode {
                print("in story mode")
                if gamepad.buttonA.isPressed {
                    print("Button A pressed")
                }
                if gamepad.leftThumbstick.valueChangedHandler != nil {
                    print("leftThumbstick value changed")
                }
            } else if self.isPlaying {
                print("in game")
                if gamepad.buttonA.isPressed {
                    print("Button A pressed")
                }
                if gamepad.leftThumbstick.valueChangedHandler != nil {
                    print("leftThumbstick value changed")
                }
            } else if self.isPaused {
                print("in paused")
                if gamepad.buttonA.isPressed {
                    print("Button A pressed")
                }
                if gamepad.leftThumbstick.valueChangedHandler != nil {
                    print("leftThumbstick value changed")
                }
            }
        }
    }
}
