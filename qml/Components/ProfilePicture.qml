import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

UbuntuShape {
    id: avatarRect

    property var name: ""
    property var picture_url: ""
    signal clicked()

    width: units.gu(5); height: width
    z: 1

    relativeRadius: 0.75
    aspect: UbuntuShape.Flat
    backgroundMode: UbuntuShape.VerticalGradient

    function stringToColor(str) {
        // if ( str.indexOf("@") != -1 ) str = getChatAvatarById ( str )
        var number = 0
        for( var i=0; i<str.length; i++ ) number += str.charCodeAt(i)
        number = (number % 10) / 10
        return Qt.hsla( number, 1, 0.7, 1 )
    }

    function stringToDarkColor(str) {
        if ( str === null ) return Qt.hsla( 0, 0.8, 0.35, 1 )
        // if ( str.indexOf("@") != -1 ) str = getChatAvatarById ( str )
        var number = 0
        for( var i=0; i<str.length; i++ ) number += str.charCodeAt(i)
        number = (number % 10) / 10
        return Qt.hsla( number, 1, 0.35, 1 )
    }

    backgroundColor: avatar.status === Image.Ready ? theme.palette.normal.background : stringToDarkColor(name)
    secondaryBackgroundColor: avatar.status === Image.Ready ? theme.palette.normal.background : stringToColor(name)

    MouseArea {
        anchors.fill: parent
        onClicked: clicked()
        onPressed: parent.aspect = UbuntuShape.Inset
        onReleased: parent.aspect = UbuntuShape.Flat
    }

    source: Image {
        id: avatar
        source: picture_url
        anchors.fill: parent
        visible: status == Image.Ready

        cache: true
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
    }

    Label {
        anchors.centerIn: parent
        z: 10
        visible: picture_url === "" || avatar.status != Image.Ready

        text: name.slice(0, 2)
        color: "white"
        textSize: parent.width > units.gu(6) ? Label.XLarge : ( parent.width > units.gu(4) ? Label.Large : Label.Small )
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: units.gu(4)
        visible: false
    }
}
