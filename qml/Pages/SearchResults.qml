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
    id: searchResults
    property string query

    header: PageHeader {
        id: header
        flickable: scrollView.flickableItem
        title: i18n.tr(`Results for «${query}»`)

        leadingActionBar.actions: Action {
            iconName: "back"
            text: i18n.tr("Back")
            onTriggered: {
                // FIXME: The sidebar flickers for a moment when switching pages.
                pStack.removePages(searchResults);
                pStack.push(Qt.resolvedUrl("./HomePage.qml"));
            }
        }

        // TODO: Allow filtering by content types
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
    
        ListView {
            id: view
            anchors.fill: parent            

            model: youtube.results
            delegate: VideoDelegate {}

            // Upstream bug prevents getting search continuations
        }
    }

    SearchModel {
        id: youtube
        onReady: youtube.getSearchResults(query)
    }
}
