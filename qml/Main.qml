import Felgo 4.0
import QtQuick 2.0
import "./entities"
import "./entities/components"

GameWindow {
    id: gameWindow
    activeScene: scene
    screenWidth: 960
    screenHeight: 640

	property int levelSize: 300
	property int wallThickness: 10

	property int wallCategory: Fixture.Category1

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
			debugDrawVisible: false
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
				categories: wallCategory
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
				categories: wallCategory
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
				categories: wallCategory
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
				categories: wallCategory
			}
			Rectangle {
				x: levelSize - wallThickness
				width: wallThickness; height: levelSize
				color: "blue"
			}
		}

		Team {
			id: playerTeam
			debugName: "player"
			entityCategory: Fixture.Category2
			entityCollisionCategories: wallCategory | Fixture.Category2 | Fixture.Category4
			bulletCategory: Fixture.Category4

			// Don't include `entityCategory` (`Fixture.Category2`) in the collision mask, so that
			// the player doesn't collide with its own bullets.
			bulletCollisionCategories: wallCategory | Fixture.Category3
		}

		Team {
			id: enemyTeam
			debugName: "enemies"
			entityCategory: Fixture.Category3
			entityCollisionCategories: wallCategory | Fixture.Category3 | Fixture.Category4
			bulletCategory: Fixture.Category4

			// Don't include `Fixture.Category3` which is an `entityCategory`, to make sure that the
			// bullets created by enemies, don't collide with other enemies, as well as, the one
			// that created them
			bulletCollisionCategories: wallCategory | Fixture.Category2
		}

		Player {
			id: player
			team: playerTeam
			speed: 10
			crosshair: crosshair
			x: levelWalls.x + levelSize / 2
			y: levelWalls.y + levelSize / 4 * 3
		}

        EntityBase {
            id: crosshair
            Rectangle {
                width: 5
                height: 5
                color: "white"
            }
        }

		BasicEnemy {
			id: enemy
			team: enemyTeam
			x: levelWalls.x + levelSize * 0.2
			y: levelWalls.y + levelSize * 0.4
		}

		MouseArea {
			id: mouseArea
			enabled: true
			anchors.fill: scene
            hoverEnabled: true
            onPositionChanged: (event) => {
                crosshair.x = event.x - crosshair.width / 2;
                crosshair.y = event.y - crosshair.height / 2;
            }
			onPressed: (event) => {
				player.shoot();
			}
		}

		Item {
			id: playerHealthDisplay
			x: 0
			y: 50
			width: 100
			height: 20
			Text {
				text: player.damagable.health
				color: "white"
			}
		}
	}
}
