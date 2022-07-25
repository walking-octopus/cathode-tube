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
import Ubuntu.Components.Popups 1.3

Component {
    id: preplayDialog
    
    Dialog {
        id: dialog
    
        property string video_id
        property string video_title
        property string channel_name
        property string thumbnail_url

        title: video_title
        text: i18n.tr("Download or watch this video")

        OptionSelector {
            id: qualitySelector
            text: i18n.tr("Quality")
            model: ['720p', '480p', '360p', '240p', '140p']

            // FIXME: For some reason, YouTube.js can't find a quality for `1080p`, so I'll remove it from the list until it's fixed.
        }

        RowLayout {
            Button {
                text: i18n.tr("Play")
                color: theme.palette.normal.positive
                Layout.fillWidth: true

                onClicked: {
                    playingVideo.video_title = video_title;
                    playingVideo.channel_name = channel_name;
                    playingVideo.thumbnail_url = thumbnail_url;

                    playingVideo.selectedVideo = {
                        "quality": qualitySelector.model[qualitySelector.selectedIndex],
                        "videoID": video_id,
                    };
                    
                    miniPlayer.showDetails();
                    PopupUtils.close(dialog);
                }
            }

            // Button {
            //     text: "Download"
            //     color: UbuntuColors.blue
            //     Layout.fillWidth: true
            //     visible: false

            //     // TODO: Add the download
            //     onClicked: PopupUtils.close(dialog)
            // }
        }

        Button {
            text: i18n.tr("Cancel")
            onClicked: PopupUtils.close(dialog)
        }
    }
}
