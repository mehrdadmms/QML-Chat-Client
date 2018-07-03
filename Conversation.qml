import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Styles 1.4

Page {

    property var token
    property var username
    property var chats : []
    property var inConversationWith
    property int index: 0
    property var sendCommand
    property var getCommand
    property var sqlindex: 0

    id: root
    anchors.fill: parent
    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);
        try{
        db.transaction(
                    function(tx) {
                        tx.executeSql('INSERT INTO TableNames VALUES(?)', "" + getCommand + inConversationWith);
                    }
                )
        }catch(error){console.log(error)}
    }

    header:
        ToolBar {
                Label{
                    id :label
                    padding: 10
                    text: qsTr("" + inConversationWith)
                    font.pixelSize: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                Label{
                    id : error
                    padding: 10
                    text: qsTr("")
                    font.pixelSize: 17
                    anchors.left: label.right
                    anchors.leftMargin: 20
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

    Timer {
                id: thread
                interval: 2000; repeat: true
                running: true
                triggeredOnStart: true

                onTriggered: {
                    getMsg();
                    console.log("thread " + chats);
                    readStuff();
                }

    }

    ColumnLayout {
           anchors.fill: parent


        ListView {
                id: listView
               Layout.fillWidth: true
               Layout.fillHeight: true
               Layout.margins: pane.leftPadding + messageField.leftPadding
               displayMarginBeginning: 40
               displayMarginEnd: 40
               verticalLayoutDirection: ListView.BottomToTop
               spacing: 12
               model: chats
               delegate: Column {
                   readonly property bool sentByMe: modelData.src === username

                   anchors.right: sentByMe ? parent.right : undefined
                   spacing: 6
                   Label {
                       id: usernames
                       text: sentByMe ? "" : modelData.src
                       color: "grey"
                       anchors.right: sentByMe ? parent.right : undefined
                   }

                   Rectangle {
                       width: Math.min(messageText.implicitWidth + 24, listView.width)
                       height: messageText.implicitHeight + 24
                       color: sentByMe ? "lightgrey" : "steelblue"

                       Label {
                           id: messageText
                           anchors.centerIn: parent
                           text: modelData.body
                           color: sentByMe ? "black" : "white"
                       }
                   }
                   Label {
                       id: times
                       text:modelData.date.substring(11).slice(0, -3)
                       color: "grey"
                       anchors.right: sentByMe ? parent.right : undefined
                   }
               }

               ScrollBar.vertical: ScrollBar {}
           }
        Pane {
               id: pane
               Layout.fillWidth: true

               RowLayout {
                   width: parent.width

                   TextArea {
                       id: messageField
                       Layout.fillWidth: true
                       placeholderText: qsTr("Enter Message")
                       wrapMode: TextArea.Wrap
                   }

                   Button {
                       id: sendButton
                       text: qsTr("Send")
                       enabled: messageField.length > 0 && messageField.text !== "You Are Not Admin!"
                       onClicked: {
                           send();
                       }
                   }
               }
           }
    }

    function dropTable() {
        console.log(" drop ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);
        try{

        db.transaction(
                    function(tx) {
                        tx.executeSql('DROP TABLE IF EXISTS '+ getCommand + inConversationWith);

                    }
                )
        }catch(error){console.log(error)}

    }

    function saveStuff(stuff) {
        console.log(" save ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);


        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS '+ getCommand + inConversationWith +'(name TEXT)');
                        tx.executeSql('INSERT INTO '+ getCommand + inConversationWith +' VALUES(?)', stuff);

                    }
                )

    }

    function readStuff() {
        console.log(" read ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);


        db.transaction(
                    function(tx) {
                        var rs = tx.executeSql('SELECT * FROM '+ getCommand + inConversationWith);
                        if(sqlindex < rs.rows.length){
                            console.log("sth : " + sqlindex)

                                for (sqlindex; sqlindex < rs.rows.length; sqlindex++) {
                                    chats.unshift(JSON.parse(rs.rows.item(sqlindex).name))
                                    console.log("test : " + chats[sqlindex]);
                                }
//                                sqlindex = index;
                                listView.model = 0;
                                listView.model = chats;
                         }

                    }
                )

    }


    function getMsg() {
        console.log("get message ");
        var URL = 'http://api.softserver.org:1104/'+ getCommand +'?token=' + token + '&dst=' + inConversationWith;
        var request = new XMLHttpRequest();
        request.onreadystatechange = function(e) {
            console.log(JSON.stringify(request));
            if (request.readyState !== 4) {
                return;
            }

            if (request.status === 200) {
//                console.log('success', request.responseText);
                var response = JSON.parse(request.responseText);
                var message = response.message;
                var code = response.code;

                if(code === "200"){  //success
                    label.text = inConversationWith;
                    if(index == 0)
                        dropTable();
                    if(1 == message.replace("There Are -", "").replace("- Message", ""))
                        var chatIndex = 1;
                    else
                         chatIndex = message.replace("There Are -", "").replace("- Messages", "");
                    if(index < chatIndex){
                        for(var i = index ; i < chatIndex ; i++){
                            console.log(response["block " + i])
//                            chats.unshift(response["block " + i]);
                            saveStuff(JSON.stringify(response["block " + i]));
//                            console.log("chats")
//                            console.log(chats[i]);
                        }
                        index = chatIndex;
//                        listView.model = 0;
//                        listView.model = chats;
                    }

                }
                else { //error

                    console.log("error in loading chats");
                    error.color = "#c0392b"
                    error.text = message;
                }
            } else {
                label.text = "Error In Connecting server. \nCheck Your Connection Please.";
                console.warn('error in loading user');
                error.color = "#2980b9"
                error.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();


    }

    function send() {
        console.log("send ");
        var msg = messageField.text;
        var URL = 'http://api.softserver.org:1104/'+ sendCommand +'?token=' + token + '&dst=' + inConversationWith + '&body=' + msg;
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
                    messageField.text="";
                    messageField.placeholderText="Enter Message"
//                    txtError.color = "#27ae60"
//                    txtError.text = message;
                }
                else if (code === "404")
                {
                    messageField.text = "You Are Not Admin!"
                    messageField.enabled = false
                }

                else { //error
                    console.log("error");

//                    txtError.color = "#c0392b"
//                    txtError.text = message;
                }
            } else {
                console.warn('error in loading user');

//                txtError.color = "#c0392b"
//                txtError.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();


    }



}
