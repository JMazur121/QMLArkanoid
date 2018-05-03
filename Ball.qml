import QtQuick 2.10

Rectangle {
    property real centerX: x+radius
    property real centerY: y+radius
    id:ball
    radius: width/2
    gradient: Gradient {
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: 1.0; color: "red" }
        }
}
