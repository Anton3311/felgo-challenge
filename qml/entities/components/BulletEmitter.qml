import QtQuick
import Felgo

Item {
	id: self
	property Team team
	property url bulletPrefab

	function emit(positionX, positionY, directionX, directionY, impulse) {
		let forceVector = Qt.point(directionX * impulse, directionY * impulse)

		entityManager.createEntityFromUrlWithProperties(
			bulletPrefab,
			{
				"x": positionX,
				"y": positionY,
				"initialImpulse": forceVector,
				"team": self.team
			}
		);
	}
}
