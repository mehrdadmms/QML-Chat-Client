import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Styles 1.4

Page {

    property var token

    id: root
    anchors.fill: parent

    header:
        ToolBar {
                Label{
                    padding: 10
                    text: qsTr("New Conversation")
                    font.pixelSize: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
                            id: btnBack
                            text: qsTr("Back")

                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                root.StackView.view.pop();
                            }
               }
            }

    Column {
        id: column
        anchors.fill: parent
        anchors.verticalCenterOffset: 0
        anchors.horizontalCenterOffset: 10
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        spacing: 10
        transformOrigin: Item.Center

        Text {
            anchors.topMargin: 15
            id: txtCreateLabel
            color: "#000000"
            text: qsTr("Start A New Conversation")
            anchors.top:column.top
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 22
        }

            TextArea  {
                width: 250
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 15
                anchors.top:txtCreateLabel.bottom
                id: txtInputUsername
                placeholderText:  qsTr("Username")
                wrapMode: TextArea.Wrap
                opacity: 1
                renderType: Text.QtRendering
                font.family: "Times New Roman"
                selectionColor: "#28b89e"
                font.capitalization: Font.MixedCase
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16

            }


            TextArea  {
                anchors.top:txtInputUsername.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 15
                width: 250
                id: txtInputmsg
                placeholderText:  qsTr("Message")
                wrapMode: TextArea.Wrap
                font.wordSpacing: -0.3
                font.weight: Font.Thin
                opacity: 1
                renderType: Text.QtRendering
                font.family: "Times New Roman"
                selectionColor: "#28b89e"
                font.capitalization: Font.MixedCase
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 17

            }



        Button {
            anchors.topMargin: 15
            id: btn
            anchors.top:txtInputmsg.bottom
            height: 42
            text: qsTr("START CONVERSATION!")
            focusPolicy: Qt.NoFocus
            font.pointSize: 11
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                send()
            }

        }

        Text {
            anchors.topMargin: 15
            anchors.top:btn.bottom
            id: txtError
            color: "#ff0000"
            text: qsTr("")
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
        }
    }



    function send() {
        console.log("new conversation ");
        var msg = txtInputmsg.text;
        var user = txtInputUsername.text;
        var URL = 'http://api.softserver.org:1104/sendmessageuser?token=' + token + '&dst=' + user + '&body=' + msg;
        var request = new XMLHttpRequest();
        request.onreadystatechange = function(e) {
            console.log(JSON.stringify(request));
            if (request.readyState !== 4) {
                return;
            }

            if (request.status === 200) {
                console.log('success', request.responseText);
                var response = JSON.parse(request.responseText);
                var message = response.message;
                var code = response.code;
                if(code === "200"){  //success
                    txtError.color = "#27ae60"
                    txtError.text = message;
                }
                else { //error
                    console.log("error");
                    txtError.color = "#c0392b"
                    txtError.text = message;
                }
            } else {
                console.warn('error in loading user');
                txtError.color = "#c0392b"
                txtError.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();


    }
}
