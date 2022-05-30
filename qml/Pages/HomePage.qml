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
import QtQuick.Layouts 1.3
//import Qt.labs.settings 1.0
import "../Components"

Page {
    id: homePage

    header: PageHeader {
        id: header
        flickable: scrollView.flickableItem
        // TODO: Switch to a dedicated actvity indicator
        title: youtube.loaded ? i18n.tr("Home") : i18n.tr("Loading...")

        leadingActionBar.actions: Action {
            iconName: "navigation-menu"
            text: i18n.tr("Menu")
            onTriggered: pStack.removePages(homePage)
            visible: !primaryPage.visible
        }

        trailingActionBar.actions: Action {
            iconName: "reload"
            text: i18n.tr("Reload")
            onTriggered: youtube.refresh()
        }

        extension: Sections {
            actions: [
                Action {
                    text: i18n.tr("Home")
                    onTriggered: youtube.getFeed("Home")
                    // The first action is triggered even before WebSocket is open
                    // To not load the feed twice, I check for loading status in getFeed.
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
    // title: i18n.tr("YT Home")

    FeedModel {
        id: youtube
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent

        // TODO: Add pull to refresh

        GridView {
            id: view
            anchors {
                fill: parent
                topMargin: spacing
                bottomMargin: spacing
                leftMargin: spacing
                rightMargin: spacing
            }

            model: youtube.model
            delegate: videoDelegate

            clip: true
            cellWidth: units.gu(15*2) // To get the 16:9 aspect ratio, the width has to be 1 unit smaller. Why?
            cellHeight: units.gu(12*2)
            property double spacing: units.gu(2)

            onAtYEndChanged: {
                if (view.atYEnd && youtube.model.count > 0) {
                    print("Loading tail videos...");

                    youtube.getContinuation();
                }
                // TODO: Add an activity indicator for continuations
            }
        }
    }

    Component {
        id: videoDelegate

        ColumnLayout {
            Image {
                id: image
                source: thumbnail
                
                Layout.maximumWidth: units.gu(15*2) - view.spacing
                Layout.maximumHeight: units.gu(9*2) - view.spacing

                // anchors.fill: parent
                fillMode: Image.PreserveAspectFit

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

            Label {
                text: `${views} | ${published}`
            }

            Label {
                text: channel.name
            }
        }
    }
}
