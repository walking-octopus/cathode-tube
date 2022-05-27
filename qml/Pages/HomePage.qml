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
//import QtQuick.Layouts 1.3
//import Qt.labs.settings 1.0
import "../Components"

Page {
    id: homePage

    header: PageHeader {
        id: header
        flickable: scrollView.flickableItem
        title: youtube.loaded ? i18n.tr('Home') : i18n.tr('Loading...')

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

        // TODO: Add pull to refresh and activity indicators

        ListView {
            id: view
            anchors.fill: parent

            model: youtube.model
            delegate: videoDelegate

            onAtYEndChanged: {
                if (view.atYEnd && youtube.model.count > 0) {
                    print("Loading tail videos...");

                    youtube.getContinuation();
                }
            }
        }
    }

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
                    SlotsLayout.position: SlotsLayout.Leading
                    width: units.gu(13.6) // 16:9
                    height: units.gu(8)

                    opacity: 0
                    states: State {
                        name: 'loaded'; when: image.status == Image.Ready
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
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: units.gu(1)
                        anchors.bottomMargin: units.gu(0.5)

                        text: duration ? duration.simple_text : ""
                        textSize: Label.Small
                        font.weight: Font.DemiBold
                        visible: !!duration
                        color: 'white'
                        
                        Rectangle {
                            anchors.fill: parent
                            anchors.leftMargin: units.gu(-0.45)
                            anchors.rightMargin: units.gu(-0.45)
                            anchors.topMargin: units.gu(-0.1)
                            anchors.bottomMargin: units.gu(-0.1)
                            z: -1

                            color: "black"
                            opacity: 0.6
                            radius: units.gu(0.4)
                        }
                    }
                }
            }
        }
    }
}
