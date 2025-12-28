import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt.labs.settings

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
    property real canvasScale: 1.0
    property real minCanvasScale: 0.4
    property real maxCanvasScale: 2.5
    property int baseFlags: 0
    property bool updatingFlags: false
    property int activeCardInteractions: 0
    property int selectedProjectIndex: -1
    property bool spacePanning: false
    property real panStartX: 0
    property real panStartY: 0
    property real panStartContentX: 0
    property real panStartContentY: 0

    ListModel {
        id: canvasModel
    }

    ListModel {
        id: projectModel
    }

    Settings {
        id: projectSettings
        category: "Projects"
        property var storedProjects: []
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
            itemRotation: 0,
            flipX: false,
            flipY: false
        })
    }

    function centerPosition() {
        var centerX = (canvasView.contentX + canvasView.width / 2) / root.canvasScale
        var centerY = (canvasView.contentY + canvasView.height / 2) / root.canvasScale
        return { x: centerX, y: centerY }
    }

    function clampValue(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value))
    }

    function applyContentPosition(x, y) {
        var maxX = Math.max(0, canvasView.contentWidth - canvasView.width)
        var maxY = Math.max(0, canvasView.contentHeight - canvasView.height)
        canvasView.contentX = clampValue(x, 0, maxX)
        canvasView.contentY = clampValue(y, 0, maxY)
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
            itemRotation: 0,
            flipX: false,
            flipY: false
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

    function serializeCanvasItems() {
        var items = []
        for (var i = 0; i < canvasModel.count; i += 1) {
            var item = canvasModel.get(i)
            items.push({
                itemType: item.itemType,
                title: item.title,
                description: item.description,
                noteText: item.noteText,
                source: item.source ? item.source.toString() : "",
                autoSize: item.autoSize,
                xPos: item.xPos,
                yPos: item.yPos,
                itemWidth: item.itemWidth,
                itemHeight: item.itemHeight,
                itemScale: item.itemScale,
                itemRotation: item.itemRotation,
                flipX: item.flipX,
                flipY: item.flipY
            })
        }
        return items
    }

    function restoreCanvasItems(items) {
        canvasModel.clear()
        for (var i = 0; i < items.length; i += 1) {
            var item = items[i]
            canvasModel.append({
                itemType: item.itemType || "note",
                title: item.title || "",
                description: item.description || "",
                noteText: item.noteText || "",
                source: item.source || "",
                autoSize: item.autoSize === undefined ? false : item.autoSize,
                xPos: item.xPos !== undefined ? item.xPos : 0,
                yPos: item.yPos !== undefined ? item.yPos : 0,
                itemWidth: item.itemWidth !== undefined ? item.itemWidth : 280,
                itemHeight: item.itemHeight !== undefined ? item.itemHeight : 160,
                itemScale: item.itemScale !== undefined ? item.itemScale : 1.0,
                itemRotation: item.itemRotation !== undefined ? item.itemRotation : 0,
                flipX: item.flipX === true,
                flipY: item.flipY === true
            })
        }
        selectedIndex = -1
    }

    function normalizeProjectData(data) {
        if (data === undefined || data === null) {
            return []
        }
        if (typeof data === "string") {
            try {
                return JSON.parse(data)
            } catch (err) {
                return []
            }
        }
        if (Array.isArray(data)) {
            return data
        }
        if (data.length !== undefined) {
            var list = []
            for (var i = 0; i < data.length; i += 1) {
                list.push(data[i])
            }
            return list
        }
        return []
    }

    function parseStoredProjects(raw) {
        var stored = raw
        if (typeof stored === "string") {
            try {
                stored = JSON.parse(stored)
            } catch (err) {
                stored = []
            }
        }
        if (!stored || stored.length === undefined) {
            stored = []
        }
        var projects = []
        for (var i = 0; i < stored.length; i += 1) {
            var entry = stored[i] || {}
            projects.push({
                name: entry.name || "Untitled",
                data: normalizeProjectData(entry.data)
            })
        }
        return projects
    }

    function hasSelection() {
        return selectedIndex >= 0 && selectedIndex < canvasModel.count
    }

    function isImageSelected() {
        return hasSelection() && canvasModel.get(selectedIndex).itemType === "image"
    }

    function selectItem(index) {
        if (index < 0 || index >= canvasModel.count) {
            selectedIndex = -1
            return
        }
        var targetIndex = canvasModel.count - 1
        if (index !== targetIndex) {
            canvasModel.move(index, targetIndex, 1)
        }
        selectedIndex = targetIndex
    }

    function selectedLabel() {
        if (!hasSelection()) {
            return "No selection"
        }
        var item = canvasModel.get(selectedIndex)
        var name = item.title
        if (name === undefined || name.trim().length === 0) {
            name = item.itemType === "image" ? "Image" : "Note"
        }
        return "Selected: " + name
    }

    function flipSelected(horizontal) {
        if (!hasSelection()) {
            return
        }
        var propertyName = horizontal ? "flipX" : "flipY"
        var currentValue = canvasModel.get(selectedIndex)[propertyName] === true
        canvasModel.setProperty(selectedIndex, propertyName, !currentValue)
    }

    function rotateSelected(angle) {
        if (!hasSelection()) {
            return
        }
        var current = canvasModel.get(selectedIndex).itemRotation || 0
        canvasModel.setProperty(selectedIndex, "itemRotation", current + angle)
    }

    function duplicateSelected() {
        if (!hasSelection()) {
            return
        }
        var item = canvasModel.get(selectedIndex)
        canvasModel.append({
            itemType: item.itemType,
            title: item.title || "",
            description: item.description || "",
            noteText: item.noteText || "",
            source: item.source || "",
            autoSize: item.autoSize === undefined ? false : item.autoSize,
            xPos: item.xPos + 24,
            yPos: item.yPos + 24,
            itemWidth: item.itemWidth !== undefined ? item.itemWidth : 280,
            itemHeight: item.itemHeight !== undefined ? item.itemHeight : 160,
            itemScale: item.itemScale !== undefined ? item.itemScale : 1.0,
            itemRotation: item.itemRotation !== undefined ? item.itemRotation : 0,
            flipX: item.flipX === true,
            flipY: item.flipY === true
        })
        selectedIndex = canvasModel.count - 1
    }

    function deleteSelected() {
        if (!hasSelection()) {
            return
        }
        var removedIndex = selectedIndex
        canvasModel.remove(removedIndex)
        if (canvasModel.count === 0) {
            selectedIndex = -1
            return
        }
        selectedIndex = Math.min(removedIndex, canvasModel.count - 1)
    }

    function bringSelectionForward() {
        if (!hasSelection()) {
            return
        }
        if (selectedIndex >= canvasModel.count - 1) {
            return
        }
        canvasModel.move(selectedIndex, selectedIndex + 1, 1)
        selectedIndex += 1
    }

    function sendSelectionBackward() {
        if (!hasSelection()) {
            return
        }
        if (selectedIndex <= 0) {
            return
        }
        canvasModel.move(selectedIndex, selectedIndex - 1, 1)
        selectedIndex -= 1
    }

    function bringSelectionToFront() {
        if (!hasSelection()) {
            return
        }
        var targetIndex = canvasModel.count - 1
        if (selectedIndex === targetIndex) {
            return
        }
        canvasModel.move(selectedIndex, targetIndex, 1)
        selectedIndex = targetIndex
    }

    function sendSelectionToBack() {
        if (!hasSelection()) {
            return
        }
        if (selectedIndex === 0) {
            return
        }
        canvasModel.move(selectedIndex, 0, 1)
        selectedIndex = 0
    }

    function persistProjects() {
        var stored = []
        for (var i = 0; i < projectModel.count; i += 1) {
            var entry = projectModel.get(i)
            stored.push({ name: entry.name, data: entry.data })
        }
        projectSettings.storedProjects = JSON.stringify(stored)
    }

    function loadStoredProjects() {
        projectModel.clear()
        var stored = parseStoredProjects(projectSettings.storedProjects)
        for (var i = 0; i < stored.length; i += 1) {
            projectModel.append(stored[i])
        }
    }

    function saveProject(name) {
        var trimmedName = name.trim()
        if (trimmedName.length === 0) {
            return
        }
        var data = serializeCanvasItems()
        var existingIndex = -1
        for (var i = 0; i < projectModel.count; i += 1) {
            if (projectModel.get(i).name === trimmedName) {
                existingIndex = i
                break
            }
        }
        if (existingIndex >= 0) {
            projectModel.setProperty(existingIndex, "data", data)
            selectedProjectIndex = existingIndex
        } else {
            projectModel.append({ name: trimmedName, data: data })
            selectedProjectIndex = projectModel.count - 1
        }
        persistProjects()
    }

    function loadProject(index) {
        if (index < 0 || index >= projectModel.count) {
            return
        }
        var entry = projectModel.get(index)
        var items = normalizeProjectData(entry.data)
        restoreCanvasItems(items)
        selectedProjectIndex = index
    }

    Component.onCompleted: {
        baseFlags = flags
        updateWindowFlags()
        loadStoredProjects()
        keyScope.forceActiveFocus()
    }

    function beginCardInteraction() {
        activeCardInteractions += 1
    }

    function endCardInteraction() {
        activeCardInteractions = Math.max(0, activeCardInteractions - 1)
    }

    FocusScope {
        id: keyScope
        anchors.fill: parent
        focus: true

        Keys.onPressed: {
            if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                root.spacePanning = true
                event.accepted = true
            }
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                root.spacePanning = false
                event.accepted = true
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+]"
        context: Qt.ApplicationShortcut
        onActivated: root.bringSelectionForward()
    }

    Shortcut {
        sequence: "Ctrl+["
        context: Qt.ApplicationShortcut
        onActivated: root.sendSelectionBackward()
    }

    Shortcut {
        sequence: "Ctrl+Shift+]"
        context: Qt.ApplicationShortcut
        onActivated: root.bringSelectionToFront()
    }

    Shortcut {
        sequence: "Ctrl+Shift+["
        context: Qt.ApplicationShortcut
        onActivated: root.sendSelectionToBack()
    }

    Shortcut {
        sequence: "Meta+]"
        context: Qt.ApplicationShortcut
        onActivated: root.bringSelectionForward()
    }

    Shortcut {
        sequence: "Meta+["
        context: Qt.ApplicationShortcut
        onActivated: root.sendSelectionBackward()
    }

    Shortcut {
        sequence: "Meta+Shift+]"
        context: Qt.ApplicationShortcut
        onActivated: root.bringSelectionToFront()
    }

    Shortcut {
        sequence: "Meta+Shift+["
        context: Qt.ApplicationShortcut
        onActivated: root.sendSelectionToBack()
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
                hoverEnabled: true
                ToolTip.text: "Add images to the canvas"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                Layout.leftMargin: 12
            }

            ToolButton {
                text: "Add Note"
                onClicked: root.addNote()
                hoverEnabled: true
                ToolTip.text: "Add a note card"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
            }

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                text: "Top"
                checkable: true
                checked: root.alwaysOnTop
                onToggled: root.alwaysOnTop = checked
                hoverEnabled: true
                ToolTip.text: "Toggle always on top"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
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

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: sidebar
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: "#0b1220"
            border.color: "#1e293b"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Label {
                    text: "Projects"
                    color: "#e2e8f0"
                    font.pixelSize: 16
                }

                TextField {
                    id: projectNameField
                    placeholderText: "Project name"
                    Layout.fillWidth: true
                    hoverEnabled: true
                    ToolTip.text: "Enter a name for saving"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                }

                Button {
                    text: "Save Project"
                    Layout.fillWidth: true
                    enabled: projectNameField.text.trim().length > 0
                    hoverEnabled: true
                    ToolTip.text: "Save the current canvas"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: saveProject(projectNameField.text)
                }

                Label {
                    text: "Saved Sessions"
                    color: "#94a3b8"
                    font.pixelSize: 12
                }

                ListView {
                    id: projectList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: projectModel
                    delegate: ItemDelegate {
                        width: ListView.view.width
                        text: name
                        highlighted: index === root.selectedProjectIndex
                        hoverEnabled: true
                        ToolTip.text: "Load project: " + name
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        onClicked: {
                            projectNameField.text = name
                            root.loadProject(index)
                        }
                    }
                    ScrollBar.vertical: ScrollBar { }

                    Text {
                        anchors.centerIn: parent
                        visible: projectModel.count === 0
                        text: "No saved projects yet"
                        color: "#64748b"
                        font.pixelSize: 12
                    }
                }
            }
        }

        Flickable {
            id: canvasView
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: canvasRoot.width * root.canvasScale
            contentHeight: canvasRoot.height * root.canvasScale
            interactive: false
            clip: true
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }
            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }

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
                    var focusX = (canvasView.contentX + wheel.x) / oldScale
                    var focusY = (canvasView.contentY + wheel.y) / oldScale
                    root.canvasScale = newScale
                    root.applyContentPosition(focusX * newScale - wheel.x,
                        focusY * newScale - wheel.y)
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
                        flipHorizontal: flipX
                        flipVertical: flipY
                        kind: itemType
                        imageSource: source
                        titleText: title
                        descriptionText: description
                        noteText: noteText
                        autoSize: autoSize
                        selected: index === root.selectedIndex
                        onActivated: root.selectItem(index)
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
                        onDragStarted: {
                            root.selectItem(index)
                            root.beginCardInteraction()
                        }
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

            MouseArea {
                id: panOverlay
                parent: canvasView
                anchors.fill: parent
                enabled: root.spacePanning
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                onPressed: {
                    root.panStartX = mouse.x
                    root.panStartY = mouse.y
                    root.panStartContentX = canvasView.contentX
                    root.panStartContentY = canvasView.contentY
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

        Rectangle {
            id: toolPanel
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: "#0b1220"
            border.color: "#1e293b"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Label {
                    text: "Tools"
                    color: "#e2e8f0"
                    font.pixelSize: 16
                }

                Text {
                    text: root.selectedLabel()
                    color: "#94a3b8"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: "Transform"
                    color: "#94a3b8"
                    font.pixelSize: 12
                }

                Button {
                    text: "Flip Horizontal"
                    Layout.fillWidth: true
                    enabled: root.isImageSelected()
                    hoverEnabled: true
                    ToolTip.text: "Flip image horizontally"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.flipSelected(true)
                }

                Button {
                    text: "Flip Vertical"
                    Layout.fillWidth: true
                    enabled: root.isImageSelected()
                    hoverEnabled: true
                    ToolTip.text: "Flip image vertically"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.flipSelected(false)
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: "Rotate Left"
                        Layout.fillWidth: true
                        enabled: root.hasSelection()
                        hoverEnabled: true
                        ToolTip.text: "Rotate selection -90°"
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        onClicked: root.rotateSelected(-90)
                    }

                    Button {
                        text: "Rotate Right"
                        Layout.fillWidth: true
                        enabled: root.hasSelection()
                        hoverEnabled: true
                        ToolTip.text: "Rotate selection +90°"
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        onClicked: root.rotateSelected(90)
                    }
                }

                Label {
                    text: "Actions"
                    color: "#94a3b8"
                    font.pixelSize: 12
                }

                Button {
                    text: "Duplicate"
                    Layout.fillWidth: true
                    enabled: root.hasSelection()
                    hoverEnabled: true
                    ToolTip.text: "Duplicate selection"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.duplicateSelected()
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: "Forward"
                        Layout.fillWidth: true
                        enabled: root.hasSelection()
                        hoverEnabled: true
                        ToolTip.text: "Bring forward (Ctrl/Cmd + ])"
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        onClicked: root.bringSelectionForward()
                    }

                    Button {
                        text: "Backward"
                        Layout.fillWidth: true
                        enabled: root.hasSelection()
                        hoverEnabled: true
                        ToolTip.text: "Send backward (Ctrl/Cmd + [)"
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        onClicked: root.sendSelectionBackward()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: "To Front"
                        Layout.fillWidth: true
                        enabled: root.hasSelection()
                        hoverEnabled: true
                        ToolTip.text: "Bring to front (Ctrl/Cmd + Shift + ])"
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        onClicked: root.bringSelectionToFront()
                    }

                    Button {
                        text: "To Back"
                        Layout.fillWidth: true
                        enabled: root.hasSelection()
                        hoverEnabled: true
                        ToolTip.text: "Send to back (Ctrl/Cmd + Shift + [)"
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        onClicked: root.sendSelectionToBack()
                    }
                }

                Button {
                    text: "Delete"
                    Layout.fillWidth: true
                    enabled: root.hasSelection()
                    hoverEnabled: true
                    ToolTip.text: "Delete selection"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.deleteSelected()
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
