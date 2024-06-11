import SwiftUI
import GameController

class GameControllerManager: ObservableObject {
    @Published var controllers: [GCController] = []

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
                setupControllerInputs(controller: controller)
            }
            if controller.playerIndex == .indexUnset {
                controller.playerIndex = GCControllerPlayerIndex(rawValue: controllers.count - 1) ?? .indexUnset
            }
            print("Controller connected: \(controller)")
        }
    }

    @objc func controllerDisconnected(notification: Notification) {
        if let disconnectedController = notification.object as? GCController {
            controllers.removeAll { $0 == disconnectedController }
            print("Controller disconnected: \(disconnectedController)")
        }
    }

    func setupControllerInputs(controller: GCController) {
//        controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad, element) in
//            guard let self = self else { return }
//            // Handle gamepad input here
//            print("Gamepad input detected")
//            if let buttonA = gamepad.buttonA, buttonA.isPressed {
//                print("Button A pressed")
//            }
//            let leftThumbstick = gamepad.leftThumbstick
//            print("Left Thumbstick x: \(leftThumbstick.xAxis.value), y: \(leftThumbstick.yAxis.value)")
//        }
    }
}
