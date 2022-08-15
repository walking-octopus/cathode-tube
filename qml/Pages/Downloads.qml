import QtQuick 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import Qt.labs.folderlistmodel 1.0

Page {
    id: downloads

    header: PageHeader {
        id: header
        title: i18n.tr("Downloaded videos")
        flickable: scrollView.flickableItem

        leadingActionBar.actions: Action {
            iconName: "navigation-menu"
            text: i18n.tr("Menu")
            onTriggered: pStack.removePages(downloads)
            visible: !primaryPage.visible
        }
    }

    FolderListModel {
        id: videoList
        folder: `file:///home/phablet/.local/share/${root.applicationName}` // FIXME: This may break with custom usernames
        showDirs: false
        sortField: FolderListModel.Size
        showOnlyReadable: true
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
    
        ListView {
            id: view
            anchors.fill: parent

            model: videoList
            delegate: ListItem {
                height: modelLayout.height + (divider.visible ? divider.height : 0)
                trailingActions: ListItemActions {
                    actions: [
                        // TODO: Implement video deletion
                        Action {
                            iconName: "delete"
                        }
                    ]
                }

                onClicked: Qt.openUrlExternally(fileURL.replace("file://", "video://"))
                // TODO: Add ContentHub support for opening offline videos

                ListItemLayout {
                    id: modelLayout
                    anchors.centerIn: parent

                    title.text: fileBaseName
                    title.maximumLineCount: 2
                    title.wrapMode: Text.Wrap

                    subtitle.text: {
                        function formatBytes(bytes, decimals = 2) {
                            if (bytes === 0) return 'Empty';
                        
                            const k = 1024;
                            const dm = decimals < 0 ? 0 : decimals;
                            const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

                            const i = Math.floor(Math.log(bytes) / Math.log(k));

                            return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
                        }

                        function formatDate(dateString) {
                            const date = new Date(dateString);
                            return [date.getDate(), date.getMonth() + 1, date.getFullYear()].join("/")
                        }

                        return [formatDate(fileModified), formatBytes(fileSize)].filter(element => !!element).join(' | ')
                    }

                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: header.height
                anchors.margins: units.gu(2)
                spacing: units.gu(2)
        
                visible: view.count === 0 && !videoList.loading
        
                Item { Layout.fillHeight: true; Layout.fillWidth: true }
        
                UbuntuShape {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: units.gu(16); Layout.preferredHeight: width
                    Layout.bottomMargin: units.gu(2)
        
                    radius: "medium"
                    source: Image {
                        source: Qt.resolvedUrl("../../assets/logo.png")
                    }
                }
        
                Label {
                    text: i18n.tr("Downloaded videos will appear here")
                    textSize: Label.Large
                    font.bold: true

                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignCenter
                }
        
                Label {
                    text: i18n.tr("You'll need to access the files externally for offline playback, since the app requires an internet connection.")

                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignCenter
                }
                
                Label {
                    text: i18n.tr("They're stored at `~/.local/share/cathode-tube.walking-octopus`.")
                    textSize: Label.Small

                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignCenter
                }
        
                Item { Layout.fillHeight: true; }
            }
        }
    }
}