import QtQuick 2.12
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: downloadDialog
    
    Dialog {
        id: dialog
        property Item video

        title: `${i18n.tr("Downloading")} «${video.video_title}»...`

        ProgressBar {
            minimumValue: 0; maximumValue: 100

            value: {
                if (video.progress == 100)
                    PopupUtils.close(dialog);

                return video.progress;
            }
        }
    }
}
