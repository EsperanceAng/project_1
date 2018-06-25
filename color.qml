import QtQuick 2.0


Item {
    Rectangle {
        anchors.fill: parent
        color: "green"

        Text {
            text: "Fragment 1"
            color: "white"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 50
            font.pixelSize: 30

            renderType: Text.NativeRendering
        }

    }
}
