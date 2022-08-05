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

Page {
    id: sidebarPage

    property bool isEnabled: false
    property list<Action> menuActions
    
    header: PageHeader {
        id: header
        title: i18n.tr("Cathode")

        automaticHeight: false
    }

    ListView {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        enabled: isEnabled
        model: menuActions

        delegate: ListItem {
            // This looks quite weird, but it required an argument
            onClicked: onTriggered(null)

            ListItemLayout {
                anchors.centerIn: parent

                Icon {
                    name: iconName
                    color: theme.palette.normal.foregroundText

                    width: units.gu(2); height: width
                    SlotsLayout.position: SlotsLayout.First
                }

                title.text: text

                Icon {
                    name: "go-next"
                    color: theme.palette.normal.foregroundText

                    width: units.gu(2); height: width
                    SlotsLayout.position: SlotsLayout.Last
                }
            }
        }
    }
}