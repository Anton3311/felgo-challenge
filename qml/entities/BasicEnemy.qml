import QtQuick
import Felgo
import "./components"

EntityBase {
	id: self
	entityId: "entity"
	entityType: "basicEnemy"

	property alias damagable: myDamagable
	property Team team

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

	Timer {
		interval: 2 * 1000
		repeat: true
		running: true
		onTriggered: {
			let count = 6;
			let angleStep = Math.PI / count;
			for (let i = 0; i < count; i += 1) {
				let angle = angleStep * i;

				let x = Math.cos(angle);
				let y = Math.sin(angle);
				bulletEmitter.emit(self.x + x, self.y + y, x, y, 200);
			}
		}
	}

	CircleCollider {
		id: collider
		categories: team.entityCategory
		collidesWith: team.entityCollisionCategories
		radius: 10

		Rectangle {
			width: 20
			height: 20
			color: "green"
		}
	}
}
