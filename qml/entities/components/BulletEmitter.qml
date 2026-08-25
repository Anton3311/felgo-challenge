import QtQuick
import Felgo

Item {
	id: self
	property Team team
	property url bulletPrefab
	property Item emissionOrigin

	property var queue: []

	Timer {
		running: true
		interval: 100
		repeat: true
		onTriggered: {
			if (queue.length === 0) {
				return;	
			}

			let first = self.queue.shift();
			emit(first.x,
				first.y,
				first.directionX,
				first.directionY,
				first.impulse);
		}
	}

	// Here `positionX` and `positionY` are local to the `emissionOrigin` entity
	function enqueueForEmittion(positionX, positionY, directionX, directionY, impulse) {
		self.queue.push({
			"x": positionX,
			"y": positionY,
			"directionX": directionX,
			"directionY": directionY,
			"impulse": impulse
		})
	}

	// Here `positionX` and `positionY` are local to the `emissionOrigin` entity
	function emit(positionX, positionY, directionX, directionY, impulse) {
		let forceVector = Qt.point(directionX * impulse, directionY * impulse)

		entityManager.createEntityFromUrlWithProperties(
			bulletPrefab,
			{
				"x": positionX + self.emissionOrigin.x,
				"y": positionY + self.emissionOrigin.y,
				"initialImpulse": forceVector,
				"team": self.team
			}
		);
	}
}
