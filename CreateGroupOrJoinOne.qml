import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.LocalStorage 2.0

Page {
    id: root
    anchors.fill: parent

    header: ToolBar {
                Label{
                    padding: 10
                    text: qsTr("Create Group Or Join One")
                    font.pixelSize: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
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
        width: 200
        height: 400
        anchors.verticalCenterOffset: 0
        anchors.horizontalCenterOffset: 10
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        spacing: 10
        transformOrigin: Item.Center

        Text {
            id: txtCreateLabel
            color: "#000000"
            text: qsTr("Create A Group")
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 22
        }

        TextArea  {
            id: txtInputName
            width: 250
            placeholderText:  qsTr("Name")
            opacity: 1
            renderType: Text.QtRendering
            font.family: "Times New Roman"
            selectionColor: "#2980b9"
            anchors.horizontalCenter: parent.horizontalCenter
            font.capitalization: Font.MixedCase
            horizontalAlignment: Text.AlignHCenter
            wrapMode: TextArea.Wrap
            font.pixelSize: 16

        }

        TextArea  {
            id: txtInputTitle
            width: 250
            placeholderText:  qsTr("Title")
            font.wordSpacing: -0.1
            font.capitalization: Font.MixedCase
            cursorVisible: false
            wrapMode: TextArea.Wrap
            selectionColor: "#0671be"
            font.family: "Times New Roman"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
        }

        Button {
            id: btnCreate

            height: 42
            text: qsTr("CREATE GROUP!")
            focusPolicy: Qt.NoFocus
            font.pointSize: 11
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                create();
            }

        }

        Text {
            id: txtError
            color: "#ff0000"
            text: qsTr("")
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
        }

        Text {
            id: txtJoinLabel
            color: "#000000"
            text: qsTr("Join A GROUP")
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 22
        }

        TextArea  {
            id: txtJoinInputName
            width: 250
            placeholderText:  qsTr("Name")
            font.wordSpacing: -0.1
            font.capitalization: Font.MixedCase
            cursorVisible: false
            selectionColor: "#0671be"
            font.family: "Times New Roman"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: TextArea.Wrap
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
        }

        Button {
            id: btnJoin

            height: 42
            text: qsTr("JOIN GROUP!")
            focusPolicy: Qt.NoFocus
            font.pointSize: 11
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                join();
            }

        }

        Text {
            id: txtJoinError
            color: "#ff0000"
            text: qsTr("")
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
        }


    }

    function join() {
        console.log("in create group ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);

        db.transaction(
                    function(tx) {
                        // Show all
                        var rs = tx.executeSql('SELECT * FROM Token');

                        var token = rs.rows.item(0).salutee;
                        joinFetch(token);
                    }
                )
    }

    function joinFetch(token) {
        console.log("fetch works join group ");
        var name = txtJoinInputName.text;
        var URL = 'http://api.softserver.org:1104/joingroup?token=' + token + '&group_name=' + name;
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
                    txtJoinError.color = "#27ae60"
                    var loginMessage = '' + message;
                    if(message === "You are already Joined!")
                        txtJoinError.color = "#c0392b"
                    txtJoinError.text = loginMessage;
                }
                else { //error
                    txtJoinError.color = "#c0392b"
                    txtJoinError.text = message;
                }
            } else {
                console.warn('error in creating group');
                txtJoinError.color = "#c0392b"
                txtJoinError.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();

    }

    function create() {
        console.log("in create group ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);

        db.transaction(
                    function(tx) {
                        // Show all
                        var rs = tx.executeSql('SELECT * FROM Token');

                        var token = rs.rows.item(0).salutee;
                        createFetch(token);
                    }
                )
    }

    function createFetch(token) {
        console.log("fetch works create group ");
        var name = txtInputName.text;
        var title = txtInputTitle.text;
        var URL = 'http://api.softserver.org:1104/creategroup?token=' + token + '&group_name=' + name + '&group_title=' + title;
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
                   var loginMessage = '' + message;
                   txtError.text = loginMessage;
                }
                else { //error
                    txtError.color = "#c0392b"
                    txtError.text = message;
                }
            } else {
                console.warn('error in creating group');
                txtError.color = "#c0392b"
                txtError.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();
    }
}
