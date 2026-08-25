import QtQuick
import Felgo

EntityBase {
    id: player

    entityId: "entity"
    entityType: "player"

    property int speed
    property alias controller: axisController

	TwoAxisController {
		id: axisController
        onInputActionPressed: (actionName) => {
            let dx = 0;
            let dy = 0;
            if (actionName === "up") {
                dy -= 1;
            }

            if (actionName === "down") {
                dy += 1;
            }

            if (actionName === "left") {
                dx -= 1;
            }

            if (actionName === "right") {
                dx += 1;
            }

            if (dx === 0 && dy === 0) {
                return;
            }

            let deltaVectorLength = Math.sqrt(dx * dx + dy * dy);
            let deltaScale = 1 / deltaVectorLength * player.speed;
            dx *= deltaScale;
            dy *= deltaScale;

            player.x += dx;
            player.y += dy;
        }
		inputActionsToKeyCode: {
            "up": Qt.Key_W,
            "down": Qt.Key_S,
            "left": Qt.Key_A,
            "right": Qt.Key_D
        }
	}

    Rectangle {
        width: 20
        height: 20
        color: "red"
    }
}
