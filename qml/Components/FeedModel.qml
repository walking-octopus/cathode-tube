import QtQuick 2.0
import QtWebSockets 1.1

Item {
    id: youtube
    property string currentFeedType: "Home"
    property variant model: videoModel
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
                youtube.refresh();
            }
        }
        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);
    
            switch (json.topic) {
                // STYLE: This use of fall-through doesn't look elegent

                case "error": {
                    print(json.payload);
                    break;
                }

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
                            
                        // TODO: Use categories trending parsing
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
                            print(`Error: invalid feed type ${feedType}`);
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
                            "id": video.id
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
        loaded = false;
        websocket.sendTextMessage(`{ "topic": "GetFeed", "payload": "${type}" }`);
    }

    function getContinuation() {
        loaded = false;
        if (currentFeedType == "Trending") { return; }
        websocket.sendTextMessage(
            JSON.stringify({
                topic: "GetContinuation"
            })
        );
    }

    function refresh() {
        loaded = false;
        youtube.getFeed(youtube.currentFeedType);
    }
}