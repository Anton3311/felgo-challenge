import QtQuick
import Felgo
import "./components"

EntityBase {
	id: self
	entityId: "entity"
	entityType: "basicEnemy"

	property alias damagable: myDamagable
	property Team team

	// The target entity, this enemy will try to attack.
	property EntityBase target
	property int attackRange: 220

	// The `WaveManager` in order to report whenevere this enemy gets killed
	property WaveManager waveManager

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

	Component.onCompleted: {
		bulletEmitter.team = team
		damagable.team = team
	}

	Damagable {
		id: myDamagable
		maxHealth: 10
		onDeath: {
			emitBulletsOnDeath();
			waveManager.reportEnemyGotKilled();
			self.destroy();
		}
	}

	BulletEmitter {
		id: bulletEmitter
		emissionOrigin: self
		bulletPrefab: Qt.resolvedUrl("./Bullet.qml")
	}

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
				// Actual bullet emission is ran on its own timer
				//
				// So here we only have to check, whether the target is still in range
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

	function randomInRange(min, max) {
		let value = Math.random();
		return min + value * (max - min)
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

			let dx = target.x - self.x
			let dy = target.y - self.y
			let angleTowardsTarget = Math.atan2(dy, dx)

			let spread = Math.PI / 6;
			let count = 6;
			for (let i = 0; i < count; i += 1) {
				let spreadAngle = randomInRange(-spread / 2, spread / 2)
				let angle = angleTowardsTarget + spreadAngle

				let x = Math.cos(angle);
				let y = Math.sin(angle);
				bulletEmitter.enqueueForEmittion(0, 0, x, y, 150);
			}
		}
	}

	function emitBulletsOnDeath() {
		let count = 12;
		let angleStep = 2 * Math.PI / count
		for (let i = 0; i < count; i += 1) {
			let angle = angleStep * i;

			let x = Math.cos(angle);
			let y = Math.sin(angle);

			// Emit immediately, since the entity won't live long enough. Since `BulletEmitter`
			// uses a timer to dequeue requests one by one.
			bulletEmitter.emit(0, 0, x, y, 150);
		}
	}

	CircleCollider {
		id: collider
		categories: team.entityCategory
		collidesWith: team.entityCollisionCategories
		radius: 16
		fixedRotation: true
		linearDamping: 1

		Image {
			anchors.centerIn: parent.anchors.center
			smooth: false
			source: Qt.resolvedUrl("../../assets/entities/ghost.png")
			width: 32
			height: 32
			mirror: collider.linearVelocity.x < 0
		}
	}
}
