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


import QtQuick 2.0
import QtWebSockets 1.1

Item {
    id: youtube
    property bool loaded: false
    property var model: historyModel

    ListModel {
        id: historyModel
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            if (status == WebSocket.Open) {
                loaded = true;
                youtube.getHistory();
            }
        }
        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);
    
            switch (json.topic) {
                case "historyEvent":
                    historyModel.clear();

                case "continuationEvent": {
                    for (const item of json.payload.items) {
                        for (const video of item.videos) {
                            historyModel.append({
                                "videoTitle": video.title,
                                "channel": video.channel,
                                "thumbnail": video.metadata.thumbnail.url,
                                "published": video.metadata.published,
                                "views": video.metadata.view_count,
                                "id": video.id
                            });
                        }
                    }

                    loaded = true;
                    break;
                }

                case "error": {
                    print(json.payload);
                    break;
                }
            }
        }
    }

    function getHistory() {
        if (!youtube.loaded) {
            return;
        }
        loaded = false;

        websocket.sendTextMessage('{"topic": "GetHistory", "payload": ""}');
    }

    function getContinuation() {
        if (!youtube.loaded) {
            return;
        }
        loaded = false;

        websocket.sendTextMessage(
            JSON.stringify({
                topic: "GetContinuation"
            })
        );
    }
}