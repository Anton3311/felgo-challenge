import QtQuick
import Felgo
import "./components"

EntityBase {
	id: self
	entityId: "entity"
	entityType: "customEntity"

	property alias damagable: myDamagable

	Damagable {
		id: myDamagable
		maxHealth: 10
		onDeath: {
			self.destroy();
		}
	}

	CircleCollider {
		id: collider
		categories: Circle.Category2
		radius: 10

		Rectangle {
			width: 20
			height: 20
			color: "green"
		}
	}
}
