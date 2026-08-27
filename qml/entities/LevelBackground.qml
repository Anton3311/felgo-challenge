import QtQuick
import Felgo

Item {
	property int levelSize
	property int wallThickness

	property alias levelWalls: walls

	// Fill the whole screen with a solid color matching the borders of the background sprite
	Rectangle {
		anchors.fill: parent
		color: "#763b36"
	}

	EntityBase {
		// Display the level background below everything
		id: walls
		width: levelSize
		height: levelSize
		anchors.centerIn: parent

		// Left
		BoxCollider {
			width: parent.width; height: wallThickness
			bodyType: Body.Static
			categories: wallCategory
		}

		// Down
		BoxCollider {
			y: levelSize - wallThickness
			width: parent.width; height: wallThickness
			bodyType: Body.Static
			categories: wallCategory
		}

		// Left
		BoxCollider {
			width: wallThickness; height: levelSize 
			bodyType: Body.Static
			categories: wallCategory
		}

		// Right
		BoxCollider {
			x: levelSize - wallThickness
			width: wallThickness; height: levelSize
			bodyType: Body.Static
			categories: wallCategory
		}

		Image {
			smooth: false
			width: levelSize
			height: levelSize
			source: Qt.resolvedUrl("../../assets/entities/levelBackground.png")
		}
	}
}
