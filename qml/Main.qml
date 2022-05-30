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
import "./Pages"

MainView {
    id: root
    objectName: "mainView"
    applicationName: "cathode-tube.walking-octopus"
    automaticOrientation: true

    width: units.gu(120)
    height: units.gu(75)
    anchorToKeyboard: true

    AdaptivePageLayout {
        id: pStack
        anchors.fill: parent
        
        function push(page, properties) {
            print(primaryPage, page)
            return pStack.addPageToNextColumn(primaryPage, page, properties);
        }
        
        layouts: PageColumnsLayout {
            when: width > units.gu(87.5);
            PageColumn {
                minimumWidth: preferredWidth;
                maximumWidth: preferredWidth;
                preferredWidth: units.gu(20) + width/7.5;

                // TODO: Find the way to hide the sidebar on the login page.
                // You can set preferredWidth to 0 to hide the sidebar, but it might be a hack
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
                }
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
                    // reconnect.running = false;
                    break;
                }
                case WebSocket.Closing: {
                    print("Closed");
                    break;
                }
                case WebSocket.Error: {
                    print("Error");
                    // reconnect.running = true;
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
