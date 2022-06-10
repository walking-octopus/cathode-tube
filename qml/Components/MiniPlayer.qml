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

Rectangle {
    width: parent.width - sidebar.preferredWidth
    height: units.gu(8)
    anchors {
        bottom: parent.bottom
        left: parent.left // FIXME: I couldn't anchor it to the sidebar
        right: parent.right
    }
    z: 25

    color: theme.palette.normal.base
    // visible: false
    
    RowLayout {
        anchors {
            fill: parent
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
        spacing: units.gu(1)

        MouseArea {
            anchors.fill: parent
            onClicked: bottomEdge.commit()
        }

        Rectangle {
            SlotsLayout.position: SlotsLayout.Leading
            color: "royalblue"
            width: units.gu(10)
            height: units.gu(6)
        }

        Column {
            Label {
                text: "Video title"
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