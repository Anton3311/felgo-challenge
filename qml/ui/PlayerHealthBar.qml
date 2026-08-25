import QtQuick
import Felgo

import "../entities/components"

Item {
	id: self

	property Damagable damagable
	property url fullHeartImage
	property url emptyHeartImage

	x: 0
	y: 0
	height: 16
	width: parent.width

	Row {
		width: parent.width
		height: parent.height
		Repeater {
			model: damagable.health
			Image {
				source: self.fullHeartImage
				fillMode: Image.PreserveAspectCrop
				width: 16
				height: 16
				smooth: false
			}
		}
		Repeater {
			model: damagable.maxHealth - damagable.health
			Image {
				source: self.emptyHeartImage
				fillMode: Image.PreserveAspectCrop
				width: 16
				height: 16
				smooth: false
			}
		}
	}
}
