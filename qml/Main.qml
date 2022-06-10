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


import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import QtWebSockets 1.1
import "./Pages"
import "./Components"

MainView {
    id: root
    objectName: "mainView"
    applicationName: "cathode-tube.walking-octopus"
    automaticOrientation: true

    width: units.gu(120)
    height: units.gu(75)
    anchorToKeyboard: true

    Rectangle {
        width: parent.width - sidebar.preferredWidth
        height: units.gu(8)
        anchors {
            bottom: parent.bottom
            left: parent.left // FIXME: I couldn't anchor it to the sidebar
            right: parent.right
        }
        z: 100

        color: "lightgrey"

        
        RowLayout {
            anchors {
                fill: parent
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            spacing: units.gu(1)
            // padding: units.gu(1)

            MouseArea {
                anchors.fill: parent
                onClicked: bottomEdge.commit()
            }

            Rectangle {
                SlotsLayout.position: SlotsLayout.Leading
                color: "royalblue"
                width: units.gu(10)
                height: units.gu(6)
            }

            Column {
                Label {
                    text: "Video title"
                }
                Label {
                    text: "Channel"
                }
            }
            
            Item {
                Layout.fillWidth: true
            }

            Icon {
                name: "media-playback-pause"
                width: units.gu(3); height: units.gu(3)

                TapHandler {
                    onTapped: print("Play")
                }
            }

            Icon {
                name: "close"
                width: units.gu(3); height: units.gu(3)

                TapHandler {
                    onTapped: print("Close")
                }
            }
        }
    }

    BottomEdge {
        id: bottomEdge
        height: parent.height - units.gu(20)
        preloadContent: true
        anchors.left: parent.left
        anchors.right: parent.right
        // FIXME: The hint stops being hidden after closing it
        hint.status: "Hidden"
        visible: false
        contentComponent: Page {
            width: bottomEdge.width
            height: bottomEdge.height

            header: PageHeader {
                id: header
                title: "Player"
            }

            Rectangle {
                width: parent.width
                height: parent.height
                color: UbuntuColors.green
            }
        }
    }

    AdaptivePageLayout {
        id: pStack
        anchors.fill: parent
        
        function push(page, properties) {
            return pStack.addPageToNextColumn(primaryPage, page, properties);
        }
        
        layouts: PageColumnsLayout {
            when: width > units.gu(87.5);
            PageColumn {
                id: sidebar
                minimumWidth: preferredWidth;
                maximumWidth: preferredWidth;
                preferredWidth: units.gu(20) + width/7.5;

                // TODO: Hide the sidebar on the login page or video player.
                // You can set preferredWidth to 0 to hide the sidebar, but it might be a hack.
            }
            PageColumn {fillWidth: true;}
        }

        primaryPage: SidebarPage {
            isEnabled: false
            menuActions: [
                Action {
                    iconName: "go-home"
                    text: i18n.tr("Home")
                    onTriggered: pStack.push(Qt.resolvedUrl("./Pages/HomePage.qml"))
                },
                Action {
                    iconName: "history"
                    text: i18n.tr("History")
                    onTriggered: pStack.push(Qt.resolvedUrl("./Pages/History.qml"))
                },
                // TODO: Playlist menu can't be added until upstream does it
                Action {
                    iconName: "voicemail"
                    text: i18n.tr("Watch later")
                    onTriggered: pStack.push(
                        Qt.resolvedUrl("./Pages/Playlist.qml"),
                        {
                            playlist_id: "WL"
                        }
                    )
                },
                Action {
                    iconName: "thumb-up"
                    text: i18n.tr("Liked videos")
                    onTriggered: pStack.push(
                        Qt.resolvedUrl("./Pages/Playlist.qml"),
                        {
                            playlist_id: "LL"
                        }
                    )
                }
                // TODO: Add the notification tab
            ]
        }
        Component.onCompleted: pStack.push(Qt.resolvedUrl("./Pages/SplashScreen.qml"))
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: serverReady

        onStatusChanged: function(status) {
            switch (status) {
                case WebSocket.Connecting: {
                    print("Connecting...");
                    break;
                }
                case WebSocket.Open: {
                    print("Open");
                    break;
                }
                case WebSocket.Closing: {
                    print("Closed");
                    break;
                }
                case WebSocket.Error: {
                    print("Error");
                    break;
                }
            }
        }

        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);

            switch (json.topic) {
                case "authorizationPendingEvent": {
                    print(`Please go to ${json.payload.url} and enter ${json.payload.code} to sign in.`);

                    pStack.push(
                        Qt.resolvedUrl("./Pages/LoginPage.qml"),
                        {
                            verification_url: json.payload.url,
                            code: json.payload.code,
                        },
                    );
                    break;
                }

                case "loginEvent": {
                    pStack.primaryPage.isEnabled = true;
                    pStack.push(Qt.resolvedUrl("./Pages/HomePage.qml"));
                    break;
                }
            }
        }
    }
}
