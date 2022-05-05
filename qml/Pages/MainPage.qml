import QtQuick 2.9
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtWebSockets 1.1

Page {
    //anchors.fill: parent

    header: PageHeader {
        id: header
        flickable: scrollView.flickableItem
        title: i18n.tr('Cathode')

        trailingActionBar {
            actions: [
                Action {
                    iconName: "reload"
                    text: "Refresh"
                    onTriggered: websocket.sendTextMessage('{ "topic": "GetFeed" }')
                }
            ]
        }
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            if (status == WebSocket.Open) {
                console.log("Open");
                websocket.sendTextMessage('{ "topic": "GetFeed" }');
            }
        }
        onTextMessageReceived: function(message) {
            print(message);
            let json = JSON.parse(message);
    
            switch (json.topic) {
                case "updateStatus": {
                    print(json.payload);
                    break;
                }
                
                case "updateFeed": {
                    videoModel.clear();
                    for (let video of json.payload.videos) {
                        videoModel.append({
                            "videoTitle": video.title,
                            "channel": video.channel
                        });
                    }
                    break;
                }
            }
        }
    }

    ListModel {
        id: videoModel
    }


    ScrollView {
        id: scrollView
        anchors.fill: parent

        ListView {
            id: view
            anchors.fill: parent

            model: videoModel
            delegate: ListItem {
                ListItemLayout {
                    anchors.centerIn: parent
                    
                    title.text: videoTitle
                    subtitle.text: channel.name
                }
            }
        }
    }

    /* Button {
        Layout.alignment: Qt.AlignHCenter
        text: i18n.tr('Fetch feed!')
        onClicked: websocket.sendTextMessage(`{ "topic": "GetFeed"}`)
    } */
}
