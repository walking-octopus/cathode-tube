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
    property string currentFeedType: "Home"
    property var model: videoModel
    property bool loaded: false

    ListModel {
        id: videoModel
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            if (status == WebSocket.Open) {
                loaded = true;
                youtube.refresh();
            }
        }
        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);
    
            switch (json.topic) {
                case "error": {
                    print(json.payload);
                    break;
                }
                // STYLE: This use of fall-through doesn't look elegent

                case "feedEvent": videoModel.clear()
                case "continuationEvent": {
                    let feedType = json.payload.feedType;
                    let videos;
                    
                    switch (feedType) {
                        case "Home": {
                            videos = json.payload.videos;
                            break;
                        }

                        case "Subscriptions": {
                            videos = [];
                            for (const item of json.payload.items) {
                                print(item.date);

                                for (const video of item.videos) {
                                    videos.push(video);
                                }
                            }
                            break;
                        }
                            
                        // TODO: Display categories in trending
                        case "Trending": {
                            videos = [];
                            for (const item of json.payload.now.content) {
                                print(item.title);

                                for (let video of item.videos) {
                                    videos.push(video);
                                }
                            }
                            break;
                        }

                        default: {
                            print(`Error: invalid feed type "${feedType}"`);
                            return;
                        }
                    }

                    for (const video of videos) {
                        videoModel.append({
                            "videoTitle": video.title,
                            "channel": video.channel,
                            "thumbnail": video.metadata.thumbnail.url,
                            "published": video.metadata.published,
                            "views": video.metadata.short_view_count_text.simple_text,
                            "duration": video.metadata.duration,
                            "id": video.id,
                        });
                    }

                    loaded = true;
                    youtube.currentFeedType = feedType;

                    break;
                }
            }
        }
    }

    function getFeed(type) {
        if (!youtube.loaded)
            // I prevented getFeed from being called while something is loading, because could result in loading a feed twice or mixing up different feeds.
            return;

        loaded = false;
        print(`Loading ${type}...`);
        websocket.sendTextMessage(`{ "topic": "GetFeed", "payload": "${type}" }`);
    }

    function getContinuation() {
        if (currentFeedType == "Trending")
            return;

        loaded = false;
        websocket.sendTextMessage(
            JSON.stringify({
                topic: "GetContinuation"
            })
        );
    }

    function refresh() {
        print(`Refresh ${youtube.currentFeedType}...`);
        youtube.getFeed(youtube.currentFeedType);
    }
}