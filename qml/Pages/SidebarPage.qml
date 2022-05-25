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
            onClicked: onTriggered

            ListItemLayout {
                anchors.centerIn: parent

                Icon {
                    width: units.gu(2); height: width
                    name: iconName
                    SlotsLayout.position: SlotsLayout.First
                }

                title.text: text

                Icon {
                    width: units.gu(2); height: width
                    name: "go-next"
                    SlotsLayout.position: SlotsLayout.Last
                }
            }
        }
    }
}