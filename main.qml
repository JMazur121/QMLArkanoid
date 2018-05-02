import QtQuick 2.10
import QtQuick.Window 2.10

Window {
    id:gameWindow
    visible: true
    width: 800
    height: 600
    title: qsTr("Arkanoid")

    Rectangle{
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
    }
}
