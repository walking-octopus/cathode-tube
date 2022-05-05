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

    // signal messageReceived(string message)

    PageStack {
        id: pStack
        // property alias onWSTextMessageReceived: websocket.onTextMessageReceived
        // property var onWSTextMessageReceived: websocket.onTextMessageReceived

        Component.onCompleted: pStack.push(Qt.resolvedUrl("./Pages/MainPage.qml"))
    }

    //WebSocket {
        //id: websocket
        //url: "ws://localhost:8999"
        //active: true

        //onStatusChanged: function(status) {
            //print(status)

            //if (status == WebSocket.Open) {
                ////view.model.status = status
                //console.log("Open");
                //pStack.push(Qt.resolvedUrl("./Pages/MainPage.qml"))
            //}
        //}

        //onTextMessageReceived: function(message) {
            //print("Main.qml: Recived message!")
            //// root.messageReceived(message);
        //}

        // onTextMessageReceived: function(message) {
        //     print(message);
        //     let json = JSON.parse(message);

        //     switch (json.topic) {
        //         case "updateStatus": {
        //             print(json.payload);
        //             break;
        //         }
        //         case "updateFeed": {
        //             videoModel.clear();
        //             for (let video of json.payload.videos) {
        //                 videoModel.append(
        //                     {
        //                         "videoTitle": video.title,
        //                         "channel": video.channel
        //                     }
        //                 );
        //             }
        //             break;
        //         }
        //     }
        // }
    //}
}
