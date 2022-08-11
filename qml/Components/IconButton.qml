import QtQuick 2.12
import Ubuntu.Components 1.3

Column {
    id: layout

    property string iconName
    property string text
    signal triggered()

    spacing: units.gu(0.8)

    Icon {
        name: layout.iconName
        width: units.gu(3.5); height: width
        anchors.horizontalCenter: parent.horizontalCenter
    }
    
    Label {
        text: layout.text
        textSize: Label.Small
        // font.weight: Font.DemiBold
        anchors.horizontalCenter: parent.horizontalCenter
    }

    TapHandler {
        onTapped: layout.triggered()
    }
}