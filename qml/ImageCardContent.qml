import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property url imageSource
    property string titleText: ""
    property string descriptionText: ""
    property bool autoSize: false
    property bool flipHorizontal: false
    property bool flipVertical: false
    property real rotationDegrees: 0
    property int layoutMargin: 8
    property int layoutSpacing: 6
    property real minimumWidth: 1
    property real minimumHeight: 1
    signal titleEdited(string text)
    signal descriptionEdited(string text)
    signal sizeHintReady(real width, real height)
    signal layoutMetricsReady(real extraWidth, real extraHeight)
    signal displaySizeReady(real width, real height)
    property bool metricsQueued: false

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: root.layoutMargin
        spacing: root.layoutSpacing

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
            onActiveFocusChanged: {
                if (!activeFocus) {
                    root.titleEdited(text)
                }
            }
            onHeightChanged: root.requestMetrics()
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
            visible: source !== ""
            rotation: root.rotationDegrees
            transformOrigin: Item.Center
            transform: Scale {
                origin.x: imagePreview.width / 2
                origin.y: imagePreview.height / 2
                xScale: root.flipHorizontal ? -1 : 1
                yScale: root.flipVertical ? -1 : 1
            }
            onPaintedWidthChanged: root.emitDisplaySize()
            onPaintedHeightChanged: root.emitDisplaySize()
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
                root.emitDisplaySize()
            }
        }

        TextArea {
            id: descriptionField
            placeholderText: "Description"
            text: root.descriptionText
            wrapMode: TextEdit.WordWrap
            color: "#d7dbe0"
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(descriptionField.contentHeight + 12,
                descriptionField.font.pixelSize + 12)
            background: Rectangle {
                color: "#0f1115"
                radius: 6
            }
            onTextChanged: {
                if (activeFocus) {
                    root.descriptionEdited(text)
                }
            }
            onActiveFocusChanged: {
                if (!activeFocus) {
                    root.descriptionEdited(text)
                }
            }
            onHeightChanged: root.requestMetrics()
            onContentHeightChanged: root.requestMetrics()
        }

        Binding {
            target: descriptionField
            property: "text"
            value: root.descriptionText
            when: !descriptionField.activeFocus
        }
    }

    function clearEditorFocus() {
        titleField.focus = false
        descriptionField.focus = false
    }

    function requestMetrics() {
        if (metricsQueued) {
            return
        }
        metricsQueued = true
        Qt.callLater(function() {
            metricsQueued = false
            root.emitMetrics()
        })
    }

    function emitMetrics() {
        var titleHeight = titleField.height > 0 ? titleField.height : titleField.implicitHeight
        var descriptionHeight = descriptionField.height > 0
            ? descriptionField.height
            : descriptionField.implicitHeight
        var extraHeight = root.layoutMargin * 2
            + root.layoutSpacing * 2
            + titleHeight
            + descriptionHeight
        var extraWidth = root.layoutMargin * 2
        root.layoutMetricsReady(extraWidth, extraHeight)
    }

    function emitDisplaySize() {
        if (!imagePreview.visible) {
            return
        }
        if (imagePreview.paintedWidth <= 0 || imagePreview.paintedHeight <= 0) {
            return
        }
        root.displaySizeReady(imagePreview.paintedWidth, imagePreview.paintedHeight)
    }

    Component.onCompleted: emitMetrics()
}
