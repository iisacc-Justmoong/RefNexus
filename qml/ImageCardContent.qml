import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property url imageSource
    property string titleText: ""
    property string descriptionText: ""
    property bool autoSize: false
    property real minimumWidth: 1
    property real minimumHeight: 1
    signal titleEdited(string text)
    signal descriptionEdited(string text)
    signal sizeHintReady(real width, real height)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        TextField {
            id: titleField
            placeholderText: "Title"
            Layout.fillWidth: true
            text: root.titleText
            onTextChanged: {
                if (activeFocus) {
                    root.titleEdited(text)
                }
            }
        }

        Binding {
            target: titleField
            property: "text"
            value: root.titleText
            when: !titleField.activeFocus
        }

        Image {
            id: imagePreview
            source: root.imageSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            onStatusChanged: {
                if (status === Image.Ready && root.autoSize) {
                    var imageWidth = imagePreview.sourceSize.width
                    var imageHeight = imagePreview.sourceSize.height
                    if (imageWidth <= 0 || imageHeight <= 0) {
                        imageWidth = imagePreview.implicitWidth
                        imageHeight = imagePreview.implicitHeight
                    }
                    var extraWidth = 16
                    var extraHeight = titleField.implicitHeight
                        + descriptionField.implicitHeight
                        + 22
                    var targetWidth = Math.max(root.minimumWidth, imageWidth + extraWidth)
                    var targetHeight = Math.max(root.minimumHeight, imageHeight + extraHeight)
                    root.sizeHintReady(targetWidth, targetHeight)
                }
            }
        }

        TextArea {
            id: descriptionField
            placeholderText: "Description"
            text: root.descriptionText
            wrapMode: TextEdit.WordWrap
            color: "#e2e8f0"
            Layout.fillWidth: true
            Layout.preferredHeight: descriptionField.font.pixelSize + 12
            background: Rectangle {
                color: "#0f172a"
                radius: 6
            }
            onTextChanged: {
                if (activeFocus) {
                    root.descriptionEdited(text)
                }
            }
        }

        Binding {
            target: descriptionField
            property: "text"
            value: root.descriptionText
            when: !descriptionField.activeFocus
        }
    }
}
