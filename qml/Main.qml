import Felgo 4.0
import QtQuick 2.0
import "./entities"

GameWindow {
    id: gameWindow
    activeScene: scene
    screenWidth: 960
    screenHeight: 640

    Scene {
        id: scene
        focus: true

        Item {
            id: level
        }

        EntityManager {
            id: entityManager
            entityContainer: level
        }

        Keys.forwardTo: player.controller

        Player {
            id: player
            speed: 10
        }
    }
}
