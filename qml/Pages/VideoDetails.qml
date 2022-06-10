import QtQuick 2.12
import Ubuntu.Components 1.3

Page {
    width: bottomEdge.width
    height: bottomEdge.height

    header: PageHeader {
        id: header
        title: "Player"
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: UbuntuColors.green
    }
}