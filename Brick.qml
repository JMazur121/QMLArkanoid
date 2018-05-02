import QtQuick 2.10

Rectangle{
    property int brickNumber
    property color innerColor
    id:brick
    color: "black"
    Rectangle{
        id:innerRect
        width: parent.width*0.95
        height: parent.height*0.95
        anchors.centerIn: parent
        color: parent.innerColor
    }
}
