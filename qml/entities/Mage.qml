import QtQuick
import Felgo
import "./components"

EntityBase {
	id: self
	entityId: "entity"
	entityType: "mage"

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
}
