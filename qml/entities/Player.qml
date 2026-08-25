import QtQuick
import Felgo
import "./components"

EntityBase {
	id: player

	entityId: "entity"
	entityType: "player"

	property Team team
	property int speed
	property EntityBase crosshair
	property alias controller: axisController
	property alias damagable: myDamagable

	property bool isMovingLeft
	property bool isMovingRight
	property bool isMovingUp
	property bool isMovingDown

	Component.onCompleted: {
		damagable.team = team
		bulletEmitter.team = team
	}

	Damagable {
		id: myDamagable
		maxHealth: 10
	}

	CircleCollider {
		id: collider
		radius: 16
		linearVelocity: Qt.point(axisController.xAxis, axisController.yAxis)
		categories: team.entityCategory
		collidesWith: team.entityCollisionCategories
		fixedRotation: true

		Image {
			anchors.centerIn: parent.anchors.center
			smooth: false
			source: Qt.resolvedUrl("../../assets/entities/player.png")
			width: 32
			height: 32
			mirror: collider.linearVelocity.x < 0
		}
	}

	TwoAxisController {
		id: axisController
		onInputActionPressed: (actionName) => {
			updateActionState(actionName, true);
			updateMovementAxis();
		}
		onInputActionReleased: (actionName) => {
			updateActionState(actionName, false);
			updateMovementAxis();
		}
		inputActionsToKeyCode: {
			"up": Qt.Key_W,
			"down": Qt.Key_S,
			"left": Qt.Key_A,
			"right": Qt.Key_D
		}
	}

	BulletEmitter {
		id: bulletEmitter
		bulletPrefab: Qt.resolvedUrl("Bullet.qml")
	}

	// Sets the corresponding boolean state of the action `actionName` to `value`
	function updateActionState(actionName, value) {
		if (actionName === "up") {
			isMovingUp = value
		}

		if (actionName === "down") {
			isMovingDown = value
		}

		if (actionName === "left") {
			isMovingLeft = value
		}

		if (actionName === "right") {
			isMovingRight = value
		}
	}

	function updateMovementAxis() {
		let dx = 0;
		let dy = 0;

		if (player.isMovingUp) {
			dy -= 1;
		}

		if (player.isMovingDown) {
			dy += 1;
		}

		if (player.isMovingLeft) {
			dx -= 1;
		}

		if (player.isMovingRight) {
			dx += 1;
		}

		if (dx === 0 && dy === 0) {
			axisController.xAxis = 0;
			axisController.yAxis = 0;
		} else {
			let deltaVectorLength = Math.sqrt(dx * dx + dy * dy);
			let deltaScale = 1 / deltaVectorLength * player.speed;

			axisController.xAxis = dx * deltaScale;
			axisController.yAxis = dy * deltaScale;
		}
	}

	function shoot() {
		let directionX = crosshair.x - player.x
		let directionY = crosshair.y - player.y

		let directionLength = Math.sqrt(directionX * directionX + directionY * directionY)
		if (directionLength <= 0.0001) {
			return;
		}

		directionX /= directionLength;
		directionY /= directionLength;

		let impulse = 150
		bulletEmitter.emit(player.x, player.y, directionX, directionY, impulse);
	}
}
