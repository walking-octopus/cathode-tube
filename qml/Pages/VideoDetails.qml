import QtQuick 2.12
import Ubuntu.Components 1.3

Page {
    property string video_id: ''
    property string video_title: i18n.tr('No media')

    width: bottomEdge.width
    height: bottomEdge.height

    header: PageHeader {
        id: header
        title: video_title
    }

    Label {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        text: video_id
        font.pixelSize: units.gu(3)

        verticalAlignment: Label.AlignVCenter
        horizontalAlignment: Label.AlignHCenter
    }
}