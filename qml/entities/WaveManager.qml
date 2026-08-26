import QtQuick
import Felgo
import "./components"

EntityBase {
	entityId: "entity"
	entityType: "waveManager"
    id: self

	property Team enemyTeam
	property EntityBase player

	property var waveTypes

	// How long to wait before starting the first wave
	property int initialDelay

	// How long to wait before starting the next wave
	property int inBetweenWavesDelay

	// Current number of enemies in the level
	property int currentEnemyCount

	// The bounding box of the spawn area
	property point spawnAreaMin
	property point spawnAreaMax

	property var markers: []

	state: "waitForFirst"
	states: [
		State {
			name: "waitForFirst"
			StateChangeScript {
				script: {
					firstWaveStartDelayTimer.start();
				}
			}
		},
		State {
			name: "waitBeforeNext"
			StateChangeScript {
				script: {
					inBetweenWavesDelayTimer.start();
				}
			}
		},
		State {
			name: "waitForCompletion"
			PropertyChanges { target: firstWaveStartDelayTimer; running: false }
		}
	]

	Timer {
		id: firstWaveStartDelayTimer
		interval: initialDelay
		repeat: false
		running: false
		onTriggered: {
			self.prepareNextWave();
		}
	}

	Timer {
		id: inBetweenWavesDelayTimer
		interval: inBetweenWavesDelay
		repeat: false
		running: false
		onTriggered: {
			self.beginNextWave();
		}
	}

	function randomInRange(min, max) {
		return min + Math.random() * (max - min);
	}

	// Prepares the next wave by placing spawn markers randomly around the level
	function prepareNextWave() {
		let waveTypeIndex = Math.floor(Math.random() * self.waveTypes.length)

		for (let enemyType of self.waveTypes[waveTypeIndex]) {
			let spawnPositionX = randomInRange(self.spawnAreaMin.x, self.spawnAreaMax.x);
			let spawnPositionY = randomInRange(self.spawnAreaMin.y, self.spawnAreaMax.y);

			let markerId = entityManager.createEntityFromUrlWithProperties(
				Qt.resolvedUrl("./SpawnMarker.qml"),
				{
					"x": spawnPositionX,
					"y": spawnPositionY,
					"enemyPrefab": enemyType,
					"enemyTeam": self.enemyTeam,
					"player": self.player
				}
			);

			let marker = entityManager.getEntityById(markerId);
			self.markers.push(marker);
		}

		state = "waitBeforeNext"
	}

	// Actually spawns the enemies, at placed spawn markers
	function beginNextWave() {
		for (let marker of self.markers) {
			marker.spawn();
		}

		self.markers.length = 0;
		state = "waitForCompletion"
	}
}
