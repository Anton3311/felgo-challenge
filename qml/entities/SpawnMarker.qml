import QtQuick
import Felgo
import "./components"

EntityBase {
	id: marker
    entityType: "spawnMarker"

	property url enemyPrefab
	property Team enemyTeam
	property EntityBase player

	// `WaveManager` is further passed to the spawned enemy, so that it can report whenever it gets
	// killed by the player.
	property WaveManager waveManager

	function spawn() {
		entityManager.createEntityFromUrlWithProperties(marker.enemyPrefab, {
			"x": marker.x,
			"y": marker.y,
			"target": marker.player,
			"team": marker.enemyTeam,
			"waveManager": waveManager
		});

		marker.destroy();
	}

	GameSpriteSequence {
		width: 32
		height: 32
		GameSprite {
			frameCount: 3
			frameWidth: 16
			frameHeight: 16
			source: Qt.resolvedUrl("../../assets/entities/exclamationMark.png")
			frameRate: 12
		}
	}
}
