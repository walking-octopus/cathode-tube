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
// import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.12

Rectangle {
    id: bgRectangle

    property string video_id
    property string video_title

    signal showDetails()

    // TODO: Add margin
    width: parent.width
    height: units.gu(8)
    anchors {
        bottom: parent.bottom
        left: parent.left // FIXME: I couldn't anchor it to the sidebar
        right: parent.right
        margins: units.gu(1.5)
    }
    z: 25

    layer.enabled: true
    layer.effect: DropShadow{
        anchors.fill: bgRectangle
        visible: bgRectangle.visible

        source: bgRectangle

        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        color: "#80000000"
    }

    color: theme.name == "Ubuntu.Components.Themes.Ambiance" ? "white" : "#3B3B3B"
    // visible: !!video_id
    
    // TODO: Use slot layout
    RowLayout {
        anchors {
            fill: parent
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
        spacing: units.gu(1)
        
        MouseArea {
            // FIXME: Anchors don't work with layouts which breaks it when toggling visibility
            anchors.fill: parent
            onClicked: showDetails()
        }

        Rectangle {
            color: "royalblue"
            width: units.gu(10)
            height: units.gu(6)
        }

        Column {
            Label {
                text: video_title
            }
            Label {
                text: "Channel"
            }
        }
        
        Item {
            Layout.fillWidth: true
        }

        Icon {
            name: "media-playback-pause"
            width: units.gu(3); height: units.gu(3)

            TapHandler {
                onTapped: print("Play")
            }
        }

        Icon {
            name: "close"
            width: units.gu(3); height: units.gu(3)

            TapHandler {
                onTapped: print("Close")
            }
        }
    }
}