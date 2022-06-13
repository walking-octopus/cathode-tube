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

Page {
    property string video_id
    property string video_title
    property string channel_name
    property string thumbnail_url
    property string quality

    width: bottomEdge.width
    height: bottomEdge.height

    header: PageHeader {
        id: header
        title: video_title
    }

    Label {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        text: !!video_id ? `Playing ${video_id} at ${quality}...` : i18n.tr('No media')
        font.pixelSize: units.gu(3)

        TapHandler {
            onTapped: Qt.openUrlExternally(`https://www.youtube.com/watch?v=${video_id}`)
        }

        verticalAlignment: Label.AlignVCenter
        horizontalAlignment: Label.AlignHCenter
    }
}