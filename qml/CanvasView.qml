import QtQuick
import QtQuick.Controls

Flickable {
    id: root
    clip: true
    interactive: false

    property real canvasWidth: 0
    property real canvasHeight: 0
    property real canvasScale: 1.0
    property real minCanvasScale: 0.4
    property real maxCanvasScale: 2.5
    property bool gridEnabled: false
    property int gridSize: 40
    property bool spacePanning: false
    property string selectedId: ""
    property var canvasModel

    signal scaleRequested(real scale)
    signal imagesDropped(var urls, real dropX, real dropY)
    signal clearSelectionRequested()
    signal itemActivated(string uid)
    signal closeRequested(string uid)
    signal collapseRequested(string uid, bool collapsedState)
    signal layoutMetricsReady(int index, real extraWidth, real extraHeight)
    signal displaySizeReady(int index, real displayWidth, real displayHeight)
    signal titleEdited(int index, string text)
    signal descriptionEdited(int index, string text)
    signal positionRequested(int index, real posX, real posY)
    signal resizeRequested(int index, real itemWidth, real itemHeight)
    signal autoSizeApplied(int index)
    signal dragStarted(string uid)
    signal dragFinished()

    property real panStartX: 0
    property real panStartY: 0
    property real panStartContentX: 0
    property real panStartContentY: 0

    contentWidth: canvasRoot.width * root.canvasScale
    contentHeight: canvasRoot.height * root.canvasScale

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AlwaysOff
    }
    ScrollBar.horizontal: ScrollBar {
        policy: ScrollBar.AlwaysOff
    }

    function clampValue(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value))
    }

    function applyContentPosition(x, y, targetScale) {
        var scale = targetScale !== undefined ? targetScale : root.canvasScale
        var maxX = Math.max(0, root.canvasWidth * scale - root.width)
        var maxY = Math.max(0, root.canvasHeight * scale - root.height)
        root.contentX = clampValue(x, 0, maxX)
        root.contentY = clampValue(y, 0, maxY)
    }

    function requestGridPaint() {
        gridOverlay.requestPaint()
    }

    onGridEnabledChanged: requestGridPaint()
    onGridSizeChanged: requestGridPaint()

    WheelHandler {
        target: null
        onWheel: {
            var angle = wheel.angleDelta.y
            if (angle === 0) {
                return
            }
            var oldScale = root.canvasScale
            var factor = angle > 0 ? 1.1 : 0.9
            var newScale = root.clampValue(oldScale * factor,
                root.minCanvasScale, root.maxCanvasScale)
            if (newScale === oldScale) {
                return
            }
            var focusX = (root.contentX + wheel.x) / oldScale
            var focusY = (root.contentY + wheel.y) / oldScale
            root.scaleRequested(newScale)
            root.applyContentPosition(focusX * newScale - wheel.x,
                focusY * newScale - wheel.y, newScale)
            wheel.accepted = true
        }
    }

    Item {
        id: canvasRoot
        width: root.canvasWidth
        height: root.canvasHeight
        transformOrigin: Item.TopLeft
        scale: root.canvasScale

        Rectangle {
            anchors.fill: parent
            color: "#0d1014"
        }

        Canvas {
            id: gridOverlay
            anchors.fill: parent
            visible: root.gridEnabled
            opacity: 0.4

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#1b1f26"
                ctx.lineWidth = 1
                var step = root.gridSize
                if (step <= 0) {
                    return
                }
                for (var x = 0; x <= width; x += step) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }
                for (var y = 0; y <= height; y += step) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        DropArea {
            anchors.fill: parent
            onDropped: {
                if (!drop.hasUrls) {
                    return
                }
                root.imagesDropped(drop.urls, drop.x, drop.y)
            }
        }

        TapHandler {
            onTapped: root.clearSelectionRequested()
        }

        Repeater {
            model: root.canvasModel
            delegate: CanvasItem {
                x: xPos
                y: yPos
                width: itemWidth
                height: itemHeight
                scale: itemScale
                imageRotation: itemRotation
                flipHorizontal: flipX
                flipVertical: flipY
                collapsedState: collapsed
                canvasPanning: root.spacePanning
                imageSource: source
                titleText: title
                descriptionText: description
                autoSize: autoSize
                selected: uid === root.selectedId
                onActivated: root.itemActivated(uid)
                onCloseRequested: root.closeRequested(uid)
                onCollapseRequested: root.collapseRequested(uid, collapsedState)
                onLayoutMetricsReady: root.layoutMetricsReady(index, extraWidth, extraHeight)
                onDisplaySizeReady: root.displaySizeReady(index, width, height)
                onTitleEdited: root.titleEdited(index, text)
                onDescriptionEdited: root.descriptionEdited(index, text)
                onPositionRequested: root.positionRequested(index, x, y)
                onResizeRequested: root.resizeRequested(index, width, height)
                onAutoSizeApplied: root.autoSizeApplied(index)
                onDragStarted: root.dragStarted(uid)
                onDragFinished: root.dragFinished()
            }
        }

        Text {
            visible: root.canvasModel && root.canvasModel.count === 0
            text: "Drop images here to start your board"
            color: "#8b9098"
            font.pixelSize: 16
            anchors.centerIn: parent
        }
    }

    MouseArea {
        id: panOverlay
        anchors.fill: parent
        enabled: root.spacePanning
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        preventStealing: true
        acceptedButtons: Qt.LeftButton
        onPressed: {
            root.panStartX = mouse.x
            root.panStartY = mouse.y
            root.panStartContentX = root.contentX
            root.panStartContentY = root.contentY
        }
        onPositionChanged: {
            if (!pressed) {
                return
            }
            var deltaX = mouse.x - root.panStartX
            var deltaY = mouse.y - root.panStartY
            root.applyContentPosition(root.panStartContentX - deltaX,
                root.panStartContentY - deltaY)
        }
    }
}
