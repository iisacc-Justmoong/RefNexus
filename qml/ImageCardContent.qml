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
    property color surfaceColor: "#121826"
    property color surfaceActive: "#1b2534"
    property color borderColor: "#243145"
    property color accentColor: "#5c7cfa"
    property color textPrimary: "#e6edf5"
    property color textSecondary: "#9aa6b2"
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
            color: root.textPrimary
            placeholderTextColor: root.textSecondary
            font.pixelSize: 13
            leftPadding: 10
            rightPadding: 10
            topPadding: 8
            bottomPadding: 8
            implicitHeight: 34
            background: Rectangle {
                radius: 8
                color: titleField.activeFocus ? root.surfaceActive : root.surfaceColor
                border.color: titleField.activeFocus ? root.accentColor : root.borderColor
            }
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
            mipmap: true
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
            color: root.textPrimary
            placeholderTextColor: root.textSecondary
            font.pixelSize: 12
            leftPadding: 10
            rightPadding: 10
            topPadding: 8
            bottomPadding: 8
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(descriptionField.contentHeight + 12,
                descriptionField.font.pixelSize + 12)
            background: Rectangle {
                color: descriptionField.activeFocus
                    ? root.surfaceActive
                    : root.surfaceColor
                radius: 8
                border.color: descriptionField.activeFocus
                    ? root.accentColor
                    : root.borderColor
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
