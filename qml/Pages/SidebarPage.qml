import QtQuick 2.9
import Ubuntu.Components 1.3

Page {
    id: sidebarPage

    property bool isEnabled: false
    
    header: PageHeader {
        id: header
        title: i18n.tr("Cathode")

        automaticHeight: false
    }

    ListModel {
        id: menuModel

        // A workaround to allow translations
        Component.onCompleted: {
            append({
                iconName: "go-home",
                text: i18n.tr("Home"),
                pagePath: "./HomePage.qml",
            });
            append({
                iconName: "help",
                text: i18n.tr("Placeholder"),
                pagePath: "",
            });
        }
    }

    ListView {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        model: menuModel
        enabled: isEnabled

        delegate: ListItem {
            onClicked: pStack.push(Qt.resolvedUrl(pagePath))

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