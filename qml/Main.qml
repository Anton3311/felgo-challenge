import Felgo 4.0
import QtQuick 2.0
import "./entities"

GameWindow {
    id: gameWindow
    activeScene: scene
    screenWidth: 960
    screenHeight: 640

	property int levelSize: 300
	property int wallThickness: 10

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

        PhysicsWorld {
            id: physicsWorld
            gravity.y: 0
            updatesPerSecondForPhysics: 60
            velocityIterations: 5
			positionIterations: 5
			debugDrawVisible: true
		}

		Keys.forwardTo: player.controller

		EntityBase {
			id: levelWalls
			width: levelSize
			height: levelSize
			anchors.centerIn: scene

			// Left
			BoxCollider {
				width: parent.width; height: wallThickness
				bodyType: Body.Static
				categories: Box.Category1 | Box.Category2
			}
			Rectangle {
				width: parent.width; height: wallThickness
				color: "blue"
			}

			// Down
			BoxCollider {
				y: levelSize - wallThickness
				width: parent.width; height: wallThickness
				bodyType: Body.Static
				categories: Box.Category1 | Box.Category2
			}
			Rectangle {
				y: levelSize - wallThickness
				width: parent.width; height: wallThickness
				color: "blue"
			}

			// Left
			BoxCollider {
				width: wallThickness; height: levelSize 
				bodyType: Body.Static
				categories: Box.Category1 | Box.Category2
			}
			Rectangle {
				width: wallThickness; height: levelSize
				color: "blue"
			}

			// Right
			BoxCollider {
				x: levelSize - wallThickness
				width: wallThickness; height: levelSize
				bodyType: Body.Static
				categories: Box.Category1 | Box.Category2
			}
			Rectangle {
				x: levelSize - wallThickness
				width: wallThickness; height: levelSize
				color: "blue"
			}
		}

		Player {
			id: player
			speed: 10
			crosshair: corsshair
			x: levelWalls.x + levelSize / 2
			y: levelWalls.y + levelSize / 4 * 3
		}

        EntityBase {
            id: corsshair
            Rectangle {
                width: 5
                height: 5
                color: "white"
            }
        }

		MouseArea {
			id: mouseArea
			enabled: true
			anchors.fill: scene
            hoverEnabled: true
            onPositionChanged: (event) => {
                corsshair.x = event.x - corsshair.width / 2;
                corsshair.y = event.y - corsshair.height / 2;
            }
			onPressed: (event) => {
				player.shoot();
			}
		}
	}
}
