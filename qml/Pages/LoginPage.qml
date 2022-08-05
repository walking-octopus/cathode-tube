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
import QtQuick.Layouts 1.3

Page {
    property string verification_url
    property string code

    header: PageHeader {
        id: header
        title: i18n.tr("Welcome!")
        leadingActionBar.actions: null
    }
    title: i18n.tr("Login")

    ColumnLayout {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        anchors.margins: units.gu(3)
        spacing: units.gu(1)

        Label {
            text: i18n.tr("Welcome to Cathode!")
            textSize: Label.XLarge
        }

        Label {
            text: i18n.tr(`It works by imitating official YouTube apps with <a href="https://github.com/LuanRT/YouTube.js">YouTube.js</a>, instead of the limited official API, allowing complete feature parity. <br><br> While Google's ToS only forbids automated interactions, nobody's certain about their anti-abuse system. Try not to trip over the rate-limit or engage in usage patterns that could be mistaken for a bot, like commenting on a lot of videos at once.`)
            wrapMode: "Wrap"

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            text: i18n.tr('To log in, please go to <a href="%1">%1</a> and enter "%3".').arg(verification_url).arg(code)
            wrapMode: "Wrap"

            Layout.fillWidth: true
            Layout.bottomMargin: units.gu(2)
        }

        Button {
            text: i18n.tr("Open and copy")
            color: theme.palette.normal.positive

            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: implicitWidth + units.gu(3)

            onClicked: {
                Clipboard.push(code);
                Qt.openUrlExternally(verification_url);
            }
        }
    }

}
