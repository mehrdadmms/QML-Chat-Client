import QtQuick 2.0
import QtQuick.Controls 2.2
Item {
    id: item1
    Text {
        id: text1
        text: qsTr("WELCOME TO IUT CHAT")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 48
    }

}
