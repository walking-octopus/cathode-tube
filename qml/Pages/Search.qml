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
    id: searchPage

    header: PageHeader {
        id: header
        title: i18n.tr("Search")

        leadingActionBar.actions: Action {
            iconName: "back"
            text: i18n.tr("Back")
            onTriggered: {
                pStack.removePages(searchPage);
                pStack.push(Qt.resolvedUrl("./HomePage.qml"))
            }
        }

        contents: TextField {
            id: searchField
            anchors.centerIn: parent
            anchors.margins: 10
            width: Math.min(parent.width, units.gu(36))

            inputMethodHints: Qt.ImhNoPredictiveText

            primaryItem: Icon {
                width: units.gu(2); height: width
                name: "find"
            }
            placeholderText: i18n.tr("Search on YouTube...")
        }
        
        // TODO: Add search filters
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
    
        ListView {
            id: view
            anchors.fill: parent
            anchors.topMargin: searchPage.header.height
            
            model: youtube.suggestions
            delegate: ListItem {
                ListItemLayout {
                    title.text: suggestion
                }

                onClicked: pStack.push(
                    Qt.resolvedUrl("./SearchResults.qml"),
                    {
                        query: suggestion
                    },
                );
            }        

            Timer {
                id: searchTimer
                interval: 500
                onTriggered: youtube.getSearchSuggestions(searchField.text)
            }

            Connections {
                target: searchField
                onTextChanged: searchTimer.restart()
                onAccepted: pStack.push(
                    Qt.resolvedUrl("./SearchResults.qml"),
                    {
                        query: searchField.text
                    },
                );
            }
        }
    }

    SearchModel {
        id: youtube
    }

    Component.onCompleted: {
        // FIXME: The focus quickly shifts away from the search
        if (searchField.text == "") {
            searchField.forceActiveFocus()
        } else {
            searchTimer.restart()
        }
    }
}
