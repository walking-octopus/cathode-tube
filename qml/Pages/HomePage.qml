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
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
//import QtQuick.Layouts 1.3
//import Qt.labs.settings 1.0
import QtWebSockets 1.1

Page {
    header: PageHeader {
        id: header
        flickable: scrollView.flickableItem
        title: i18n.tr('Home')

        // leadingActionBar.actions: Action {
        //     iconName: "navigation-menu"
        //     text: i18n.tr("Menu")
        //     onTriggered: print("Placeholder")
        // }

        trailingActionBar.actions: Action {
            iconName: "reload"
            text: i18n.tr("Reload")
            onTriggered: youtube.getFeed(youtube.currentFeedType)
        }

        extension: Sections {
            actions: [
                Action {
                    text: i18n.tr("Home")
                    onTriggered: youtube.getFeed("Home")
                },
                Action {
                    text: i18n.tr("Subscriptions")
                    onTriggered: youtube.getFeed("Subscriptions")
                },
                Action {
                    text: i18n.tr("Trending")
                    onTriggered: youtube.getFeed("Trending")
                }
            ]
        }
    }
    title: i18n.tr("YT Home")

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

        onStatusChanged: function(status) {
            if (status == WebSocket.Open) {
                youtube.getFeed(youtube.currentFeedType);
            }
        }
        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);
    
            switch (json.topic) {
                // STYLE: This use of fall-through doesn't look elegent

                case "feedEvent": videoModel.clear()

                case "continuationEvent": {
                    // FIXME: I think feed types should be handeled the server
                    let feedType = youtube.currentFeedType;
                    
                    switch (feedType) {
                        case "Home":
                            for (const video of json.payload.videos) {
                                // FIXME: Different feeds give out different information. This doesn't account for it.
                                videoModel.append({
                                    "videoTitle": video.title,
                                    "channel": video.channel,
                                    "thumbnail": video.metadata.thumbnail.url,
                                    "published": video.metadata.published,
                                    "views": video.metadata.short_view_count_text.simple_text,
                                    "duration": video.metadata.duration.simple_text,
                                    "id": video.id
                                });
                            }
                            break;

                        // TODO: Add proper subscription/trending parsing
                        case "Subscriptions":
                            for (const item of json.payload.items) {
                                print(item.date)
                                for (let video of item.videos) {
                                    videoModel.append({
                                        "videoTitle": video.title,
                                        "channel": video.channel,
                                        "thumbnail": video.metadata.thumbnail.url,
                                        "published": video.metadata.published,
                                        "views": video.metadata.short_view_count_text.simple_text,
                                        // "duration": video.metadata.duration.simple_text,
                                        "id": video.id
                                    });
                                }
                            }
                            break;

                        case "Trending":
                            for (const item of json.payload.now.content) {
                                print(item.title);
                                for (let video of item.videos) {
                                    videoModel.append({
                                        "videoTitle": video.title,
                                        "channel": video.channel,
                                        "thumbnail": video.metadata.thumbnail.url,
                                        "published": video.metadata.published,
                                        "views": video.metadata.short_view_count_text.simple_text,
                                        // "duration": video.metadata.duration.simple_text,
                                        "id": video.id
                                    });
                                }
                            }
                            break;

                        default: {
                            print("Error: invalid feed type");
                            print(feedType);
                            return;
                        }
                    }


                    break;
                }
            }
        }
    }

    QtObject {
        id: youtube

        property string currentFeedType: "Home"

        function getFeed(type) {
            currentFeedType = type;
            websocket.sendTextMessage(`{ "topic": "GetFeed", "payload": "${type}" }`);
        }

        function getContinuation() {
            websocket.sendTextMessage(
                JSON.stringify({
                    topic: "GetContinuation"
                })
            );
        }
    }

    ListModel {
        id: videoModel
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent

        ListView {
            id: view
            anchors.fill: parent

            model: videoModel
            delegate: ListItem {
                height: units.gu(8.5)
                onClicked: Qt.openUrlExternally(`https://www.youtube.com/watch?v=${id}`)

                ListItemLayout {
                    id: layout
                    anchors.centerIn: parent
                    
                    title.text: videoTitle
                    subtitle.text: channel.name
                    summary.text: duration ? `${duration} | ${views} | ${published}` : `${views} | ${published}`

                    Image {
                        SlotsLayout.position: SlotsLayout.Leading
                        width: units.gu(10) // 16/9
                        height: units.gu(6)
                        source: thumbnail
                    }
                }
            }

            onAtYEndChanged: {
                if (view.atYEnd && videoModel.count > 0) {
                    print("Loading tail videos...");

                    // FIXME: The trending feed isn't infinite, so don't try fetching more of it.
                    youtube.getContinuation();
                }
            }
        }
    }
}
