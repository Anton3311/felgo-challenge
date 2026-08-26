import Felgo 4.0
import QtQuick 2.0
import "./entities"
import "./entities/components"
import "./ui"

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

		Component.onCompleted: {
			scene.initializeWaveVariants();
		}

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
			speed: 150
			crosshair: crosshair
			x: levelWalls.x + levelSize / 2
			y: levelWalls.y + levelSize / 4 * 3
		}

        EntityBase {
            id: crosshair
			Image {
				smooth: false
				anchors.centerIn: parent
				source: Qt.resolvedUrl("../assets/entities/crosshair.png")
				width: 16
				height: 16
			}
        }

		property url ghostPrefab: Qt.resolvedUrl("./entities/Ghost.qml")
		property url magePrefab: Qt.resolvedUrl("./entities/Mage.qml")

		WaveManager {
			id: waveManager
			enemyTeam: enemyTeam
			player: player
			waveTypes: []
			initialDelay: 6000
			inBetweenWavesDelay: 5000
			spawnAreaMin: Qt.point(levelWalls.x + 48, levelWalls.y + 48)
			spawnAreaMax: Qt.point(levelWalls.x + levelSize - 48, levelWalls.y + levelSize - 48)
		}

		function initializeWaveVariants() {
			let ghostPrefab = Qt.resolvedUrl("./entities/Ghost.qml");
			let magePrefab = Qt.resolvedUrl("./entities/Mage.qml");

			waveManager.waveTypes = [
				[ghostPrefab],
				[magePrefab],
				[ghostPrefab, ghostPrefab],
				[magePrefab, magePrefab],
				[magePrefab, ghostPrefab],
			];
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

		PlayerHealthBar {
			damagable: player.damagable
			fullHeartImage: Qt.resolvedUrl("../assets/entities/heartFull.png")
			emptyHeartImage: Qt.resolvedUrl("../assets/entities/heartEmpty.png")
		}
	}
}
