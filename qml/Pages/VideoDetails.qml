import QtQuick 2.12
import Ubuntu.Components 1.3

Page {
    property string video_id

    width: bottomEdge.width
    height: bottomEdge.height

    header: PageHeader {
        id: header
        title: "Player"
    }

    Label {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        text: i18n.tr('Placeholder')
        font.pixelSize: units.gu(3)

        verticalAlignment: Label.AlignVCenter
        horizontalAlignment: Label.AlignHCenter
    }
}