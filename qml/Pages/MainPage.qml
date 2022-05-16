/*
 * Copyright (C) 2022  walking-octopus
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * cathode-tube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


import QtQuick 2.9
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
//import Qt.labs.settings 1.0
import QtWebSockets 1.1

Page {
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
                websocket.sendTextMessage('{ "topic": "GetFeed" }');
            }
        }
        onTextMessageReceived: function(message) {
            print(message);
            let json = JSON.parse(message);
    
            switch (json.topic) {
                case "signIn": {
                    print("Hey! This is still WIP, so I didn't add the login page yet.");
                    print(`Please go to ${json.payload.url} and enter ${json.payload.code} to sign in.`);
                    break;
                }

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
}
