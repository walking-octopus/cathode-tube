import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

Page {
    id: picker
    property var activeTransfer

    property string url
    property string handler
    property string contentType

    signal cancel()
    signal imported(string fileUrl)

    header: PageHeader {
        title: i18n.tr("Share")

        leadingActionBar.actions: Action {
            iconName: "back"
            text: i18n.tr("Back")

            onTriggered: {
                pStack.removePages(picker);
                pStack.push(Qt.resolvedUrl("./HomePage.qml"));
            }
        }
    }

    ContentPeerPicker {
        anchors {
            fill: parent;
            topMargin: picker.header.height
        }

        visible: parent.visible
        showTitle: false  //otherwise a second header will be shown
        contentType: ContentType.Links
        handler: ContentHandler.Share

        onPeerSelected: {
            picker.activeTransfer = peer.request()
            picker.activeTransfer.stateChanged.connect(function() {
                if (picker.activeTransfer.state === ContentTransfer.InProgress) {
                    console.log("Share in progress: " + url);
                    picker.activeTransfer.items = [ resultComponent.createObject(parent, {"url": url}) ];
                    picker.activeTransfer.state = ContentTransfer.Charged;
                    pStack.removePages(picker);
                    pStack.push(Qt.resolvedUrl("./HomePage.qml"));
                }
            })
        }

        onCancelPressed: {
            pStack.removePages(picker);
            pStack.push(Qt.resolvedUrl("./HomePage.qml"));
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: picker.activeTransfer
    }

    Component {
        id: resultComponent

        ContentItem {}
    }
}
