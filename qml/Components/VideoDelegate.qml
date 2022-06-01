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

Component {
    id: videoDelegate

    ListItem {
        height: units.gu(10.5)
        onClicked: Qt.openUrlExternally(`https://www.youtube.com/watch?v=${id}`)

        ListItemLayout {
            id: layout
            anchors.centerIn: parent

            title.text: videoTitle
            subtitle.text: channel.name
            summary.text: `${views} | ${published}`
            summary.visible: (views != "N/A") ? true : false

            Image {
                id: image
                source: thumbnail
                width: units.gu(13.6) // 16:9
                height: units.gu(8)
                SlotsLayout.position: SlotsLayout.Leading

                opacity: 0
                states: State {
                    name: "loaded"; when: image.status == Image.Ready
                    PropertyChanges { target: image; opacity: 1}
                }
                transitions: Transition {
                    SpringAnimation {
                        easing.type: Easing.InSine
                        spring: 5
                        epsilon: 0.3
                        damping: 0.7
                        properties: "opacity"
                    }
                }

                Label {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: units.gu(0.85)
                        bottomMargin: units.gu(0.5)
                    }

                    text: duration ? duration.simple_text : ""
                    visible: !!duration
                    color: "white"
                    textSize: Label.Small
                    font.weight: Font.DemiBold

                    UbuntuShape {
                        anchors {
                            fill: parent
                            leftMargin: units.gu(-0.45)
                            rightMargin: units.gu(-0.45)
                            topMargin: units.gu(-0.1)
                            bottomMargin: units.gu(-0.1)
                        }
                        z: -1

                        color: "black"
                        opacity: 0.58
                        radius: "small"
                    }
                }
            }
        }
    }
} 