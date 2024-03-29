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
import QtWebSockets 1.1
// import "../Components"

Page {
    id: notificationPage

    header: PageHeader {
        id: header
        title: i18n.tr("Notifications")
        flickable: scrollView.flickableItem

        leadingActionBar.actions: Action {
            iconName: "back"
            text: i18n.tr("Back")
            onTriggered: pStack.removePages(notificationPage)
            visible: !primaryPage.visible
        }
    }

    ListModel {
        id: notificationModel
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            if (status == WebSocket.Open) {
                websocket.sendTextMessage('{ "topic": "GetNotifications" }');
            }
        }

        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);

            switch (json.topic) {
                case "notificationsEvent": {
                    // Replace `title` with `short_text` because of QML weird
                    json.payload.items = json.payload.items.map(function(obj) {
                        obj['short_text'] = obj['title']; // Assign new key
                        delete obj['title']; // Delete old key
                        return obj;
                    });

                    for (const item of json.payload.items) {
                        notificationModel.append(item);
                    }

                    break;
                }
            }
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
    
        ListView {
            id: view
            anchors.fill: parent

            model: notificationModel
            delegate: ListItem {
                height: modelLayout.height + (divider.visible ? divider.height : 0)
                onClicked: {
                    if (!!video_url && video_url != "N/A")
                        Qt.openUrlExternally(video_url)
                }

                ListItemLayout {
                    id: modelLayout
                    anchors.centerIn: parent

                    title.text: short_text
                    title.maximumLineCount: 2
                    title.wrapMode: Text.WordWrap

                    subtitle.text: sent_time

                    Rectangle {
                        width: units.gu(0.8); height: width;
                        radius: width*0.5
                        color: theme.palette.normal.focus
                        SlotsLayout.position: SlotsLayout.Leading
                        visible: !read
                    }

                    Image {
                        id: image
                        source: !!video_thumbnail ? video_thumbnail.url : ""
                        visible: !!video_thumbnail
        
                        width: units.gu(16/1.1); height: units.gu(9/1.1)
                        
                        sourceSize.width: 336; sourceSize.height: 188
                        fillMode: Image.PreserveAspectCrop
                        // The image has a weird aspect ratio, so it need to be cropped.
                
                        SlotsLayout.position: SlotsLayout.Trailing
        
                        opacity: 0
                        states: State {
                            name: "loaded"; when: image.status == Image.Ready
                            PropertyChanges { target: image; opacity: 1}
                        }
                        transitions: Transition {
                            SpringAnimation {
                                easing.type: Easing.InSine
                                spring: 5
                                epsilon: 0.3
                                damping: 0.7
                                properties: "opacity"
                            }
                        }
                    }
                }
            }

            // TODO: Add notification continuations
        }

    }
}