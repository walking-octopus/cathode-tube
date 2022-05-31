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
    property var suggestions: suggestionModel
    property var results: resultsModel
    property bool loaded: false

    signal ready()

    ListModel {
        id: suggestionModel
    }

    ListModel {
        id: resultsModel
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            if (status == WebSocket.Open) {
                loaded = true;
                ready();
            }
        }
        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);
    
            switch (json.topic) {
                case "error": {
                    print(json.payload);
                    break;
                }

                case "searchSuggestionsEvent": {
                    suggestionModel.clear();
                    for (const suggestion of json.payload.results) {
                        suggestionModel.append({
                            "suggestion": suggestion
                        });
                    }

                    loaded = true;
                    break;
                }

                case "searchResultsEvent": {
                    resultsModel.clear();
                    for (const video of json.payload.videos) {
                        // print(video.title);
                        resultsModel.append({
                            "videoTitle": video.title,
                            "channel": video.channel,
                            "thumbnail": video.metadata.thumbnails[0].url,
                            "published": video.metadata.published,
                            "views": video.metadata.view_count,
                            "duration": video.metadata.duration,
                            "id": video.id
                        });
                    }

                    loaded: true;
                    break;
                }
            }
        }
    }

    function getSearchSuggestions(query) {
        if (!youtube.loaded || !query) {
            suggestionModel.clear();
            return;
        }
        loaded = false;

        websocket.sendTextMessage(`{"topic": "GetSearchSuggestions", "payload": "${query}"}`);
    }

    function getSearchResults(query) {
        if (!youtube.loaded || !query)
            return;
        loaded = false;

        websocket.sendTextMessage(`{"topic": "GetSearchResults", "payload": "${query}"}`);
    }
}