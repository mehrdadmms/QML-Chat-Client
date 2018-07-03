import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.LocalStorage 2.0

Page {
    property var users:[]
    property var index:0
    property var token
    property var sqlindex : 0

    id: root
    anchors.fill: parent

    header:
        ToolBar {
                Label{
                    id : label
                    padding: 10
                    text: qsTr("Users")
                    font.pixelSize: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
//                Label{
//                    id : error
//                    padding: 10
//                    text: qsTr("asdd")
//                    font.pixelSize: 17
//                    anchors.left: label.right
//                    anchors.leftMargin: 20
//                    anchors.verticalCenter: parent.verticalCenter
//                    horizontalAlignment: Text.AlignHCenter
//                    verticalAlignment: Text.AlignVCenter
//                }
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

                Image {

                   id: plus
                   anchors.rightMargin: 20
                   anchors.right: btnBack.left
                   source: "qrc:/plus.png"
                   MouseArea {
                       anchors.fill: parent
                       onClicked: {
                           root.StackView.view.push("qrc:/NewConversation.qml", {token : token});
                       }
                   }
                }

            }


    Timer {
                id: thread
                interval: 3000; repeat: true
                running: true
                triggeredOnStart: true

                onTriggered: {
                    update();
//                    console.log("thread " + users);
                    readStuff()

                }

    }
    ListView {

       id: listView
       anchors.fill: parent
       topMargin: 48
       leftMargin: 48
       bottomMargin: 48
       rightMargin: 48
       spacing: 20
       model: users
       delegate: ItemDelegate {
          text: modelData
          width: listView.width - listView.leftMargin - listView.rightMargin
          height: avatar.implicitHeight
          leftPadding: avatar.implicitWidth + 32

          Image {

             id: avatar
             source: "qrc:/Users.png"
          }
          onClicked: {
              var user = getusername()
                root.StackView.view.push("qrc:/Conversation.qml", {
                                             token : token,
                                             inConversationWith:modelData ,
                                             username:user,
                                             sendCommand:"sendmessageuser",
                                             getCommand:"getuserchats"}
                                        );
          }
       }
    }

    function getusername() {
        console.log(" get username ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);
        var username ;
        db.transaction(
                    function(tx) {
                        // Show all
                        var rs = tx.executeSql('SELECT * FROM Storage');

                        username = rs.rows.item(0).salutation;

                    }
                )
        return username;
    }

    function dropTable(table) {
        console.log(" drop ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);
        try{

        db.transaction(
                    function(tx) {
                        tx.executeSql('DROP TABLE IF EXISTS '+table);

                    }
                )
        }catch(error){console.log(error)}

    }

    function saveStuff(table, stuff) {
        console.log(" save ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);


        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS '+ table +'(name TEXT)');
                        tx.executeSql('INSERT INTO '+ table +' VALUES(?)', stuff);

                    }
                )

    }

    function readStuff() {
        console.log(" read ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);


        db.transaction(
                    function(tx) {
                        var rs = tx.executeSql('SELECT * FROM Users');
                        if(sqlindex < rs.rows.length){
                            console.log("sth : " + sqlindex)

                                for (sqlindex; sqlindex < rs.rows.length; sqlindex++) {
                                users.push(JSON.parse(rs.rows.item(sqlindex).name))
                                console.log("test : " + users[sqlindex]);
                                }
//                                sqlindex = index;
                                listView.model = 0;
                                listView.model = users;
                         }

                    }
                )

    }

    function update() {
        console.log("update ");
        var URL = 'http://api.softserver.org:1104/getuserlist?token=' + token;
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
                    if(index == 0)
                        dropTable("Users");
                    if(1 == message.replace("You Have Chat With -", "").replace("- User", ""))
                        var userIndex = 1;
                    else
                         userIndex = message.replace("You Have Chat With -", "").replace("- Users", "");
                    if(index < userIndex){
                        for(var i = index ; i < userIndex ; i++){
                            console.log(response["block " + i].src)
                            saveStuff("Users", JSON.stringify(response["block " + i].src))
//                            users.push(response["block " + i].src);
//                            console.log("in username : " + users[i]);
                        }
                        index = userIndex;
                    }

                }
                else { //error
                    console.log("error");
//                    error.color = "#c0392b"
//                    error.text = message;
                }
            } else {
                console.warn('error in loading user');
//                error.color = "#2980b9"
//                error.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();


    }
}
