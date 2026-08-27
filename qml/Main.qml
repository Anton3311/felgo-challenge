import Felgo 4.0
import QtQuick 2.0
import "./scenes"

GameWindow {
    id: gameWindow
	activeScene: mainScene
    screenWidth: 960
    screenHeight: 640

	state: "main"
	states: [
		State {
			name: "main"
			PropertyChanges { target: gameWindow; activeScene: mainScene }
			PropertyChanges { target: gameSceneLoader; source: "" }
			PropertyChanges { target: mainScene; enabled: true }
			PropertyChanges { target: mainScene; opacity: 1 }
			StateChangeScript {
				script: {
				}
			}
		},
		State {
			name: "game"
			PropertyChanges { target: mainScene; enabled: false }
			PropertyChanges { target: mainScene; opacity: 0 }
			PropertyChanges { target: gameWindow; activeScene: gameSceneLoader.item }
			PropertyChanges { target: gameSceneLoader; source: "./scenes/GameScene.qml" }
			StateChangeScript {
				script: {

				}
			}
		}
	]

	FontLoader {
		id: pixelFont
		source: "../assets/fonts/Jersey10-Regular.ttf"
	}

	Loader {
		id: gameSceneLoader
		focus: true
		onLoaded: {
			gameSceneLoader.item.pixelFont = pixelFont.font
			gameSceneLoader.Keys.forwardTo = [gameSceneLoader.item]
			gameSceneLoader.item.onGameOver.connect((wavesCompleted, enemiesKilled) => {
				mainScene.displayRunStatistics(wavesCompleted, enemiesKilled);
				gameWindow.state = "main"
			})
		}
	}

	MainScene {
		id: mainScene
		pixelFont: pixelFont.font
	}
}
