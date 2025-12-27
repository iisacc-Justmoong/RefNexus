import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    color: "#0f172a"

    property bool alwaysOnTop: false
    property int selectedIndex: -1
    property real canvasWidth: 4200
    property real canvasHeight: 2800
    property int baseFlags: 0
    property bool updatingFlags: false
    property int activeCardInteractions: 0

    ListModel {
        id: canvasModel
    }

    function addImage(url, dropX, dropY) {
        var urlString = url.toString()
        var baseName = urlString.substring(urlString.lastIndexOf("/") + 1)
        canvasModel.append({
            itemType: "image",
            title: decodeURIComponent(baseName),
            description: "",
            noteText: "",
            source: url,
            autoSize: true,
            xPos: dropX,
            yPos: dropY,
            itemWidth: 320,
            itemHeight: 240,
            itemScale: 1.0,
            itemRotation: 0
        })
    }

    function centerPosition() {
        var centerX = canvasView.contentX + canvasView.width / 2
        var centerY = canvasView.contentY + canvasView.height / 2
        return { x: centerX, y: centerY }
    }

    function addNote() {
        var center = centerPosition()
        canvasModel.append({
            itemType: "note",
            title: "",
            description: "",
            noteText: "New note",
            source: "",
            autoSize: false,
            xPos: center.x - 140,
            yPos: center.y - 80,
            itemWidth: 280,
            itemHeight: 160,
            itemScale: 1.0,
            itemRotation: 0
        })
    }

    function updateWindowFlags() {
        if (updatingFlags) {
            return
        }
        updatingFlags = true
        var newFlags = baseFlags
        if (alwaysOnTop) {
            newFlags |= Qt.WindowStaysOnTopHint
        }
        flags = newFlags
        if (alwaysOnTop) {
            raise()
            requestActivate()
        }
        updatingFlags = false
    }

    Component.onCompleted: {
        baseFlags = flags
        updateWindowFlags()
    }

    function beginCardInteraction() {
        activeCardInteractions += 1
    }

    function endCardInteraction() {
        activeCardInteractions = Math.max(0, activeCardInteractions - 1)
    }

    onAlwaysOnTopChanged: updateWindowFlags()

    header: ToolBar {
        background: Rectangle {
            color: "#0b1220"
            border.color: "#1e293b"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10

            ToolButton {
                text: "Add Image"
                onClicked: imageDialog.open()
                Layout.leftMargin: 12
            }

            ToolButton {
                text: "Add Note"
                onClicked: root.addNote()
            }

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                text: "Top"
                checkable: true
                checked: root.alwaysOnTop
                onToggled: root.alwaysOnTop = checked
            }

        }
    }

    FileDialog {
        id: imageDialog
        title: "Add Images"
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp *.gif *.tif *.tiff)"]
        onAccepted: {
            var center = root.centerPosition()
            for (var i = 0; i < selectedFiles.length; i += 1) {
                root.addImage(selectedFiles[i], center.x + i * 24, center.y + i * 24)
            }
        }
    }

    Flickable {
        id: canvasView
        anchors.fill: parent
        contentWidth: canvasRoot.width
        contentHeight: canvasRoot.height
        interactive: root.activeCardInteractions === 0
        clip: true
        ScrollBar.vertical: ScrollBar { }
        ScrollBar.horizontal: ScrollBar { }

        Item {
            id: canvasRoot
            width: root.canvasWidth
            height: root.canvasHeight
            transformOrigin: Item.TopLeft

            Rectangle {
                anchors.fill: parent
                color: "#0b1220"
            }

            DropArea {
                anchors.fill: parent
                onDropped: {
                    if (!drop.hasUrls) {
                        return
                    }
                    var baseX = drop.x
                    var baseY = drop.y
                    for (var i = 0; i < drop.urls.length; i += 1) {
                        root.addImage(drop.urls[i], baseX + i * 24, baseY + i * 24)
                    }
                }
            }

            TapHandler {
                onTapped: root.selectedIndex = -1
            }

            Repeater {
                model: canvasModel
                delegate: CanvasItem {
                    x: xPos
                    y: yPos
                    width: itemWidth
                    height: itemHeight
                    scale: itemScale
                    rotation: itemRotation
                    kind: itemType
                    imageSource: source
                    titleText: title
                    descriptionText: description
                    noteText: noteText
                    autoSize: autoSize
                    selected: index === root.selectedIndex
                    onActivated: root.selectedIndex = index
                    onTitleEdited: canvasModel.setProperty(index, "title", text)
                    onDescriptionEdited: canvasModel.setProperty(index, "description", text)
                    onNoteEdited: canvasModel.setProperty(index, "noteText", text)
                    onPositionRequested: {
                        canvasModel.setProperty(index, "xPos", x)
                        canvasModel.setProperty(index, "yPos", y)
                    }
                    onResizeRequested: {
                        canvasModel.setProperty(index, "itemWidth", width)
                        canvasModel.setProperty(index, "itemHeight", height)
                    }
                    onAutoSizeApplied: canvasModel.setProperty(index, "autoSize", false)
                    onDragStarted: root.beginCardInteraction()
                    onDragFinished: root.endCardInteraction()
                }
            }

            Text {
                visible: canvasModel.count === 0
                text: "Drop images here to start your board"
                color: "#94a3b8"
                font.pixelSize: 16
                anchors.centerIn: parent
            }
        }
    }
}
