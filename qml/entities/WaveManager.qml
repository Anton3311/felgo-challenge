import QtQuick
import Felgo
import "./components"

EntityBase {
	entityId: "entity"
	entityType: "waveManager"
    id: self

	property int waveIndex: 0

	property Team enemyTeam
	property EntityBase player

	property var waveTypes

	// How long to wait before starting the first wave
	property int initialDelay

	// How long to wait before starting the next wave
	property int inBetweenWavesDelay

	// Current number of enemies in the level.
	//
	// When this count reches 0, the next wave starts.
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
					inBetweenWavesDelayTimer.restart();
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
		if (self.currentEnemyCount != 0) {
			throw "Can't start a wave before the current one has finished"
		}

		console.debug("prepareNextWave");

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
					"player": self.player,
					"waveManager": self,
				}
			);

			let marker = entityManager.getEntityById(markerId);
			self.markers.push(marker);
		}

		self.currentEnemyCount = self.markers.length

		state = "waitBeforeNext"
	}

	// Actually spawns the enemies, at placed spawn markers
	function beginNextWave() {
		console.debug("beginNextWave");

		for (let marker of self.markers) {
			marker.spawn();
		}

		self.markers.length = 0;
		state = "waitForCompletion"

		self.waveIndex += 1;
	}

	function reportEnemyGotKilled() {
		if (self.currentEnemyCount == 0) {
			throw "`reportEnemyGotKilled` was called more times than there were enemies in the level";
		}

		self.currentEnemyCount -= 1
		if (self.currentEnemyCount == 0) {
			// The player has killed all the enemies, prepare the next wave.
			self.prepareNextWave();
		}
	}
}
