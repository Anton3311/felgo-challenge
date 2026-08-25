import QtQuick
import Felgo
import "./components"

EntityBase {
	id: self
	entityId: "entity"
	entityType: "basicEnemy"

	property alias damagable: myDamagable
	property Team team

	// The current target entity, this enemy will try to attack.
	//
	// Well, it can only be the player or null.
	property EntityBase target: null
	property int attackRange: 220

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
			self.destroy();
		}
	}

	BulletEmitter {
		id: bulletEmitter
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

					collider.linearVelocity = Qt.point(dx * 200, dy * 200);
				}

				break;
			}
		}
	}

	Timer {
		id: attackTimer
		interval: 1.2 * 1000
		repeat: true
		running: false
		onTriggered: {
			let count = 6;
			let angleStep = 2 * Math.PI / count;
			for (let i = 0; i < count; i += 1) {
				let angle = angleStep * i;

				let x = Math.cos(angle);
				let y = Math.sin(angle);
				bulletEmitter.emit(self.x + x, self.y + y, x, y, 150);
			}
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
