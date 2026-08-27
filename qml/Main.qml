import Felgo 4.0
import QtQuick 2.0
import "./scenes"

GameWindow {
    id: gameWindow
    activeScene: mainScene
    screenWidth: 960
    screenHeight: 640

	FontLoader {
		id: pixelFont
		source: "../assets/fonts/Jersey10-Regular.ttf"
	}

	GameScene {
		id: mainScene
		pixelFont: pixelFont.font
	}
}
