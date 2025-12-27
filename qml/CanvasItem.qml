import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property string kind: "image"
    property url imageSource
    property string titleText: ""
    property string descriptionText: ""
    property string noteText: ""
    property bool autoSize: false
    property bool selected: false
    property bool resizing: false
    property real minimumWidth: 1
    property real minimumHeight: 1
    signal activated()
    signal titleEdited(string text)
    signal descriptionEdited(string text)
    signal noteEdited(string text)
    signal positionRequested(real x, real y)
    signal resizeRequested(real width, real height)
    signal autoSizeApplied()
    signal dragStarted()
    signal dragFinished()

    property real dragStartX: 0
    property real dragStartY: 0
    property real resizeStartWidth: 0
    property real resizeStartHeight: 0
    property real resizePressX: 0
    property real resizePressY: 0

    z: selected ? 2 : 1

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.kind === "note" ? "#111c34" : "#0b1220"
        border.color: root.selected ? "#38bdf8" : "#1e293b"
        border.width: root.selected ? 2 : 1
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
        sourceComponent: root.kind === "note" ? noteContent : imageContent
    }

    Connections {
        target: contentLoader.item
        ignoreUnknownSignals: true
        function onTitleEdited(text) { root.titleEdited(text) }
        function onDescriptionEdited(text) { root.descriptionEdited(text) }
        function onNoteEdited(text) { root.noteEdited(text) }
        function onSizeHintReady(width, height) {
            if (root.autoSize) {
                root.resizeRequested(width, height)
                root.autoSizeApplied()
            }
        }
    }

    DragHandler {
        id: dragHandler
        target: null
        enabled: !root.resizing
        onActiveChanged: {
            if (active) {
                root.dragStartX = root.x
                root.dragStartY = root.y
                root.dragStarted()
            } else {
                root.dragFinished()
            }
        }
        onTranslationChanged: {
            if (active) {
                root.positionRequested(root.dragStartX + translation.x,
                    root.dragStartY + translation.y)
            }
        }
    }

    PinchHandler {
        target: root
        minimumScale: 0.3
        maximumScale: 3.0
        enabled: !root.resizing
    }

    TapHandler {
        onTapped: root.activated()
    }

    Rectangle {
        id: resizeHandle
        width: 14
        height: 14
        radius: 3
        color: "#38bdf8"
        border.color: "#0f172a"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 6
        visible: root.selected

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            onPressed: {
                root.resizeStartWidth = root.width
                root.resizeStartHeight = root.height
                root.resizePressX = mouse.x
                root.resizePressY = mouse.y
                root.resizing = true
                root.dragStarted()
            }
            onPositionChanged: {
                if (!pressed) {
                    return
                }
                var deltaX = mouse.x - root.resizePressX
                var deltaY = mouse.y - root.resizePressY
                var newWidth = Math.max(root.minimumWidth, root.resizeStartWidth + deltaX)
                var newHeight = Math.max(root.minimumHeight, root.resizeStartHeight + deltaY)
                root.resizeRequested(newWidth, newHeight)
            }
            onReleased: {
                root.resizing = false
                root.dragFinished()
            }
        }
    }

    Component {
        id: imageContent
        ImageCardContent {
            imageSource: root.imageSource
            titleText: root.titleText
            descriptionText: root.descriptionText
            autoSize: root.autoSize
            minimumWidth: root.minimumWidth
            minimumHeight: root.minimumHeight
        }
    }

    Component {
        id: noteContent
        NoteCardContent {
            noteText: root.noteText
        }
    }
}
