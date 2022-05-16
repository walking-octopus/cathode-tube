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

Page {
    property string verification_url
    property string code

    header: PageHeader {
        id: header
        title: i18n.tr('Welcome!')
    }
    title: i18n.tr("Login")

    ColumnLayout {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: units.gu(0.5)

        Label {
            text: i18n.tr(`Welcome to Cathode! <br> It works by imitating official YouTube apps through <a href="https://github.com/LuanRT/YouTube.js">YouTube.js</a> instead of the limited official API, allowing complete feature parity to the official apps. While Google's ToS only forbids automated interactions, nobody's certain about their anti-abuse system, so try not to trip over the rate limit or engage in usage patterns that could be mistaken for a bot.`)
            wrapMode: "WordWrap"

            Layout.fillWidth: true
            Layout.leftMargin: units.gu(2)
            Layout.rightMargin: units.gu(2)
            Layout.topMargin: units.gu(2)
        }
        Label {
            text: i18n.tr(`To log in, please go to <a href="${verification_url}">${verification_url}</a> and enter "${code}".`)
            wrapMode: "WordWrap"

            Layout.fillWidth: true
            Layout.leftMargin: units.gu(2)
            Layout.rightMargin: units.gu(2)
            Layout.topMargin: units.gu(2)
        }
        //Button {
            //text: i18n.tr("Open the page and copy the code")
            //onClicked: internal.onTokenChanged()
            //color: UbuntuColors.green

            //Layout.fillWidth: true
        //}
    }

}
