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
import Ubuntu.Components.Popups 1.3
import QtWebSockets 1.1
import UserMetrics 0.1
import "./Pages"
import "./Components"

MainView {
    id: root
    objectName: "mainView"
    applicationName: "cathode-tube.walking-octopus"
    automaticOrientation: true
    anchorToKeyboard: true

    width: units.gu(120)
    height: units.gu(75)

    // This isn't perfect. Maybe if I can write my own text into usermetrics,
    // I can fetch watch time from YouTube itself. (Blocked by YouTube.js v2)
    // Metric {
    //     id: metricWatchTime
    //     name: "watch-time"
    //     format: i18n.tag("Today you've spent %1 minutes watching YouTube")
    //     emptyFormat: i18n.tag("No time wasted on YouTube today. Keep it up!"); minimum: 0
    //     domain: "cathode-tube"
        
    //     You can edit the format and use update to push text into it!
    //     function pushText(value) {
    //         format = value;
    //         update(1);
    //     }
        
    //     Timer {
    //         interval: 60000 // Every minute
    //         running: !!playingVideo.selectedVideo
    //         onTriggered: metricWatchTime.increment()
    //     }
    // }

    // I think counting the number of videos watches would be simpler for now.
    Metric {
        id: metricPlayedVideos
        name: "played-videos"
        format: i18n.tag("Played %1 YouTube videos.")
        emptyFormat: i18n.tag("No time wasted on YouTube today. Keep it up!"); minimum: 0
        domain: "cathode-tube"
    }

    Item {
        id: playingVideo

        property var selectedVideo: { "videoID": "", "quality": "" }

        property string video_title
        property string channel_name
        property string thumbnail_url

        property alias videoPage: bottomEdge.contentItem

        property int progress: 0

        function download() {
            websocket.sendTextMessage(JSON.stringify({
                topic: "DownloadVideo",
                payload: {
                    video_title: `${video_title} | ${channel_name}`,
                    video_id: selectedVideo.videoID,
                    quality: selectedVideo.quality
                },
            }));

            PopupUtils.open(downloadDialog, null, {
                'video': playingVideo,
            });
        }

        function deleteFile(filePath) {
            websocket.sendTextMessage(JSON.stringify({
                topic: "DeleteFile",
                payload: { path: filePath },
            }));
        }
    }

    MiniPlayer {
        id: miniPlayer

        video_title: playingVideo.video_title
        channel_name: playingVideo.channel_name
        thumbnail_url: playingVideo.thumbnail_url

        onShowDetails: bottomEdge.commit()
    }

    BottomEdge {
        id: bottomEdge
        anchors {
            left: parent.left
            right: parent.right
        }

        hint.status: "Hidden"
        visible: false
        onCollapseCompleted: visible = false

        // Delay loading bottom edge until after the main WS is open to save on startup time

        // FIXME: Why even load it if nothing's playing?
        // The WebSocket needs some time to connect before sending a message. Preloading is thus required.

        preloadContent: false
        Timer {
            interval: 100
            running: websocket.status == WebSocket.Open
            onTriggered: bottomEdge.preloadContent = true
        }

        contentComponent: VideoPage {
            id: videoPage

            selectedVideo: playingVideo.selectedVideo
            video_title: playingVideo.video_title
            channel_name: playingVideo.channel_name
        }
    }

    PreplayDialog {
        id: preplayDialog
    }

    DownloadDialog {
        id: downloadDialog
    }

    AdaptivePageLayout {
        id: pStack
        anchors.fill: parent
        
        function push(page, properties) {
            return pStack.addPageToNextColumn(primaryPage, page, properties);
        }
        
        layouts: PageColumnsLayout {
            when: width > units.gu(87.5);
            PageColumn {
                id: sidebar
                minimumWidth: preferredWidth; maximumWidth: preferredWidth;
                preferredWidth: units.gu(20) + width/7.5;
            }
            PageColumn {fillWidth: true;}
        }

        primaryPage: SidebarPage {
            isEnabled: false
            menuActions: [
                Action {
                    iconName: "go-home"
                    text: i18n.tr("Home")
                    onTriggered: pStack.push(Qt.resolvedUrl("./Pages/HomePage.qml"))
                },
                Action {
                    iconName: "notification"
                    text: i18n.tr("Notifications")
                    onTriggered: pStack.push(Qt.resolvedUrl("./Pages/Notifications.qml"))
                },
                Action {
                    iconName: "document-save-as"
                    text: i18n.tr("Downloads")
                    onTriggered: pStack.push(Qt.resolvedUrl("./Pages/Downloads.qml"))
                },
                Action {
                    iconName: "history"
                    text: i18n.tr("History")
                    onTriggered: pStack.push(Qt.resolvedUrl("./Pages/History.qml"))
                },
                // TODO: Library page is blocked by YouTube.js v2
                Action {
                    iconName: "voicemail"
                    text: i18n.tr("Watch later")
                    onTriggered: pStack.push(
                        Qt.resolvedUrl("./Pages/Playlist.qml"),
                        { playlist_id: "WL" }
                    )
                },
                Action {
                    iconName: "thumb-up"
                    text: i18n.tr("Liked videos")
                    onTriggered: pStack.push(
                        Qt.resolvedUrl("./Pages/Playlist.qml"),
                        { playlist_id: "LL" }
                    )
                }
            ]
        }

        Component.onCompleted: pStack.push(Qt.resolvedUrl("./Pages/SplashScreen.qml"))
    }

    WebSocket {
        id: websocket
        url: "ws://localhost:8999"
        active: serverReady

        onStatusChanged: function(status) {
            switch (status) {
                case WebSocket.Connecting: {
                    print("Connecting...");
                    break;
                }
                case WebSocket.Open: {
                    print("Open");
                    break;
                }
                case WebSocket.Closing: {
                    print("Closed");
                    break;
                }
                case WebSocket.Error: {
                    print("Error");
                    break;
                }
            }
        }

        onTextMessageReceived: function(message) {
            let json = JSON.parse(message);

            switch (json.topic) {
                case "authorizationPendingEvent": {
                    print(`Please go to ${json.payload.url} and enter ${json.payload.code} to sign in.`);

                    pStack.push(
                        Qt.resolvedUrl("./Pages/LoginPage.qml"),
                        {
                            verification_url: json.payload.url,
                            code: json.payload.code,
                        },
                    );

                    break;
                }

                case "loginEvent": {
                    pStack.primaryPage.isEnabled = true;
                    pStack.push(Qt.resolvedUrl("./Pages/HomePage.qml"));
                    break;
                }

                case "videoDownloadEvent": {
                    playingVideo.progress = json.payload;

                    if (playingVideo.progress == 100)
                        playingVideo.progress = 0;

                    break;
                }
            }
        }
    }
}
