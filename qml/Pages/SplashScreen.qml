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
    header: PageHeader {
        id: header
    }

    Rectangle {
        id: splashScreen
        anchors.fill: parent

        ActivityIndicator {
            id: loadingflg
            anchors.centerIn: parent

            running: splashScreen.visible
        }

        //transitions: Transition {
            //NumberAnimation { property: "opacity"; duration: 400}
        //}

        //states: [
            //State { when: !root.serverLoaded;
                //PropertyChanges { target: splashScreen; opacity: 1.0 }
            //},
            //State { when: root.serverLoaded;
                //PropertyChanges { target: splashScreen; opacity: 0.0 }
            //}
        //]
    }
}
