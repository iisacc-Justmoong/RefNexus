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
    property bool flipHorizontal: false
    property bool flipVertical: false
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
    property real resizeStartX: 0
    property real resizeStartY: 0
    property real resizePressSceneX: 0
    property real resizePressSceneY: 0
    property string resizeEdge: ""
    property real edgeHandleSize: 8

    z: selected ? 2 : 1
    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.flipHorizontal ? -1 : 1
        yScale: root.flipVertical ? -1 : 1
    }

    HoverHandler {
        id: hoverHandler
    }

    ToolTip.text: "Click to select. Drag to move. Drag edges to resize."
    ToolTip.delay: 1000
    ToolTip.visible: hoverHandler.hovered

    function beginResize(edge, pressSceneX, pressSceneY) {
        root.resizeStartWidth = root.width
        root.resizeStartHeight = root.height
        root.resizeStartX = root.x
        root.resizeStartY = root.y
        root.resizePressSceneX = pressSceneX
        root.resizePressSceneY = pressSceneY
        root.resizeEdge = edge
        root.resizing = true
        root.dragStarted()
    }

    function updateResize(currentSceneX, currentSceneY) {
        if (!root.resizing) {
            return
        }
        var scaleFactor = root.scale
        if (root.parent && root.parent.scale !== undefined) {
            scaleFactor *= root.parent.scale
        }
        if (scaleFactor === 0) {
            scaleFactor = 1
        }
        var deltaX = (currentSceneX - root.resizePressSceneX) / scaleFactor
        var deltaY = (currentSceneY - root.resizePressSceneY) / scaleFactor
        var newWidth = root.resizeStartWidth
        var newHeight = root.resizeStartHeight
        var newX = root.resizeStartX
        var newY = root.resizeStartY
        if (root.resizeEdge.indexOf("left") >= 0) {
            newWidth = Math.max(root.minimumWidth, root.resizeStartWidth - deltaX)
            var widthDelta = root.resizeStartWidth - newWidth
            newX = root.resizeStartX + widthDelta
        }
        if (root.resizeEdge.indexOf("right") >= 0) {
            newWidth = Math.max(root.minimumWidth, root.resizeStartWidth + deltaX)
        }
        if (root.resizeEdge.indexOf("top") >= 0) {
            newHeight = Math.max(root.minimumHeight, root.resizeStartHeight - deltaY)
            var heightDelta = root.resizeStartHeight - newHeight
            newY = root.resizeStartY + heightDelta
        }
        if (root.resizeEdge.indexOf("bottom") >= 0) {
            newHeight = Math.max(root.minimumHeight, root.resizeStartHeight + deltaY)
        }
        root.resizeRequested(newWidth, newHeight)
        root.positionRequested(newX, newY)
    }

    function endResize() {
        root.resizing = false
        root.dragFinished()
    }

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
                root.beginResize("bottom-right", mouse.sceneX, mouse.sceneY)
            }
            onPositionChanged: {
                root.updateResize(mouse.sceneX, mouse.sceneY)
            }
            onReleased: {
                root.endResize()
            }
        }
    }

    MouseArea {
        id: leftResizeArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.edgeHandleSize
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed: root.beginResize("left", mouse.sceneX, mouse.sceneY)
        onPositionChanged: root.updateResize(mouse.sceneX, mouse.sceneY)
        onReleased: root.endResize()
    }

    MouseArea {
        id: rightResizeArea
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.edgeHandleSize
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        onPressed: root.beginResize("right", mouse.sceneX, mouse.sceneY)
        onPositionChanged: root.updateResize(mouse.sceneX, mouse.sceneY)
        onReleased: root.endResize()
    }

    MouseArea {
        id: topResizeArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.edgeHandleSize
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        onPressed: root.beginResize("top", mouse.sceneX, mouse.sceneY)
        onPositionChanged: root.updateResize(mouse.sceneX, mouse.sceneY)
        onReleased: root.endResize()
    }

    MouseArea {
        id: bottomResizeArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.edgeHandleSize
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        onPressed: root.beginResize("bottom", mouse.sceneX, mouse.sceneY)
        onPositionChanged: root.updateResize(mouse.sceneX, mouse.sceneY)
        onReleased: root.endResize()
    }

    MouseArea {
        id: topLeftResizeArea
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.edgeHandleSize * 1.5
        height: root.edgeHandleSize * 1.5
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.beginResize("top-left", mouse.sceneX, mouse.sceneY)
        onPositionChanged: root.updateResize(mouse.sceneX, mouse.sceneY)
        onReleased: root.endResize()
    }

    MouseArea {
        id: topRightResizeArea
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.edgeHandleSize * 1.5
        height: root.edgeHandleSize * 1.5
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.beginResize("top-right", mouse.sceneX, mouse.sceneY)
        onPositionChanged: root.updateResize(mouse.sceneX, mouse.sceneY)
        onReleased: root.endResize()
    }

    MouseArea {
        id: bottomLeftResizeArea
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.edgeHandleSize * 1.5
        height: root.edgeHandleSize * 1.5
        hoverEnabled: true
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.beginResize("bottom-left", mouse.sceneX, mouse.sceneY)
        onPositionChanged: root.updateResize(mouse.sceneX, mouse.sceneY)
        onReleased: root.endResize()
    }

    MouseArea {
        id: bottomRightResizeArea
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: root.edgeHandleSize * 1.5
        height: root.edgeHandleSize * 1.5
        hoverEnabled: true
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.beginResize("bottom-right", mouse.sceneX, mouse.sceneY)
        onPositionChanged: root.updateResize(mouse.sceneX, mouse.sceneY)
        onReleased: root.endResize()
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
