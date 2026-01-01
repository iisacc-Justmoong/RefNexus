import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    clip: true
    property url imageSource
    property string titleText: ""
    property string descriptionText: ""
    property bool autoSize: false
    property bool selected: false
    property bool resizing: false
    property bool flipHorizontal: false
    property bool flipVertical: false
    property bool collapsedState: false
    property real imageRotation: 0
    property real dragBarHeight: 30
    property bool canvasPanning: false
    property real minimumWidth: 1
    property real minimumHeight: 1
    property color surfaceColor: "#121826"
    property color surfaceElevated: "#151d2b"
    property color surfaceHover: "#1b2534"
    property color borderColor: "#243145"
    property color borderActive: "#5c7cfa"
    property color textPrimary: "#e6edf5"
    property color textSecondary: "#9aa6b2"
    property color gripColor: "#2f3c4f"
    signal activated()
    signal titleEdited(string text)
    signal descriptionEdited(string text)
    signal positionRequested(real x, real y)
    signal resizeRequested(real width, real height)
    signal autoSizeApplied()
    signal layoutMetricsReady(real extraWidth, real extraHeight)
    signal displaySizeReady(real width, real height)
    signal dragStarted()
    signal dragFinished()
    signal closeRequested()
    signal collapseRequested(bool collapsed)

    property real dragStartX: 0
    property real dragStartY: 0
    property real dragPressSceneX: 0
    property real dragPressSceneY: 0
    property real resizeStartWidth: 0
    property real resizeStartHeight: 0
    property real resizeStartX: 0
    property real resizeStartY: 0
    property real resizePressSceneX: 0
    property real resizePressSceneY: 0
    property string resizeEdge: ""
    property real edgeHandleSize: 12
    property real edgeGrabPadding: 8
    property bool edgeHovering: leftResizeArea.containsMouse
        || rightResizeArea.containsMouse
        || topResizeArea.containsMouse
        || bottomResizeArea.containsMouse
        || topLeftResizeArea.containsMouse
        || topRightResizeArea.containsMouse
        || bottomLeftResizeArea.containsMouse
        || bottomRightResizeArea.containsMouse
        || resizeHandleMouse.containsMouse

    z: selected ? 2 : 1

    HoverHandler {
        id: hoverHandler
    }

    ToolTip.text: "Click to select. Drag to move. Drag edges to resize."
    ToolTip.delay: 1000
    ToolTip.visible: hoverHandler.hovered

    onSelectedChanged: {
        if (!selected && contentLoader.item && contentLoader.item.clearEditorFocus) {
            contentLoader.item.clearEditorFocus()
        }
    }

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

    function scenePoint(mouseArea, mouse) {
        var point = mouseArea.mapToItem(null, mouse.x, mouse.y)
        return { x: point.x, y: point.y }
    }

    function beginMove(pressSceneX, pressSceneY) {
        root.dragStartX = root.x
        root.dragStartY = root.y
        root.dragPressSceneX = pressSceneX
        root.dragPressSceneY = pressSceneY
        root.dragStarted()
    }

    function updateMove(currentSceneX, currentSceneY) {
        var scaleFactor = root.scale
        if (root.parent && root.parent.scale !== undefined) {
            scaleFactor *= root.parent.scale
        }
        if (scaleFactor === 0) {
            scaleFactor = 1
        }
        var deltaX = (currentSceneX - root.dragPressSceneX) / scaleFactor
        var deltaY = (currentSceneY - root.dragPressSceneY) / scaleFactor
        root.positionRequested(root.dragStartX + deltaX, root.dragStartY + deltaY)
    }

    function endMove() {
        root.dragFinished()
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
        radius: 14
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: root.selected ? "#16223a" : "#131a26"
            }
            GradientStop { position: 1.0; color: "#0f141d" }
        }
        border.color: root.selected ? root.borderActive : root.borderColor
        border.width: root.selected ? 2 : 1
    }

    Item {
        id: contentContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: dragBar.bottom
        anchors.bottom: parent.bottom
        visible: !root.collapsedState

        Loader {
            id: contentLoader
            anchors.fill: parent
            sourceComponent: imageContent
        }
    }

    Connections {
        target: contentLoader.item
        ignoreUnknownSignals: true
        function onTitleEdited(text) { root.titleEdited(text) }
        function onDescriptionEdited(text) { root.descriptionEdited(text) }
        function onSizeHintReady(width, height) {
            if (root.autoSize) {
                root.resizeRequested(width, height)
                root.autoSizeApplied()
            }
        }
        function onLayoutMetricsReady(extraWidth, extraHeight) {
            root.layoutMetricsReady(extraWidth, extraHeight + root.dragBarHeight)
        }
        function onDisplaySizeReady(width, height) {
            root.displaySizeReady(width, height)
        }
    }

    PinchHandler {
        target: root
        minimumScale: 0.3
        maximumScale: 3.0
        enabled: !root.resizing && !root.canvasPanning
    }

    TapHandler {
        onTapped: root.activated()
    }

    Rectangle {
        id: dragBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.dragBarHeight
        radius: 12
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.surfaceElevated }
            GradientStop { position: 1.0; color: "#111824" }
        }
        border.color: root.selected ? root.borderActive : root.borderColor
        border.width: 1
        z: 6

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            spacing: 6
            z: 2

            ToolButton {
                id: closeButton
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-close-dark.svg"
                icon.width: 10
                icon.height: 10
                hoverEnabled: true
                implicitWidth: 18
                implicitHeight: 18
                onClicked: root.closeRequested()
                ToolTip.text: "Close card"
                ToolTip.delay: 1000
                ToolTip.visible: hovered

                background: Rectangle {
                    radius: 8
                    color: closeButton.down
                        ? "#2a3a54"
                        : (closeButton.hovered ? "#1f2a3a" : "#18202d")
                    border.color: "#1d2836"
                }
            }

            ToolButton {
                id: collapseButton
                display: AbstractButton.IconOnly
                icon.source: root.collapsedState
                    ? "qrc:/qt/qml/RefNexus/resources/icon-chevron-right-dark.svg"
                    : "qrc:/qt/qml/RefNexus/resources/icon-chevron-down-dark.svg"
                icon.width: 10
                icon.height: 10
                hoverEnabled: true
                implicitWidth: 18
                implicitHeight: 18
                onClicked: root.collapseRequested(!root.collapsedState)
                ToolTip.text: root.collapsedState ? "Expand card" : "Collapse card"
                ToolTip.delay: 1000
                ToolTip.visible: hovered

                background: Rectangle {
                    radius: 8
                    color: collapseButton.down
                        ? "#2a3a54"
                        : (collapseButton.hovered ? "#1f2a3a" : "#1a2232")
                    border.color: "#1d2836"
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 36
            height: 4
            radius: 2
            color: root.gripColor
            opacity: 0.7
            z: 1
        }

        Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 44
            anchors.rightMargin: 8
            text: root.titleText.trim().length > 0
                ? root.titleText
                : "Image"
            color: root.textPrimary
            font.pixelSize: 12
            font.weight: Font.Medium
            elide: Text.ElideRight
            visible: root.collapsedState
            z: 1
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            z: 0
            enabled: !root.canvasPanning
            onPressed: function(mouse) {
                root.activated()
                var point = scenePoint(dragArea, mouse)
                root.beginMove(point.x, point.y)
            }
            onPositionChanged: function(mouse) {
                if (!pressed) {
                    return
                }
                var point = scenePoint(dragArea, mouse)
                root.updateMove(point.x, point.y)
            }
            onReleased: function(mouse) {
                root.endMove()
            }
        }
    }

    Rectangle {
        id: resizeHandle
        width: 14
        height: 14
        radius: 4
        color: root.selected ? root.borderActive : "#3a475c"
        border.color: "#0b0f14"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 6
        visible: root.selected && !root.collapsedState

        MouseArea {
            id: resizeHandleMouse
            anchors.fill: parent
            enabled: !root.collapsedState
            cursorShape: Qt.SizeFDiagCursor
            preventStealing: true
            onPressed: function(mouse) {
                var point = scenePoint(resizeHandleMouse, mouse)
                root.beginResize("bottom-right", point.x, point.y)
            }
            onPositionChanged: function(mouse) {
                var point = scenePoint(resizeHandleMouse, mouse)
                root.updateResize(point.x, point.y)
            }
            onReleased: function(mouse) {
                root.endResize()
            }
        }
    }

    MouseArea {
        id: leftResizeArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.edgeHandleSize + root.edgeGrabPadding
        anchors.leftMargin: -root.edgeGrabPadding / 2
        anchors.topMargin: -root.edgeGrabPadding / 2
        anchors.bottomMargin: -root.edgeGrabPadding / 2
        enabled: !root.collapsedState && !root.canvasPanning
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.SizeHorCursor
        z: 4
        onPressed: function(mouse) {
            var point = scenePoint(leftResizeArea, mouse)
            root.beginResize("left", point.x, point.y)
        }
        onPositionChanged: function(mouse) {
            var point = scenePoint(leftResizeArea, mouse)
            root.updateResize(point.x, point.y)
        }
        onReleased: function(mouse) {
            root.endResize()
        }
    }

    MouseArea {
        id: rightResizeArea
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.edgeHandleSize + root.edgeGrabPadding
        anchors.rightMargin: -root.edgeGrabPadding / 2
        anchors.topMargin: -root.edgeGrabPadding / 2
        anchors.bottomMargin: -root.edgeGrabPadding / 2
        enabled: !root.collapsedState && !root.canvasPanning
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.SizeHorCursor
        z: 4
        onPressed: function(mouse) {
            var point = scenePoint(rightResizeArea, mouse)
            root.beginResize("right", point.x, point.y)
        }
        onPositionChanged: function(mouse) {
            var point = scenePoint(rightResizeArea, mouse)
            root.updateResize(point.x, point.y)
        }
        onReleased: function(mouse) {
            root.endResize()
        }
    }

    MouseArea {
        id: topResizeArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.edgeHandleSize + root.edgeGrabPadding
        anchors.leftMargin: -root.edgeGrabPadding / 2
        anchors.rightMargin: -root.edgeGrabPadding / 2
        anchors.topMargin: -root.edgeGrabPadding / 2
        enabled: !root.collapsedState && !root.canvasPanning
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.SizeVerCursor
        z: 4
        onPressed: function(mouse) {
            var point = scenePoint(topResizeArea, mouse)
            root.beginResize("top", point.x, point.y)
        }
        onPositionChanged: function(mouse) {
            var point = scenePoint(topResizeArea, mouse)
            root.updateResize(point.x, point.y)
        }
        onReleased: function(mouse) {
            root.endResize()
        }
    }

    MouseArea {
        id: bottomResizeArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.edgeHandleSize + root.edgeGrabPadding
        anchors.leftMargin: -root.edgeGrabPadding / 2
        anchors.rightMargin: -root.edgeGrabPadding / 2
        anchors.bottomMargin: -root.edgeGrabPadding / 2
        enabled: !root.collapsedState && !root.canvasPanning
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.SizeVerCursor
        z: 4
        onPressed: function(mouse) {
            var point = scenePoint(bottomResizeArea, mouse)
            root.beginResize("bottom", point.x, point.y)
        }
        onPositionChanged: function(mouse) {
            var point = scenePoint(bottomResizeArea, mouse)
            root.updateResize(point.x, point.y)
        }
        onReleased: function(mouse) {
            root.endResize()
        }
    }

    MouseArea {
        id: topLeftResizeArea
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.edgeHandleSize * 2 + root.edgeGrabPadding
        height: root.edgeHandleSize * 2 + root.edgeGrabPadding
        anchors.leftMargin: -root.edgeGrabPadding / 2
        anchors.topMargin: -root.edgeGrabPadding / 2
        enabled: !root.collapsedState && !root.canvasPanning
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.SizeFDiagCursor
        z: 5
        onPressed: function(mouse) {
            var point = scenePoint(topLeftResizeArea, mouse)
            root.beginResize("top-left", point.x, point.y)
        }
        onPositionChanged: function(mouse) {
            var point = scenePoint(topLeftResizeArea, mouse)
            root.updateResize(point.x, point.y)
        }
        onReleased: function(mouse) {
            root.endResize()
        }
    }

    MouseArea {
        id: topRightResizeArea
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.edgeHandleSize * 2 + root.edgeGrabPadding
        height: root.edgeHandleSize * 2 + root.edgeGrabPadding
        anchors.rightMargin: -root.edgeGrabPadding / 2
        anchors.topMargin: -root.edgeGrabPadding / 2
        enabled: !root.collapsedState && !root.canvasPanning
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.SizeBDiagCursor
        z: 5
        onPressed: function(mouse) {
            var point = scenePoint(topRightResizeArea, mouse)
            root.beginResize("top-right", point.x, point.y)
        }
        onPositionChanged: function(mouse) {
            var point = scenePoint(topRightResizeArea, mouse)
            root.updateResize(point.x, point.y)
        }
        onReleased: function(mouse) {
            root.endResize()
        }
    }

    MouseArea {
        id: bottomLeftResizeArea
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.edgeHandleSize * 2 + root.edgeGrabPadding
        height: root.edgeHandleSize * 2 + root.edgeGrabPadding
        anchors.leftMargin: -root.edgeGrabPadding / 2
        anchors.bottomMargin: -root.edgeGrabPadding / 2
        enabled: !root.collapsedState && !root.canvasPanning
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.SizeBDiagCursor
        z: 5
        onPressed: function(mouse) {
            var point = scenePoint(bottomLeftResizeArea, mouse)
            root.beginResize("bottom-left", point.x, point.y)
        }
        onPositionChanged: function(mouse) {
            var point = scenePoint(bottomLeftResizeArea, mouse)
            root.updateResize(point.x, point.y)
        }
        onReleased: function(mouse) {
            root.endResize()
        }
    }

    MouseArea {
        id: bottomRightResizeArea
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: root.edgeHandleSize * 2 + root.edgeGrabPadding
        height: root.edgeHandleSize * 2 + root.edgeGrabPadding
        anchors.rightMargin: -root.edgeGrabPadding / 2
        anchors.bottomMargin: -root.edgeGrabPadding / 2
        enabled: !root.collapsedState && !root.canvasPanning
        hoverEnabled: true
        preventStealing: true
        cursorShape: Qt.SizeFDiagCursor
        z: 5
        onPressed: function(mouse) {
            var point = scenePoint(bottomRightResizeArea, mouse)
            root.beginResize("bottom-right", point.x, point.y)
        }
        onPositionChanged: function(mouse) {
            var point = scenePoint(bottomRightResizeArea, mouse)
            root.updateResize(point.x, point.y)
        }
        onReleased: function(mouse) {
            root.endResize()
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
            flipHorizontal: root.flipHorizontal
            flipVertical: root.flipVertical
            rotationDegrees: root.imageRotation
        }
    }
}
