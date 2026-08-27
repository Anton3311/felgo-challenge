import QtQuick
import Felgo

import "../entities"
import "../entities/components"
import "../ui"

Scene {
	id: scene

	property font pixelFont

	property int levelSize: 176 * 2
	property int wallThickness: 10
	property int wallCategory: Fixture.Category1
	property int backgroundZOrder: -100

	Component.onCompleted: {
		levelBackground.levelSize = levelSize
		levelBackground.wallThickness = wallThickness
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
		debugDrawVisible: false
	}

	Keys.forwardTo: [player.controller, startListener]

	Item {
		id: startListener
		Keys.onPressed: (event) => {
			if (event.key == Qt.Key_Space) {
				gameWindow.state = "game"
			}
		}
	}

	LevelBackground {
		id: levelBackground
		anchors.fill: scene
		z: backgroundZOrder

		Column {
			width: parent.width
			y: 50
			spacing: 12
			Text {
				width: parent.width
				horizontalAlignment: Text.Center
				text: "Press [Space] to start"
				font.family: pixelFont.family
				font.styleName: pixelFont.styleName
				font.pixelSize: 24
				color: "white"
			}
			Column {
				id: runStatistics
				enabled: false
				opacity: 0
				width: parent.width
				Text {
					id: wavesCompletedText
					width: parent.width
					horizontalAlignment: Text.Center
					text: ""
					font.family: pixelFont.family
					font.styleName: pixelFont.styleName
					font.pixelSize: 16
					color: "white"
				}
				Text {
					id: enemiesKilledText
					width: parent.width
					horizontalAlignment: Text.Center
					text: ""
					font.family: pixelFont.family
					font.styleName: pixelFont.styleName
					font.pixelSize: 16
					color: "white"
				}
			}
		}
	}

	function displayRunStatistics(wavesCompleted, enemiesKilled) {
		runStatistics.enabled = true;
		runStatistics.opacity = 1
		wavesCompletedText.text = "Waves completed " + wavesCompleted
		enemiesKilledText.text = "Enemies killed " + enemiesKilled
	}

	property alias levelWalls: levelBackground.levelWalls

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

	Player {
		id: player
		team: playerTeam
		speed: 150
		crosshair: crosshair
		x: levelWalls.x + levelSize / 2
		y: levelWalls.y + levelSize / 4 * 3
	}
}
