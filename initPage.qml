import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.0

Page{
    id : root
    anchors.fill: parent
    SwipeView {
        id: swipeView
        anchors.fill: parent

        currentIndex: tabBar.currentIndex


        Signup{

        }
        //LOGIN PAGE
        Page {
            id: page
            width: 600
            height: 400

            header: Label {
                text: qsTr("Log In")
                font.pixelSize: Qt.application.font.pixelSize * 2
                padding: 10
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

                TextArea  {
                    id: txtInputUsername
                    width: 250
                    placeholderText:  qsTr("Username")
                    opacity: 1
                    renderType: Text.QtRendering
                    font.family: "Times New Roman"
                    selectionColor: "#28b89e"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.capitalization: Font.MixedCase
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    wrapMode: TextArea.Wrap
                }

                TextArea  {
                    id: txtInputPassword
                    width: 250
                    placeholderText:  qsTr("Password")
                    font.wordSpacing: -0.1
                    font.capitalization: Font.MixedCase
                    cursorVisible: false
                    selectionColor: "#28b89e"
                    font.family: "Times New Roman"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 16
                    wrapMode: TextArea.Wrap
                }

                Button {
                    id: btnSignUp
                    width: 96
                    height: 42
                    text: qsTr("LOG IN!")
                    focusPolicy: Qt.NoFocus
                    font.pointSize: 11
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        if(txtInputUsername.text === ""){
                            txtError.color = "#c0392b"
                            txtError.text = "Username Can Not Be Empty."
                        }else if (txtInputPassword.text === ""){
                            txtError.color = "#c0392b"
                            txtError.text = "Password Can Not Be Empty."
                        }
                        else
                            fetch()

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
            }
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            text: qsTr("Sign Up")
        }
        TabButton {
            text: qsTr("Logn In")
        }
    }
    function save (token) {
        console.log("in save ")
        var username = txtInputUsername.text;
        var password = txtInputPassword.text;
        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);

        db.transaction(
            function(tx) {

                // if database got locked delete from here
                tx.executeSql('DROP TABLE IF EXISTS Storage')
                tx.executeSql('DROP TABLE IF EXISTS Token')

                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS Storage(salutation TEXT, salutee TEXT)');
                tx.executeSql('CREATE TABLE IF NOT EXISTS Token(salutation TEXT, salutee TEXT)');

                // Add row
                tx.executeSql('INSERT INTO Storage VALUES(?, ?)', [ username, password ]);
                tx.executeSql('INSERT INTO Token VALUES(?, ?)', ["token", token]);

            }
        )

    }

    function fetch() {
        console.log("fetch works");
        txtError.color = "#2980b9"
        txtError.text = "Connecting...";
        var username = txtInputUsername.text;
        var password = txtInputPassword.text;
        var URL = 'http://api.softserver.org:1104/login?username=' + username + '&password=' + password;
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
                    var token = response.token;
                    save(token);
                    root.StackView.view.replace("qrc:/menu.qml")
                }
                else { //error
                    txtError.color = "#c0392b"
                    txtError.text = message;
                }
            } else {
                console.warn('error');
                txtError.color = "#c0392b"
                txtError.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();
    }

}
