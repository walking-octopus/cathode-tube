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
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import QtWebSockets 1.1
import QtWebEngine 1.10

Page {
    id: videoDetails

    // These should be grouped into something like a turple, since you need both to stream a video
    property string video_id
    property string quality

    property string video_title
    property string channel_name
    property string thumbnail_url

    property string video_source
    property var videoData

    width: bottomEdge.width
    height: bottomEdge.height

    flickable: null
    header: PageHeader {
        id: header
        title: video_title

        // FIXME: This is a hack, but I couldn't find a proper way to hide the header
        height: !videoPlayer.isFullScreen ? units.gu(6.125) : 0
        visible: !videoPlayer.isFullScreen
    }

    GridLayout {
        id: layout
        columns: root.width > units.gu(100) && !videoPlayer.isFullScreen ? 2 : 1

        // FIXME: Setting the columns to 1 is a temporary hack for full screen.

        anchors {
            topMargin: header.height // FIXME: The player is partialy covered in full-screen mode.
            fill: parent
        }
        
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: width / 16.0 * 9.0
            
            WebEngineView {
                id: videoPlayer
                anchors.fill: parent

                // FIXME: The layout is still out of frame and the webview is upscaled.

                settings.fullScreenSupportEnabled: true

                onFullScreenRequested: {
                    if (request.toggleOn) {
                        window.showFullScreen();
                    } else {
                        window.showNormal();
                    }

                    request.accept();
                }
        
                zoomFactor: units.gu(1) / 8
                url: !!video_source ? video_source : "about:blank"
            }
        }

        // FIXME: Use a scroll view.
        // Also, somehow you can scroll the feed, even when it's covered by the video player

        ColumnLayout {
            Layout.maximumWidth: layout.columns > 1 ? parent.width / 2.3 : parent.width
            Layout.margins: units.gu(1.5)

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    color: UbuntuColors.orange

                    height: channelLayout.height / 1.1; width: height;
                    Layout.rightMargin: units.gu(0.5)
                }

                ColumnLayout {
                    id: channelLayout
                    Layout.maximumWidth: parent.width / 2.5

                    Label {
                        text: channel_name

                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Button {
                        text: !videoData.metadata.is_subscribed ? `Subscribe (${videoData.metadata.subscriber_count.split(" ")[0]})` : "Subscribed"
                        color: !videoData.metadata.is_subscribed ? UbuntuColors.red : UbuntuColors.warmGrey
                    }
                }

                Item { Layout.fillWidth: true }

                ColumnLayout {
                    Label {
                        text: "14k views"
                    }

                    ProgressBar {
                        Layout.preferredWidth: 150
                        value: videoData.metadata.rating / 5
                    }

                    RowLayout {
                        Icon {
                            name: "thumb-up"
                            width: units.gu(3); height: width
                        }
                        Label {
                            text: videoData.metadata.likes.short_count_text
                        }

                        Item {
                            width: units.gu(1)
                        }

                        Icon {
                            name: "thumb-down"
                            width: units.gu(3); height: width
                        }
                        Label {
                            text: videoData.metadata.dislikes.short_count_text
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: units.gu(2)

                text: !!videoData ? videoData.description : ""

                wrapMode: Text.WordWrap
                color: theme.palette.normal.baseText
            }
        }
    }

    Connections {
        target: videoDetails

        onVideo_idChanged: {
            if (video_id == "") {
                print("Closing the video...")
                video_source = "";
                videoData = undefined;
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

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: true

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
                    videoData = json.payload;
                    break;
                }
                case "error": {
                    print(json.payload);
                }
            }
        }
    }
}
