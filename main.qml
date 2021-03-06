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
        property int chancesLeft
        property real xVelocity : 1.0
        property real yVelocity : 1.0
        property bool upMove
        property bool rightMove

        function isColliding(c_item){
            var deltaX = ball.centerX - Math.max(c_item.x,Math.min(ball.centerX,c_item.x+c_item.width))
            var deltay = ball.centerY - Math.max(c_item.y,Math.min(ball.centerY,c_item.y+c_item.height))
            return (deltaX * deltaX + deltay * deltay) < (ball.radius * ball.radius);
        }

        function bricksCollision(){
            var children = gameController.data;
            var deletedBricks = 0;
            var moveRight = rightMove;
            var moveUp = upMove;
            for (var item=0; item<children.length;++item){
                if(children[item].objectName === "brick")
                    if(isColliding(children[item])){
                        if(ball.centerX <= children[item].x){//hit from left
                            moveRight = !rightMove;
                        }
                        else if(ball.centerX >= (children[item].x + children[item].width)){//hit from right
                            moveRight = !rightMove;
                        }
                        else if(ball.centerY < children[item].y){//hit from above
                            moveUp = !upMove;
                        }
                        else {//hit from bottom
                            moveUp = !upMove;
                        }
                        ++deletedBricks;
                        children[item].destroy();
                    }
            }
            if(deletedBricks > 0) {
                ballDown.stop();
                ballUp.stop();
                ballLeft.stop();
                ballRight.stop();
                gameController.bricksLeft -= deletedBricks;
                if(gameController.bricksLeft == 0){
                    gameController.state = "Game_Won"
                    return;
                }

                if(moveRight){
                    gameController.rightMove = true;
                    ballRight.start();
                }
                else {
                    gameController.rightMove = false;
                    ballLeft.start();
                }
                if(moveUp){
                    gameController.upMove = true;
                    ballUp.start();
                }
                else {
                    gameController.upMove = false;
                    ballDown.start();
                }
            }
        }

        id:gameController
        width: gameWindow.width
        height: gameWindow.height
        color:"#426496"
        focus: true

        Ball{
            id:ball
            width: gameController.width/37
            height: width
            x:gameController.width/2 - width/2
            y:gameController.height - 3*height

            PropertyAnimation{
                id: ballDown
                target: ball
                property: "y"
                to: gameController.height - ball.height
                duration: (gameController.height - ball.height - ball.y) / gameController.yVelocity
                onStopped: {
                    if(gameController.state !== "Game_Paused" && (ball.y >= gameController.height - ball.height)){
                        --gameController.chancesLeft;
                        gameController.state = (gameController.chancesLeft > 0) ? "Game_Chance_Lost" : "Game_Lost"
                    }
                }
            }

            PropertyAnimation{
                id: ballUp
                target: ball
                property: "y"
                to: 0
                duration: ball.y / gameController.yVelocity
                onStopped: {
                    if (ball.y <= 0){
                        ballDown.start();
                        gameController.upMove = false
                    }
                }
            }

            PropertyAnimation{
                id: ballRight
                target: ball
                property: "x"
                to: gameController.width - ball.width
                duration: (gameController.width - ball.width - ball.x) / gameController.xVelocity
                onStopped: {
                    if (ball.x >= gameController.width - ball.width){
                        ballLeft.start();
                        gameController.rightMove = false
                    }
                }
            }

            PropertyAnimation{
                id: ballLeft
                target: ball
                property: "x"
                to: 0
                duration: ball.x / gameController.xVelocity
                onStopped: {
                    if (ball.x <= 0){
                        ballRight.start();
                        gameController.rightMove = true
                    }
                }
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

        Timer{
            id:timer
            interval: 20
            repeat: true
            onTriggered: {
                if(gameController.isColliding(paddle)) {
                    ballDown.stop()
                    gameController.upMove = true
                    ballUp.start()
                }
                else
                    gameController.bricksCollision();
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
                chancesLeft = 3
                gameController.state = "GameOngoing"
                var velocityComponent = Math.random()*0.3 + 0.2
                var secondComponent = Math.sqrt(0.65*0.65 - velocityComponent*velocityComponent)
                if (secondComponent > velocityComponent){
                    gameController.yVelocity = secondComponent
                    gameController.xVelocity = velocityComponent
                }
                else {
                    gameController.yVelocity = velocityComponent
                    gameController.xVelocity = secondComponent
                }
                gameController.rightMove = true
                gameController.upMove = true
                ballRight.start()
                ballUp.start()
            }
            else if(gameController.state === "Game_Chance_Lost") {
                gameController.state = "GameOngoing"
                ballUp.start()
                ballRight.start()
                gameController.rightMove = true
                gameController.upMove = true
            }
            else if(gameController.state === "Game_Lost" || gameController.state === "Game_Won"){
                Bricks.clearBricks();
                Bricks.initBricks();
                gameController.state = "GameInitialized"
            }
        }

        Keys.onEscapePressed: {
            if(gameController.state === "GameOngoing"){
                gameController.state = "Game_Paused"
            }
            else if(gameController.state === "Game_Paused"){
                gameController.state = "GameOngoing"
                upMove ? ballUp.start() : ballDown.start()
                rightMove ? ballRight.start() : ballLeft.start()
            }
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
                PropertyChanges {
                    target: ballUp;
                    running: false;
                }
                PropertyChanges {
                    target: ballDown;
                    running: false;
                }
                PropertyChanges {
                    target: ballLeft;
                    running: false;
                }
                PropertyChanges {
                    target: ballRight;
                    running: false;
                }
                PropertyChanges {
                    target: timer
                    running: false
                }
                PropertyChanges {
                    target: ball
                    x: gameController.width/2 - ball.width/2
                    y: gameController.height - 3*ball.height
                }
                PropertyChanges {
                    target: paddle
                    x : (gameController.width - paddle.width)/2
                    y : gameController.height - paddle.height
                }
            },
            State {
                name: "GameOngoing"
                PropertyChanges {
                    target: ballUp;
                    running: false;
                }
                PropertyChanges {
                    target: ballDown;
                    running: false;
                }
                PropertyChanges {
                    target: ballLeft;
                    running: false;
                }
                PropertyChanges {
                    target: ballRight;
                    running: false;
                }
                PropertyChanges {
                    target: timer
                    running: true
                }
            },
            State {
                name: "Game_Paused"
                PropertyChanges {
                    target: movingLeft;
                    running: false;
                }
                PropertyChanges {
                    target: movingRight;
                    running: false;
                }
                PropertyChanges {
                    target: ballUp;
                    running: false;
                }
                PropertyChanges {
                    target: ballDown;
                    running: false;
                }
                PropertyChanges {
                    target: ballLeft;
                    running: false;
                }
                PropertyChanges {
                    target: ballRight;
                    running: false;
                }
                PropertyChanges {
                    target: timer
                    running: false
                }
            },
            State {
                name: "Game_Chance_Lost"
                PropertyChanges {
                    target: ballUp;
                    running: false;
                }
                PropertyChanges {
                    target: ballDown;
                    running: false;
                }
                PropertyChanges {
                    target: ballLeft;
                    running: false;
                }
                PropertyChanges {
                    target: ballRight;
                    running: false;
                }
                PropertyChanges {
                    target: timer
                    running: false
                }
                PropertyChanges {
                    target: ball
                    x: gameController.width/2 - ball.width/2
                    y: gameController.height - 3*ball.height
                }
                PropertyChanges {
                    target: paddle
                    x : (gameController.width - paddle.width)/2
                    y : gameController.height - paddle.height
                }
            },
            State {
                name: "Game_Won"
                PropertyChanges {
                    target: ballUp;
                    running: false;
                }
                PropertyChanges {
                    target: ballDown;
                    running: false;
                }
                PropertyChanges {
                    target: ballLeft;
                    running: false;
                }
                PropertyChanges {
                    target: ballRight;
                    running: false;
                }
                PropertyChanges {
                    target: timer
                    running: false
                }
            },
            State {
                name: "Game_Lost"
                PropertyChanges {
                    target: ballUp;
                    running: false;
                }
                PropertyChanges {
                    target: ballDown;
                    running: false;
                }
                PropertyChanges {
                    target: ballLeft;
                    running: false;
                }
                PropertyChanges {
                    target: ballRight;
                    running: false;
                }
                PropertyChanges {
                    target: timer
                    running: false
                }
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
