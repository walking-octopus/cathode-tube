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
import QtWebEngine 1.10

Page {
    id: videoDetails

    property bool main_ws_ready: false

    property string video_id
    property string video_title
    property string channel_name
    property string thumbnail_url
    property string quality

    property string video_source

    width: bottomEdge.width
    height: bottomEdge.height

    flickable: null
    header: PageHeader {
        id: header
        title: video_title
    }

    WebEngineView {
        id: webview
        anchors {
            fill: parent
            topMargin: header.height
        }
        // TODO: Handle fullscreen request

        zoomFactor: units.gu(1) / 8
        url: video_source
    }

    Connections {
        target: videoDetails

        onVideo_idChanged: {
            if (video_id == "") {
                print("Closing the video...")
                webview.url = "about:black";
                return;
            }

            print("Fetching the info..")
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

    // FIXME: Since the first websocket to connect has to always be the main one, I need add a small delay.
    Timer {
        interval: 100
        running: main_ws_ready
        onTriggered: websocket.active = true
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"

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
                    video_source = json.payload.selected_format.url;
                    print(video_source);
                    break;
                }
                case "videoDetailsEvent": {
                    print(JSON.stringify(json.payload));
                    break;
                }
                case "error": {
                    print(json.payload)
                }
            }
        }
    }
}