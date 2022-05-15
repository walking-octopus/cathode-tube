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

        Component.onCompleted: pStack.push(Qt.resolvedUrl("./Pages/MainPage.qml"))
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            if (status == WebSocket.Open) {
                console.log("Open");
                pStack.push(Qt.resolvedUrl("./Pages/MainPage.qml"))
            } else if (status == WebSocket.Closed) {
                console.log("Closed");
                websocket.active = false;
                websocket.active = true;
            } else if (status == WebSocket.Connecting) {
                console.log("Connecting");
            }
        }
    }
}
