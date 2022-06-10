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
        // TODO: Switch to a dedicated actvity indicator
        title: youtube.loaded ? i18n.tr("Home") : i18n.tr("Loading...")

        leadingActionBar.actions: Action {
            iconName: "navigation-menu"
            text: i18n.tr("Menu")
            onTriggered: pStack.removePages(homePage)
            visible: !primaryPage.visible
        }

        trailingActionBar.actions: [
            Action {
                iconName: "reload"
                text: i18n.tr("Reload")
                onTriggered: youtube.refresh()
            },
            Action {
                iconName: "find"
                text: i18n.tr("Search")
                onTriggered: pStack.push(Qt.resolvedUrl("./Search.qml"))
            }
        ]

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

        ListView {
            id: view
            anchors.fill: parent

            model: youtube.model
            delegate: VideoDelegate {}

            onAtYEndChanged: {
                if (view.atYEnd && youtube.model.count > 0) {
                    print("Loading tail videos...");

                    youtube.getContinuation();
                }
                // TODO: Add an activity indicator for continuations
            }
        }
    }
}
