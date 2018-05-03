import QtQuick 2.10

Rectangle{
    property int brickNumber
    property color innerColor

    width: parent.width/20
    height: (parent.height * 0.35)/9
    id:brick
    color: "black"
    objectName: "brick"
    Rectangle{
        id:innerRect
        width: parent.width*0.95
        height: parent.height*0.95
        anchors.centerIn: parent
        color: parent.innerColor
    }
}
