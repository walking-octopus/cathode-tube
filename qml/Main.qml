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


//import Example 1.0
import QtQuick 2.9
import Ubuntu.Components 1.3
import QtWebSockets 1.1
//import QtQuick.Controls 2.2
//import QtQuick.Layouts 1.3
// import Qt.labs.settings 1.0
//import "./Components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'cathode-tube.walking-octopus'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)
    anchorToKeyboard: true

    PageStack {
        id: pStack

        Component.onCompleted: pStack.push(Qt.resolvedUrl("./Pages/SplashScreen.qml"))
    }

    Timer {
        id: reconnect
        interval: 12
        onTriggered: {
            websocket.active = false;
            websocket.active = true;
        }
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            switch (status) {
                case WebSocket.Connecting: {
                    print("Connecting...");
                    break;
                }
                case WebSocket.Open: {
                    print("Open");
                    reconnect.running = false;
                    break;
                }
                case WebSocket.Closing: {
                    print("Closed");
                    break;
                }
                case WebSocket.Error: {
                    print("Error");
                    reconnect.running = true;
                    break;
                }
            }
        }

        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);

            switch (json.topic) {
                case "signIn": {
                    print("Hey! This is still WIP, so I didn't add the login page yet.");
                    print(`Please go to ${json.payload.url} and enter ${json.payload.code} to sign in.`);

                    pStack.pop();
                    pStack.push(
                        Qt.resolvedUrl("./Pages/LoginPage.qml"),
                        {
                            verification_url: json.payload.url,
                            code: json.payload.code,
                        },
                    );
                    break;
                }

                case "signedIn": {
                    pStack.pop();
                    pStack.push(Qt.resolvedUrl("./Pages/HomePage.qml"));
                    break;
                }
            }
        }
    }
}
