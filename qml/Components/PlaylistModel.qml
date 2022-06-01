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
import QtWebSockets 1.1

Item {
    id: youtube
    property bool loaded: false
    property var model: playlistModel
    property string playlist

    property var playlistInfo
    Component.onCompleted: {
        playlistInfo = {
            title: "",
            description: "",
            total_items: "",
            last_updated: "",
            views: ""
        }
    }

    ListModel {
        id: playlistModel
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            if (status == WebSocket.Open) {
                loaded = true;
                youtube.getPlaylist(playlist);
            }
        }
        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);
    
            switch (json.topic) {
                case "playlistEvent": {
                    playlistModel.clear();

                    for (const video of json.payload.items) {
                        playlistModel.append({
                            "videoTitle": video.title,
                            "channel": video.channel,
                            "thumbnail": video.thumbnails[0].url,
                            "duration": video.duration,
                            "id": video.id,
                            "views": "N/A",
                            "published": "N/A"
                        });
                    }

                    playlistInfo = {
                        title: json.payload.title,
                        description: json.payload.description,
                        total_items: json.payload.total_items,
                        last_updated: json.payload.last_updated,
                        views: json.payload.views
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

    function getPlaylist(id) {
        if (!youtube.loaded) {
            return;
        }
        loaded = false;

        websocket.sendTextMessage(
            JSON.stringify({
                topic: "GetPlaylist",
                payload: id,
            }),
        );
    }
}