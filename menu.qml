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
                    text: qsTr("Menu")
                    font.pixelSize: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
                            text: qsTr("Logout and Exit")
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                readAndLogOut();
                            }
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
                model: ["Users", "Groups", "Channels", "Create Group Or Join One", "Create Channel Or Join One"]
                delegate: ItemDelegate {
                    text: modelData
                    width: listView.width - listView.leftMargin - listView.rightMargin
                    height: avatar.implicitHeight
                    leftPadding: avatar.implicitWidth + 32
                    Image {
                            id: avatar
//                            source: "qrc:/Create_Group_Or_Join_One.png"
//                            source: "qrc:/" + modelData.replace(" ", "_") + ".png"
                            source: "qrc:/" + modelData.split(' ').join('_') + ".png"
                    }
                    onClicked:{
                        var username = getusername();
                        var token = getToken();
                        if(modelData === "Groups")
                            getGroupList(token, username);
                        else if(modelData === "Channels")
                            getChannelList(token, username);
                        else if(modelData === "Users")
//                            getUsersList(token);
                            root.StackView.view.push("qrc:/Users.qml",{token:token})
                        else
                            root.StackView.view.push("qrc:/" + modelData.split(' ').join('') + ".qml")
                    }
                }
            }

    function getToken() {
        console.log(" get token ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);
        var token ;

        db.transaction(
                    function(tx) {
                        // Show all
                        var rs = tx.executeSql('SELECT * FROM Token');

                        token = rs.rows.item(0).salutee;

                    }
                )
        return token;
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

    //--------------------------------------

    function getChannelList(token, username) {
        console.log("fetch works join channel ");
//        var channelName = [];
        var URL = 'http://api.softserver.org:1104/getchannellist?token=' + token;
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
                    dropTable("Channels")
                    if(1 == message.replace("You Are in -", "").replace("- Channel", ""))
                        var channelIndex = 1;
                    else
                         channelIndex = message.replace("You Are in -", "").replace("- Channels", "");
                    for(var i = 0 ; i < channelIndex ; i++){
                        console.log(response["block " + i].channel_name)
                        var channel = response["block " + i].channel_name
                        saveStuff("Channels", JSON.stringify(channel))
//                        channelName.push(channel);
//                        console.log("in channelName : " + channelName[i]);
                    }
                    root.StackView.view.push("qrc:/Channels.qml",{token:token, username:username})
                }
                else { //error
                    console.log("error");
//                    txtJoinError.color = "#c0392b"
//                    txtJoinError.text = message;
                }
            } else {
                console.warn('error in loading channel');
                root.StackView.view.push("qrc:/Channels.qml",{token:token, username:username})
//                txtJoinError.color = "#c0392b"
//                txtJoinError.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();


    }

    function getGroupList(token ,username) {
        console.log("fetch works group ");
        var URL = 'http://api.softserver.org:1104/getgrouplist?token=' + token;
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
                    if(1 == message.replace("You Are in -", "").replace("- Group", ""))
                        var groupIndex = 1;
                    else
                        groupIndex = message.replace("You Are in -", "").replace("- Groups", "");
                    dropTable("Groups")
                    for(var i = 0 ; i < groupIndex ; i++){
                        console.log(response["block " + i].group_name)
                        var group = response["block " + i].group_name
                        saveStuff("Groups", JSON.stringify(group))
//                        groupName.push(group);
//                        console.log("in array : " + groupName[i]);
                    }
                    root.StackView.view.push("qrc:/Groups.qml",{token : token, username:username})
                }
                else { //error
                    console.log("error");
//                    txtJoinError.color = "#c0392b"
//                    txtJoinError.text = message;
                }
            } else {
                console.warn('error in laoding groups');
                root.StackView.view.push("qrc:/Groups.qml",{token : token, username:username})
//                txtJoinError.color = "#c0392b"
//                txtJoinError.text = "Error In Connecting server. \nCheck Your Connection Please.";
            }
        };

        request.open('GET', URL);
        request.send();


    }

    //--------------------------------------

    function readAndLogOut () {
        console.log("in logout ")

        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);
        var user;
        var pass
        try{
        db.transaction(
                    function(tx) {
                        // Show all
                        var rs = tx.executeSql('SELECT * FROM Storage');

                         user = rs.rows.item(0).salutation;
                         pass = rs.rows.item(0).salutee;

                        tx.executeSql('DROP TABLE IF EXISTS Storage');
                        tx.executeSql('DROP TABLE IF EXISTS Token');

                        rs = tx.executeSql('SELECT * FROM TableNames');

                        for (var i = 0; i < rs.rows.length; i++) {
                            console.log(rs.rows.item(i).name);
                            dropTable(rs.rows.item(i).name)
                        }
                        tx.executeSql('DROP TABLE IF EXISTS TableNames');
                        fetch(user, pass, tx);
                    }
                )
        }catch(error){
            console.log(error)
            fetch(user, pass, null);
        }
    }

    function fetch(username, password, tx) {
        console.log("logOut")
        var URL = 'http://api.softserver.org:1104/logout?username=' + username + '&password=' + password;
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

                    Qt.quit();

                }
                else { //error
                    console.log("could not quit");
                }
            } else {
                console.warn('error');
            }
        };

        request.open('GET', URL);
        request.send();
    }

}
