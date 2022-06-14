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
import Ubuntu.Components 1.3
import QtWebSockets 1.1

Page {
    id: videoDetails

    property string video_id
    property string video_title
    property string channel_name
    property string thumbnail_url
    property string quality

    width: bottomEdge.width
    height: bottomEdge.height

    header: PageHeader {
        id: header
        title: video_title
    }

    Label {
        id: label
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        text: !!video_id ? `Playing ${video_id} at ${quality}...` : i18n.tr('No media')
        font.pixelSize: units.gu(3)

        TapHandler {
            onTapped: Qt.openUrlExternally(`https://www.youtube.com/watch?v=${video_id}`)
        }

        verticalAlignment: Label.AlignVCenter
        horizontalAlignment: Label.AlignHCenter
    }

    Connections {
        target: videoDetails

        onVideo_idChanged: {
            websocket.sendTextMessage(
                JSON.stringify({
                    topic: "GetStreamingData",
                    payload: {
                        id: video_id,
                        quality: quality,
                    },
                }),
            );
            websocket.sendTextMessage(
                JSON.stringify({
                    topic: "GetVideoDetails",
                    payload: {
                        id: video_id,
                    },
                }),
            );
        }
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: serverReady // FIXME: Activate the server 100ms after the main one

        onStatusChanged: function(status) {
            switch (status) {
                case WebSocket.Connecting: {
                    print("Player WS connecting...");
                    break;
                }
                case WebSocket.Open: {
                    print("Player WS open");
                    break;
                }
                case WebSocket.Closing: {
                    print("Player WS closed");
                    break;
                }
                case WebSocket.Error: {
                    print("Player WS error");
                    break;
                }
            }
        }

        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);

            switch (json.topic) {
                case "streamingDataEvent": {
                    print(json.payload.selected_format.url);
                    break;
                }
                case "videoDetailsEvent": {
                    print(JSON.stringify(json.payload));
                    break;
                }
            }
        }
    }
}