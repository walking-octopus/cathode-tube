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
import "../Components"

Page {
    id: historyPage

    header: PageHeader {
        id: header
        title: youtube.loaded ? i18n.tr("History") : i18n.tr("Loading...")
        flickable: scrollView.flickableItem

        leadingActionBar.actions: Action {
            iconName: "navigation-menu"
            text: i18n.tr("Menu")
            onTriggered: pStack.removePages(historyPage)
            visible: !primaryPage.visible
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
    
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
                // TODO: Add an activity indicator for continuations
            }
        }

    }

    VideoDelegate {
        id: videoDelegate
    }

    HistoryModel {
        id: youtube
    }
}