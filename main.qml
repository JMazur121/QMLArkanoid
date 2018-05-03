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
        property int bricksLeft
        property int chancesLeft : 3
        property real xVelocity : 1.0
        property real yVelocity : 1.0

        function initBall(){
            ball.x = gameController.width/2 - width/2
            ball.y = gameController.height - 3*height
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
            y:gameController.height - 3*height

            PropertyAnimation{
                id: ballDown
                target: ball
                property: "y"
                to: gameController.height - ball.height
                duration: (gameController.height - ball.height - ball.y) / gameController.yVelocity
                onStopped: ballUp.start()
            }

            PropertyAnimation{
                id: ballUp
                target: ball
                property: "y"
                to: 0
                duration: ball.y / gameController.yVelocity
                onStopped: ballDown.start()
            }

            PropertyAnimation{
                id: ballRight
                target: ball
                property: "x"
                to: gameController.width - ball.width
                duration: (gameController.width - ball.width - ball.x) / gameController.xVelocity
                onStopped: ballLeft.start()
            }

            PropertyAnimation{
                id: ballLeft
                target: ball
                property: "x"
                to: 0
                duration: ball.x / gameController.xVelocity
                onStopped: ballRight.start()
            }
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

        Keys.onLeftPressed: {
            if(gameController.state === "GameOngoing")
                movingLeft.start()
        }
        Keys.onRightPressed: {
            if(gameController.state === "GameOngoing")
                movingRight.start()
        }
        Keys.onSpacePressed: {
            if(gameController.state === "GameInitialized"){
                gameController.state = "GameOngoing"
                var velocityComponent = Math.random()*0.3 + 0.2
                var secondComponent = Math.sqrt(0.7*0.7 - velocityComponent*velocityComponent)
                if (secondComponent > velocityComponent){
                    gameController.yVelocity = secondComponent
                    gameController.xVelocity = velocityComponent
                }
                else {
                    gameController.yVelocity = velocityComponent
                    gameController.xVelocity = secondComponent
                }
                console.log("xVel: "+xVelocity+" yVel: "+yVelocity)
                ballRight.running = true
                ballUp.running = true
            }
        }

        Keys.onEscapePressed: {
            if(gameController.state === "GameOngoing")
                gameController.state = "Game_Paused"
            else if(gameController.state === "Game_Paused")
                gameController.state = "GameOngoing"
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Left) {
                movingLeft.stop()
                event.accepted = true
            }
            else if (event.key === Qt.Key_Right) {
                movingRight.stop()
                event.accepted = true
            }
        }
        states: [
            State {
                name: "GameInitialized"
            },
            State {
                name: "GameOngoing"
                PropertyChanges {
                    target: movingLeft;
                    paused: false
                }
                PropertyChanges {
                    target: movingRight;
                    paused: false
                }
            },
            State {
                name: "Game_Paused"
                PropertyChanges {
                    target: movingLeft;
                    paused: true;
                }
                PropertyChanges {
                    target: movingRight;
                    paused: true;
                }
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

        Component.onCompleted: {
            Bricks.initBricks();
            gameController.state = "GameInitialized"
        }
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
