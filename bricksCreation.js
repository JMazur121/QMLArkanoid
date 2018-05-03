function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function initBricks(){
    var brickWidth = gameController.width/20;
    var brickHeight = (gameController.height * 0.35)/9;
    var currX = 0.0;
    var currY = gameController.height * 0.1;
    var component = Qt.createComponent("Brick.qml");
    var currentBricksNumber = 0;

    for (var row=0; row<9;++row) {
        var bricksInRow = getRandomInt(8,20);
        currentBricksNumber += bricksInRow;
        var spacing = (gameController.width - bricksInRow * brickWidth)/2;
        currX = spacing;
        var r = Math.random();
        var g = Math.random();
        var b = Math.random();

        if ((bricksInRow % 2 == 1) || (Math.random() > 0.5)) {
            for(var j=0; j<bricksInRow; ++j)
            {
                component.createObject(gameController,{"x":currX,
                                                       "y":currY,
                                                       "innerColor":Qt.rgba(r,g,b,1)});
                currX += brickWidth;
            }
        }
        else {
            currX = 0.0;
            var rightX = gameController.width - brickWidth;
            for(var k=0; k<(bricksInRow/2); ++k)
            {
                component.createObject(gameController,{"x":currX,
                                                       "y":currY,
                                                       "innerColor":Qt.rgba(r,g,b,1)});

                component.createObject(gameController,{"x":rightX,
                                                       "y":currY,
                                                       "innerColor":Qt.rgba(r,g,b,1)});

                currX += brickWidth;
                rightX -= brickWidth;
            }
        }
        currY += brickHeight;
    }
}

function clearBricks() {
    var children = gameController.data;
            for(var item = 0; item< children.length; ++item){
                if(children[item].objectName === "brick"){
                    children[item].destroy();
                }
            }
}
