import QtQuick
import Felgo
import "./components"

EntityBase {
	id: self
	entityId: "entity"
	entityType: "mage"

	property alias damagable: myDamagable
	property Team team

	// The target entity, this enemy will try to attack.
	property EntityBase target
	property int attackRange: 220

	Component.onCompleted: {
		bulletEmitter.team = team
		damagable.team = team
	}

	Damagable {
		id: myDamagable
		maxHealth: 10
		onDeath: {
			self.destroy();
		}
	}

	BulletEmitter {
		id: bulletEmitter
		emissionOrigin: self
		bulletPrefab: Qt.resolvedUrl("./Bullet.qml")
	}

	CircleCollider {
		id: collider
		categories: team.entityCategory
		collidesWith: team.entityCollisionCategories
		radius: 16
		fixedRotation: true
		linearDamping: 1

		Image {
			id: sprite
			anchors.centerIn: parent.anchors.center
			smooth: false
			source: Qt.resolvedUrl("../../assets/entities/mage.png")
			width: 32
			height: 32
			mirror: collider.linearVelocity.x < 0
		}
	}

	state: "follow"
	states: [
		State {
			name: "follow"
			PropertyChanges { target: attackTimer; running: false }
		},
		State {
			name: "attack"
			PropertyChanges { target: attackTimer; running: true }
		}
	]

	function isTargetWithinRange() {
		if (target === null) {
			return false;
		}

		let dx = target.x - self.x
		let dy = target.y - self.y
		let distanceToTarget = Math.sqrt(dx * dx + dy * dy)
		return distanceToTarget <= attackRange;
	}

	Timer {
		id: updateTimer 
		interval: 16
		running: true
		repeat: true
		onTriggered: {
			// Here we update the whole state machine of this enemy

			switch (state) {
			case "attack":
				if (!isTargetWithinRange()) {
					// No target in range, go back to following
					state = "follow"
				}

				break;
			case "follow":
				if (isTargetWithinRange()) {
					state = "attack";
				} else {
					let dx = target.x - self.x
					let dy = target.y - self.y
					let distanceToTarget = Math.sqrt(dx * dx + dy * dy)

					dx /= distanceToTarget;
					dy /= distanceToTarget;

					collider.linearVelocity = Qt.point(dx * 80, dy * 80);
				}

				break;
			}
		}
	}

	function lerp(min, max, t) {
		return min * (1 - t) + max * t;
	}

	Timer {
		id: attackTimer
		interval: 1.2 * 1000
		repeat: true
		running: false
		onTriggered: {
			if (target === null) {
				return;
			}

			let halfSize = 2;
			let patternScale = 10;

			// The primary attack pattern consists of 5 bullets (for example), placed in shape
			// resembling a tent.
			//
			// The whole attack pattern can be described by this function.
			// let tent = (x) => halfSize - Math.abs(x)
			// 
			// And will look like this:
			//     *
			//   *   *
			// *       *

			// This pattern should also be aligned towards the player, so for that we will need to
			// defined a little 2D basis.
			let dx = target.x - self.x
			let dy = target.y - self.y
			let distanceToTarget = Math.sqrt(dx * dx + dy * dy);

			// Forward vector, pointing towards the player
			//
			// Normalize it first.
			let forwardX = dx / distanceToTarget;
			let forwardY = dy / distanceToTarget;
			// Right vector. If you were to look along the `forward` vector, `right` is orthogonal
			// to `forward` and points exactly to the right.
			let rightX = forwardY;
			let rightY = -forwardX;

			for (let i = -halfSize; i <= halfSize; i += 1) {
				// The position of the bullet locally in our basis
				let localX = i;
				let localY = halfSize - Math.abs(localX);

				// The position of the bullet, local to the enemy + aligned towards the player
				let globalX = rightX * localX + forwardX * localY
				let globalY = rightY * localX + forwardY * localY;

				bulletEmitter.emit(
					globalX * patternScale,
					globalY * patternScale,
					// Send all the bullets in the same direction, towards the player
					forwardX,
					forwardY,
					150);
			}
		}
	}
}
