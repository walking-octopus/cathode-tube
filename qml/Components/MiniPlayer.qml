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
// import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.12

Rectangle {
    id: bgRectangle

    property string video_title
    property string channel_name
    property string thumbnail_url

    signal showDetails()

    width: parent.width
    height: units.gu(8)
    anchors {
        bottom: parent.bottom
        left: parent.left // FIXME: I couldn't anchor it to the sidebar
        right: parent.right
        margins: units.gu(1.5)
    }
    z: 25

    // FIXME: The shadow is not in grid units
    layer.enabled: true
    layer.effect: DropShadow{
        anchors.fill: bgRectangle

        source: bgRectangle
        visible: bgRectangle.visible

        horizontalOffset: units.gu(0.38); verticalOffset: units.gu(0.38)
        radius: units.gu(1)
        color: "#80000000"
    }

    color: theme.name == "Ubuntu.Components.Themes.Ambiance" ? "white" : "#3B3B3B" // Dark color might look too gray
    visible: !!video_title // TODO: Add a visibility transition
    
    MouseArea {
        anchors.fill: layout
        onClicked: showDetails()
    }

    // Using ListItemLayout feels like a hack, but it works fine.
    ListItemLayout {
        id: layout
        
        Image {
            source: thumbnail_url

            width: units.gu(10); height: units.gu(6)
            SlotsLayout.position: SlotsLayout.Leading
        }

        title.text: video_title
        subtitle.text: channel_name

        Icon {
            name: playingVideo.videoPage != null && playingVideo.videoPage.videoPlayer.recentlyAudible ?
                "media-playback-pause" :
                "media-playback-start"

            TapHandler {
                onTapped: playingVideo.videoPage != null && playingVideo.videoPage.videoPlayer.recentlyAudible ?
                    playingVideo.videoPage.videoPlayer.pause() :
                    playingVideo.videoPage.videoPlayer.play()
            }

            width: units.gu(3); height: width
            SlotsLayout.position: SlotsLayout.Trailing
        }

        Icon {
            name: "close"
            
            TapHandler {
                onTapped: {
                    playingVideo.video_title = '';
                    playingVideo.channel_name = '';
                    playingVideo.thumbnail_url = '';

                    playingVideo.selectedVideo = {"videoID": "", "quality": ""};
                }
            }

            width: units.gu(3); height: width
            SlotsLayout.position: SlotsLayout.Trailing
        }
    }
}