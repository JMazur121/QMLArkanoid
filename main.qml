import QtQuick 2.10
import QtQuick.Window 2.10

import "bricksCreation.js" as Bricks

Window {
    property int lastWidth: 800
    property int lastHeight: 600

    id:gameWindow
    visible: true
    width: 800
    height: 600
    title: qsTr("Arkanoid")

    Rectangle{
        property int bricksLeft: 0

        function initBall(){
            ball.x = gameController.width/2 - width/2
            ball.y = gameController.height/2 - height/2
        }

        function initPaddle(){
            paddle.x = (gameController.width - paddle.width)/2
            paddle.y = gameController.height - paddle.height
        }

        id:gameController
        width: gameWindow.width
        height: gameWindow.height
        color:"#426496"
        focus: true

        Ball{
            id:ball
            width: gameController.width/40
            height: width
            x:gameController.width/2 - width/2
            y:gameController.height/2 - height/2
        }

        Rectangle{
            property real paddleSpeed: gameController.width/1000 //1000 ms

            id:paddle
            border.width: 1
            width: gameController.width * 0.2
            height: gameController.height * 0.03
            color: "lightgray"
            x: (gameController.width - paddle.width)/2
            y: gameController.height - paddle.height

            PropertyAnimation{
                id: movingLeft;
                target: paddle;
                property: "x";
                to : 0;
                duration: paddle.x / paddle.paddleSpeed
            }

            PropertyAnimation{
                id: movingRight;
                target: paddle;
                property: "x";
                to : gameController.width - paddle.width;
                duration: (gameController.width - paddle.width - paddle.x) / paddle.paddleSpeed
            }
        }

        Keys.onLeftPressed: movingLeft.start()
        Keys.onRightPressed: movingRight.start()
        Keys.onSpacePressed: {
            Bricks.initBricks()
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Left) {
                movingLeft.stop()
                event.accepted = true
                return
            }
            else if (event.key === Qt.Key_Right) {
                movingRight.stop()
                event.accepted = true
                return
            }
        }
        states: [
            State {
                name: "GameInitialized"
            },
            State {
                name: "GameOngoing"
            },
            State {
                name: "Game_Paused"
            },
            State {
                name: "Game_Chance_Lost"
            },
            State {
                name: "Game_Won"
            },
            State {
                name: "Game_Lost"
            }
        ]
        state: "GameInitialized"
    }

    onWidthChanged: {
        var ratio = gameController.width / lastWidth
        lastWidth = gameController.width
        var children = gameController.data
        for(var item = 0; item< children.length; ++item){
                    if(children[item].objectName === "brick")
                        children[item].x = children[item].x * ratio
                }
    }

    onHeightChanged: {
        var ratio = gameController.height / lastHeight
        lastHeight = gameController.height
        var children = gameController.data
        for(var item = 0; item< children.length; ++item){
                    if(children[item].objectName === "brick")
                        children[item].y = children[item].y * ratio
                }
    }
}
