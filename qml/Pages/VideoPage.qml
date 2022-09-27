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
import QtSystemInfo 5.5
import QtSensors 5.0
import "../Components"

Page {
    id: videoDetails

    readonly property var emptyVideo: {
        "metadata": {
            "is_subscribed": false,
            "view_count": 0,
            "rating": 0,
            "is_liked": false,
            "is_disliked": false,
            "likes": {
                "short_count_text": "0"
            },
            "dislikes": {
                "short_count_text": "0"
            },
            "publish_date_text": "",
            "subscriber_count": "0"
        },
        "description": ""
    }
    // FIXME: The metadata often remains undefined, leading to errors. This is a hack. Use a Loader!

    property var selectedVideo: {"videoID": "", "quality": ""}
    property var videoData: emptyVideo

    property alias videoPlayer: videoPlayer

    property string streamingURL

    property string video_title
    property string channel_name

    width: bottomEdge.width; height: bottomEdge.height

    Toast { id: videoToast }

    flickable: null
    header: PageHeader {
        id: header
        title: video_title

        // Setting the height to 0 is a hack, but I couldn't find a proper way to hide the header.
        visible: !videoPlayer.isFullScreen
        height: visible ? implicitHeight : 0
    }
    
    // TODO: (Testing...) Switch to full-screen in landscape
    OrientationSensor {
        id: orientationSensor
        active: true

        onReadingChanged: {
            if (reading.orientation >= OrientationReading.TopUp && reading.orientation <= OrientationReading.RightUp) {
                let orientation = reading.orientation;
                let isLandscape = orientation === OrientationReading.LeftUp || orientation === OrientationReading.RightUp;

                if (isLandscape && !!streamingURL) {
                    window.showFullScreen();
                }
            }
        }
    }

    GridLayout {
        id: layout
        columns: root.width > units.gu(110) && !videoPlayer.isFullScreen ? 2 : 1
        // FIXME: Setting the columns to 1 is a temporary hack for full screen.

        anchors {
            // FIXME: The player might be partialy covered in full-screen mode.
            topMargin: header.height
            fill: parent
        }
        
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: width / 16.0 * 9.0

            ActivityIndicator {
                anchors.centerIn: parent
                running: !videoPlayer.visible // isVideoLoading
            }
            
            WebEngineView {
                id: videoPlayer
                anchors.fill: parent

                ScreenSaver {
                    screenSaverEnabled: !Qt.application.active || !videoPlayer.recentlyAudible
                }

                function play() {
                    runJavaScript(`document.getElementsByTagName("video")[0].play()`);
                }
                function pause() {
                    runJavaScript(`document.getElementsByTagName("video")[0].pause()`);
                }

                // FIXME: The layout is still there out of frame, making it a hack.

                settings.fullScreenSupportEnabled: true

                onFullScreenRequested: {
                    if (request.toggleOn) {
                        window.showFullScreen();
                    } else {
                        window.showNormal();
                    }

                    request.accept();
                }
        
                url: streamingURL

                visible: !!streamingURL
                lifecycleState: !!streamingURL ? WebEngineView.LifecycleState.Active : WebEngineView.LifecycleState.Discarded

                zoomFactor: units.gu(1) / 8
            }
        }

        // FIXME: Scrolling the ScrollView scrolls the home feed, but only sometimes...
        // FIXME: The maximumWidth can slightly clip the content

        ScrollView {
            Layout.maximumWidth: layout.columns > 1 ? parent.width / 2.4 : parent.width
            Layout.fillHeight: true; Layout.fillWidth: true
            contentItem: contentFlickable
        }

        Flickable {
            id: contentFlickable
            anchors.margins: units.gu(2)
            width: parent.width; height: parent.height
            contentHeight: contentLayout.height

            ColumnLayout {
                id: contentLayout
                width: parent.width
                
                ProgressBar {
                    Layout.fillWidth: true
                    indeterminate: true
                    visible: videoData == emptyVideo //isDescriptionLoading
                }
                
                RowLayout {
                    Layout.fillWidth: true

                    // TODO: Fetching the channel thumbnail might require the switch to v2 or an extra request
                    ProfilePicture {
                        name: channel_name

                        Layout.preferredWidth: units.gu(6.5)
                        Layout.preferredHeight: width
                        Layout.rightMargin: units.gu(0.3)
                    }

                    ColumnLayout {
                        id: channelLayout

                        Label {
                            text: channel_name

                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Button {
                            text: !videoData.metadata.is_subscribed ? 
                                i18n.tr("Subscribe (%1)").arg(videoData.metadata.subscriber_count.split(" ")[0]) :
                                i18n.tr("Subscribed")

                            onClicked: {
                                websocket.sendTextMessage(JSON.stringify({
                                    topic: "SetSubscription",
                                    payload: {
                                        channel_id: videoData.metadata.channel_id,
                                        isSubscribed: !videoData.metadata.is_subscribed
                                    },
                                }));
                            }

                            gradient: !videoData.metadata.is_subscribed ? UbuntuColors.orangeGradient : UbuntuColors.greyGradient
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ColumnLayout {
                        Label {
                            text: i18n.tr("%1 views").arg(videoData.metadata.view_count)
                        }

                        ProgressBar {
                            Layout.preferredWidth: units.gu(18)
                            value: videoData.metadata.rating / 5
                        }
                        
                        RowLayout {
                            Layout.topMargin: units.gu(0.5)

                            Icon {
                                name: "thumb-up"
                                color: videoData.metadata.is_liked ? UbuntuColors.green : theme.palette.normal.foregroundText
                                width: units.gu(3); height: width

                                TapHandler {
                                    onTapped: {
                                        websocket.sendTextMessage(JSON.stringify({
                                            topic: "SetRating",
                                            payload: {
                                                id: selectedVideo.videoID,
                                                action: !videoData.metadata.is_liked ? "Like" : "RemoveRating"
                                            },
                                        }));
                                    }
                                }
                            }

                            Label {
                                text: videoData.metadata.likes.short_count_text
                            }

                            Item { width: units.gu(0.5) }

                            Icon {
                                name: "thumb-down"
                                color: videoData.metadata.is_disliked ? UbuntuColors.red : theme.palette.normal.foregroundText
                                width: units.gu(3); height: width

                                TapHandler {
                                    onTapped: {
                                        websocket.sendTextMessage(JSON.stringify({
                                            topic: "SetRating",
                                            payload: {
                                                id: selectedVideo.videoID,
                                                action: !videoData.metadata.is_disliked ? "Dislike" : "RemoveRating"
                                            },
                                        }));
                                    }
                                }
                            }
                            Label {
                                text: videoData.metadata.dislikes.short_count_text
                            }
                        }
                    }
                }

                Label {
                    //Layout.fillWidth: true
                    Layout.topMargin: units.gu(0.6)

                    text: i18n.tr("Published on %1").arg(videoData.metadata.publish_date_text)
                }

                Row {
                    Layout.topMargin: units.gu(1.5)
                    Layout.alignment: Qt.AlignHCenter
                    spacing: units.gu(3)

                    IconButton {
                        text: i18n.tr("Save")
                        iconName: "document-save"
                        onTriggered: playingVideo.download()
                    }

                    IconButton {
                        text: i18n.tr("Add to")
                        iconName: "add-to-playlist"
                        onTriggered: print("TODO: Add playlist item")
                    }

                    IconButton {
                        text: i18n.tr("Share")
                        iconName: "share"
                        onTriggered: {
                            pStack.push(
                                Qt.resolvedUrl("./SharePage.qml"),
                                { "url": `https://youtube.com/watch?${selectedVideo.videoID}` },
                            );

                            bottomEdge.collapse();
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: units.gu(1)

                    text: {
                        function replaceURLs(text) {
                            const urlRegex = /(((http(s)?:\/\/)|(www\.))[^\s]+)/g;
                            text = text.replace(/(?:\r\n|\r|\n)/g, ' <br> ');
                            return text.replace(urlRegex, '<a href="$1">$1</a>');
                        }

                        return replaceURLs(videoData.description);
                    }
                    
                    onLinkActivated: Qt.openUrlExternally(link)
                    wrapMode: Text.Wrap
                    color: theme.palette.normal.baseText
                }
            }
        }
    }


    Connections {
        target: videoDetails

        // FIXME: Video downloads trigger the video player

        onSelectedVideoChanged: {
            if (selectedVideo.videoID == "") {
                print("Closing the video...");

                streamingURL = "";
                videoData = emptyVideo;

                return;
            }

            print("Fetching the info..");
            videoData = emptyVideo;

            websocket.sendTextMessage(JSON.stringify({
                topic: "GetStreamingData",
                payload: {
                    id: selectedVideo.videoID,
                    quality: selectedVideo.quality,
                },
            }));

            websocket.sendTextMessage(JSON.stringify({
                topic: "GetVideoDetails",
                payload: {
                    id: selectedVideo.videoID,
                },
            }));

            metricPlayedVideos.increment();
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
                    streamingURL = json.payload.selected_format.url;
                    print(streamingURL);
                    break;
                }
                case "videoDetailsEvent": {
                    videoData = json.payload;
                    channel_name = videoData.metadata.channel_name;
                    break;
                }
                case "updateSubscription": {
                    videoData.metadata.is_subscribed = json.payload;
                    videoData = videoData;
                    videoToast.show(
                        json.payload ? i18n.tr("Subscribed!") : i18n.tr("Unsubscribed.")
                    );
                    break;
                }
                case "ratingEvent": {
                    switch (json.payload.type) {
                        case "Like": {
                            videoData.metadata.is_liked = true;
                            videoData.metadata.is_disliked = false;
                            videoData = videoData; // QML wouldn't update the props otherwise.
                            videoToast.show(i18n.tr("Liked!"));
                            break;
                        }
                        case "RemoveRating": {
                            videoData.metadata.is_liked = false;
                            videoData.metadata.is_disliked = false;
                            videoData = videoData;
                            videoToast.show(i18n.tr("Rating removed."));
                            break;
                        }
                        case "Dislike": {
                            videoData.metadata.is_disliked = true;
                            videoData.metadata.is_liked = false;
                            videoData = videoData;
                            videoToast.show(i18n.tr("Disliked."));
                            break;
                        }
                    }

                    break;
                }
                case "error": {
                    print(JSON.stringify(json.payload));
                }
            }
        }
    }
}
