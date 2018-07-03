import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.LocalStorage 2.0


ApplicationWindow {
    id : root
    visible: true
    width: 640
    height: 480
    title: qsTr("Messenger")

    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "asyncStorage", 1000000);
        var token = false;
        try{
        db.transaction(
                    function(tx) {

                        tx.executeSql('CREATE TABLE IF NOT EXISTS TableNames(name TEXT UNIQUE)');

//                        tx.executeSql('DROP TABLE IF EXISTS TableNames');

                        try{

                            tx.executeSql('INSERT INTO TableNames VALUES(?)', "Groups");
                            tx.executeSql('INSERT INTO TableNames VALUES(?)', "Users");
                            tx.executeSql('INSERT INTO TableNames VALUES(?)', "Channels");

                        }catch(error){console.log(error)}
                        // Show all
                        var rs = tx.executeSql('SELECT * FROM Token');

                        token = rs.rows.item(0).salutee;
                        if(token)
                            stack.replace("qrc:/menu.qml")

                    }
                )
        }catch(error){
            console.log(error)
            console.log(error === "no such table")
            stack.replace("qrc:/InitPage.qml")
        }
    }


    StackView {
            id: stack
            anchors.fill: parent
            initialItem: /*InitPage{}*/ Welcome{}
    }

}


