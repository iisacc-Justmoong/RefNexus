import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    color: "#0b0d10"

    onClosing: {
        syncCurrentProject()
    }

    property bool alwaysOnTop: false
    property string selectedId: ""
    property real canvasWidth: 4200
    property real canvasHeight: 2800
    property real canvasScale: 1.0
    property real minCanvasScale: 0.4
    property real maxCanvasScale: 2.5
    property real collapsedHeight: 40
    property bool gridEnabled: false
    property bool snapEnabled: false
    property int gridSize: 40
    property bool leftSidebarCollapsed: false
    property bool rightSidebarCollapsed: false
    property string fitTargetId: ""
    property real fitTargetWidth: 0
    property real fitTargetHeight: 0
    property int baseFlags: 0
    property bool updatingFlags: false
    property int activeCardInteractions: 0
    property int selectedProjectIndex: -1
    property bool spacePanning: inputState ? inputState.spacePressed : false
    property real panStartX: 0
    property real panStartY: 0
    property real panStartContentX: 0
    property real panStartContentY: 0
    property bool projectRestoring: false
    property int editingProjectIndex: -1
    property string editingProjectName: ""

    ListModel {
        id: canvasModel
    }

    ListModel {
        id: projectModel
    }

    Timer {
        id: autoSaveTimer
        interval: 250
        repeat: false
        onTriggered: root.syncCurrentProject()
    }

    function createId() {
        return Math.random().toString(36).slice(2) + Date.now().toString(36)
    }

    function addImage(url, dropX, dropY) {
        var urlString = url.toString()
        var baseName = urlString.substring(urlString.lastIndexOf("/") + 1)
        var snapped = snapPosition(dropX, dropY)
        canvasModel.append({
            uid: createId(),
            itemType: "image",
            title: decodeURIComponent(baseName),
            description: "",
            source: urlString,
            autoSize: true,
            xPos: snapped.x,
            yPos: snapped.y,
            itemWidth: 320,
            itemHeight: 240,
            itemScale: 1.0,
            itemRotation: 0,
            flipX: false,
            flipY: false,
            collapsed: false,
            expandedHeight: 240,
            contentExtraWidth: 16,
            contentExtraHeight: 0,
            displayWidth: 0,
            displayHeight: 0
        })
        scheduleAutoSave()
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

    function snapValue(value) {
        if (!snapEnabled || gridSize <= 0) {
            return value
        }
        return Math.round(value / gridSize) * gridSize
    }

    function snapPosition(x, y) {
        return { x: snapValue(x), y: snapValue(y) }
    }

    function snapSize(width, height) {
        if (!snapEnabled || gridSize <= 0) {
            return { width: width, height: height }
        }
        return {
            width: Math.max(1, snapValue(width)),
            height: Math.max(1, snapValue(height))
        }
    }

    function scheduleAutoSave() {
        if (projectRestoring || !projectStore) {
            return
        }
        autoSaveTimer.restart()
        projectStore.updateCurrentProject(serializeCanvasItems())
    }

    function syncCurrentProject() {
        if (projectRestoring || !projectStore) {
            return
        }
        Qt.inputMethod.commit()
        projectStore.updateCurrentProject(serializeCanvasItems())
    }

    function indexForId(targetId) {
        if (!targetId) {
            return -1
        }
        for (var i = 0; i < canvasModel.count; i += 1) {
            if (canvasModel.get(i).uid === targetId) {
                return i
            }
        }
        return -1
    }

    function selectionIndex() {
        return indexForId(selectedId)
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
            var uid = item.uid
            if (!uid) {
                uid = createId()
                canvasModel.setProperty(i, "uid", uid)
            }
            items.push({
                uid: uid,
                itemType: item.itemType,
                title: item.title,
                description: item.description,
                source: item.source ? item.source.toString() : "",
                autoSize: item.autoSize,
                xPos: item.xPos,
                yPos: item.yPos,
                itemWidth: item.itemWidth,
                itemHeight: item.itemHeight,
                itemScale: item.itemScale,
                itemRotation: item.itemRotation,
                flipX: item.flipX,
                flipY: item.flipY,
                collapsed: item.collapsed === true,
                expandedHeight: item.expandedHeight !== undefined
                    ? item.expandedHeight
                    : item.itemHeight,
                contentExtraWidth: item.contentExtraWidth,
                contentExtraHeight: item.contentExtraHeight,
                displayWidth: item.displayWidth,
                displayHeight: item.displayHeight
            })
        }
        return items
    }

    function restoreCanvasItems(items) {
        canvasModel.clear()
        for (var i = 0; i < items.length; i += 1) {
            var item = items[i]
            if (item.itemType && item.itemType !== "image") {
                continue
            }
            canvasModel.append({
                uid: item.uid || createId(),
                itemType: "image",
                title: item.title || "",
                description: item.description || "",
                source: item.source || "",
                autoSize: item.autoSize === undefined ? false : item.autoSize,
                xPos: item.xPos !== undefined ? item.xPos : 0,
                yPos: item.yPos !== undefined ? item.yPos : 0,
                itemWidth: item.itemWidth !== undefined ? item.itemWidth : 280,
                itemHeight: item.itemHeight !== undefined ? item.itemHeight : 160,
                itemScale: item.itemScale !== undefined ? item.itemScale : 1.0,
                itemRotation: item.itemRotation !== undefined ? item.itemRotation : 0,
                flipX: item.flipX === true,
                flipY: item.flipY === true,
                collapsed: item.collapsed === true,
                expandedHeight: item.expandedHeight !== undefined
                    ? item.expandedHeight
                    : (item.itemHeight !== undefined ? item.itemHeight : 160),
                contentExtraWidth: item.contentExtraWidth !== undefined
                    ? item.contentExtraWidth
                    : 16,
                contentExtraHeight: item.contentExtraHeight !== undefined
                    ? item.contentExtraHeight
                    : 0,
                displayWidth: item.displayWidth !== undefined
                    ? item.displayWidth
                    : 0,
                displayHeight: item.displayHeight !== undefined
                    ? item.displayHeight
                    : 0
            })
        }
        selectedId = ""
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

    function refreshProjects() {
        projectModel.clear()
        if (!projectStore) {
            return
        }
        var projects = projectStore.projects
        for (var i = 0; i < projects.length; i += 1) {
            projectModel.append({
                name: projects[i].name
            })
        }
    }

    function loadCurrentProject() {
        if (!projectStore) {
            return
        }
        projectRestoring = true
        restoreCanvasItems(normalizeProjectData(projectStore.currentProjectData()))
        projectRestoring = false
        selectedProjectIndex = projectStore.currentProjectIndex
        editingProjectIndex = -1
        editingProjectName = ""
    }

    function beginRenameProject(index) {
        if (index < 0 || index >= projectModel.count) {
            return
        }
        editingProjectIndex = index
        editingProjectName = projectModel.get(index).name
    }

    function commitRenameProject() {
        if (editingProjectIndex < 0) {
            return
        }
        if (projectStore) {
            projectStore.renameProject(editingProjectIndex, editingProjectName)
        }
        editingProjectIndex = -1
        editingProjectName = ""
        refreshProjects()
        selectedProjectIndex = projectStore ? projectStore.currentProjectIndex : -1
    }

    function cancelRenameProject() {
        editingProjectIndex = -1
        editingProjectName = ""
    }

    function selectProjectByName(name) {
        for (var i = 0; i < projectModel.count; i += 1) {
            if (projectModel.get(i).name === name) {
                selectedProjectIndex = i
                return
            }
        }
        selectedProjectIndex = -1
    }

    function removeItemById(itemId) {
        var index = indexForId(itemId)
        if (index < 0) {
            return
        }
        canvasModel.remove(index)
        if (selectedId === itemId) {
            if (canvasModel.count === 0) {
                selectedId = ""
            } else {
                var nextIndex = Math.min(index, canvasModel.count - 1)
                selectedId = canvasModel.get(nextIndex).uid
            }
        }
        scheduleAutoSave()
    }

    function toggleCollapse(itemId, collapsed) {
        var index = indexForId(itemId)
        if (index < 0) {
            return
        }
        var item = canvasModel.get(index)
        if (collapsed) {
            canvasModel.setProperty(index, "expandedHeight", item.itemHeight)
            canvasModel.setProperty(index, "itemHeight", root.collapsedHeight)
            canvasModel.setProperty(index, "collapsed", true)
        } else {
            var restoredHeight = item.expandedHeight !== undefined
                ? item.expandedHeight
                : item.itemHeight
            canvasModel.setProperty(index, "itemHeight", restoredHeight)
            canvasModel.setProperty(index, "collapsed", false)
        }
        scheduleAutoSave()
    }

    function updateCanvasItem(index, updates) {
        var result = updates
        if (updates.xPos !== undefined || updates.yPos !== undefined) {
            var snappedPos = snapPosition(
                updates.xPos !== undefined ? updates.xPos : canvasModel.get(index).xPos,
                updates.yPos !== undefined ? updates.yPos : canvasModel.get(index).yPos
            )
            result = Object.assign({}, updates, {
                xPos: snappedPos.x,
                yPos: snappedPos.y
            })
        }
        if (updates.itemWidth !== undefined || updates.itemHeight !== undefined) {
            var snappedSize = snapSize(
                updates.itemWidth !== undefined ? updates.itemWidth : canvasModel.get(index).itemWidth,
                updates.itemHeight !== undefined ? updates.itemHeight : canvasModel.get(index).itemHeight
            )
            result = Object.assign({}, result, {
                itemWidth: snappedSize.width,
                itemHeight: snappedSize.height
            })
        }
        for (var key in result) {
            canvasModel.setProperty(index, key, result[key])
        }
        scheduleAutoSave()
    }

    function applyFitSize(index, extraWidth, extraHeight) {
        if (index < 0) {
            return
        }
        updateCanvasItem(index, {
            itemWidth: fitTargetWidth + extraWidth,
            itemHeight: fitTargetHeight + extraHeight,
            autoSize: false
        })
    }

    function hasSelection() {
        return selectionIndex() >= 0
    }

    function isImageSelected() {
        var index = selectionIndex()
        return index >= 0 && canvasModel.get(index).itemType === "image"
    }

    function selectItem(itemId) {
        var index = indexForId(itemId)
        if (index < 0) {
            selectedId = ""
            return
        }
        var targetIndex = canvasModel.count - 1
        if (index !== targetIndex) {
            canvasModel.move(index, targetIndex, 1)
            scheduleAutoSave()
        }
        selectedId = itemId
    }

    function selectedLabel() {
        var index = selectionIndex()
        if (index < 0) {
            return "No selection"
        }
        var item = canvasModel.get(index)
        var name = item.title
        if (name === undefined || name.trim().length === 0) {
            name = "Image"
        }
        return "Selected: " + name
    }

    function flipSelected(horizontal) {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        var propertyName = horizontal ? "flipX" : "flipY"
        var currentValue = canvasModel.get(index)[propertyName] === true
        canvasModel.setProperty(index, propertyName, !currentValue)
        scheduleAutoSave()
    }

    function rotateSelected(angle) {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        var current = canvasModel.get(index).itemRotation || 0
        canvasModel.setProperty(index, "itemRotation", current + angle)
        scheduleAutoSave()
    }

    function fitImageToContent() {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        if (canvasModel.get(index).itemType !== "image") {
            return
        }
        var item = canvasModel.get(index)
        var displayWidth = item.displayWidth
        var displayHeight = item.displayHeight
        if (!displayWidth || !displayHeight) {
            return
        }
        var extraWidth = item.contentExtraWidth !== undefined ? item.contentExtraWidth : 16
        var extraHeight = item.contentExtraHeight !== undefined ? item.contentExtraHeight : 0
        fitTargetId = item.uid
        fitTargetWidth = displayWidth
        fitTargetHeight = displayHeight
        applyFitSize(index, extraWidth, extraHeight)
    }

    function duplicateSelected() {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        var item = canvasModel.get(index)
        var newId = createId()
        canvasModel.append({
            uid: newId,
            itemType: item.itemType,
            title: item.title || "",
            description: item.description || "",
            source: item.source || "",
            autoSize: item.autoSize === undefined ? false : item.autoSize,
            xPos: item.xPos + 24,
            yPos: item.yPos + 24,
            itemWidth: item.itemWidth !== undefined ? item.itemWidth : 280,
            itemHeight: item.itemHeight !== undefined ? item.itemHeight : 160,
            itemScale: item.itemScale !== undefined ? item.itemScale : 1.0,
            itemRotation: item.itemRotation !== undefined ? item.itemRotation : 0,
            flipX: item.flipX === true,
            flipY: item.flipY === true,
            collapsed: item.collapsed === true,
            expandedHeight: item.expandedHeight !== undefined
                ? item.expandedHeight
                : item.itemHeight,
            contentExtraWidth: item.contentExtraWidth !== undefined
                ? item.contentExtraWidth
                : 16,
            contentExtraHeight: item.contentExtraHeight !== undefined
                ? item.contentExtraHeight
                : 0,
            displayWidth: item.displayWidth !== undefined
                ? item.displayWidth
                : 0,
            displayHeight: item.displayHeight !== undefined
                ? item.displayHeight
                : 0
        })
        selectedId = newId
        scheduleAutoSave()
    }

    function deleteSelected() {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        canvasModel.remove(index)
        if (canvasModel.count === 0) {
            selectedId = ""
            return
        }
        var nextIndex = Math.min(index, canvasModel.count - 1)
        selectedId = canvasModel.get(nextIndex).uid
        scheduleAutoSave()
    }

    function bringSelectionForward() {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        if (index >= canvasModel.count - 1) {
            return
        }
        canvasModel.move(index, index + 1, 1)
        scheduleAutoSave()
    }

    function sendSelectionBackward() {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        if (index <= 0) {
            return
        }
        canvasModel.move(index, index - 1, 1)
        scheduleAutoSave()
    }

    function bringSelectionToFront() {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        var targetIndex = canvasModel.count - 1
        if (index === targetIndex) {
            return
        }
        canvasModel.move(index, targetIndex, 1)
        scheduleAutoSave()
    }

    function sendSelectionToBack() {
        var index = selectionIndex()
        if (index < 0) {
            return
        }
        if (index === 0) {
            return
        }
        canvasModel.move(index, 0, 1)
        scheduleAutoSave()
    }

    function createProject(name) {
        if (!projectStore) {
            return
        }
        syncCurrentProject()
        autoSaveTimer.stop()
        if (!projectStore.createProject(name)) {
            return
        }
        cancelRenameProject()
        refreshProjects()
        loadCurrentProject()
    }

    function deleteProject(index) {
        if (!projectStore) {
            return
        }
        if (!projectStore.deleteProject(index)) {
            return
        }
        if (editingProjectIndex >= 0) {
            cancelRenameProject()
        }
        refreshProjects()
        loadCurrentProject()
    }

    function loadProject(index) {
        if (!projectStore) {
            return
        }
        syncCurrentProject()
        autoSaveTimer.stop()
        if (!projectStore.setCurrentProject(index)) {
            return
        }
        cancelRenameProject()
        loadCurrentProject()
    }

    Component.onCompleted: {
        baseFlags = flags
        updateWindowFlags()
        if (projectStore) {
            projectStore.reload()
        }
        refreshProjects()
        loadCurrentProject()
        gridOverlay.requestPaint()
    }

    Connections {
        target: projectStore
        function onProjectsChanged() {
            refreshProjects()
            loadCurrentProject()
            if (gridOverlay) {
                gridOverlay.requestPaint()
            }
        }
    }

    onGridEnabledChanged: gridOverlay.requestPaint()
    onGridSizeChanged: gridOverlay.requestPaint()

    function beginCardInteraction() {
        activeCardInteractions += 1
    }

    function endCardInteraction() {
        activeCardInteractions = Math.max(0, activeCardInteractions - 1)
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
            color: "#0f1115"
            border.color: "#1b1f26"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10

            ToolButton {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-add-image.svg"
                icon.width: 18
                icon.height: 18
                onClicked: imageDialog.open()
                hoverEnabled: true
                ToolTip.text: "Add images to the canvas"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                Layout.leftMargin: 12
            }

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-pin.svg"
                icon.width: 18
                icon.height: 18
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
            Layout.preferredWidth: root.leftSidebarCollapsed ? 40 : 260
            Layout.minimumWidth: root.leftSidebarCollapsed ? 40 : 260
            Layout.maximumWidth: root.leftSidebarCollapsed ? 40 : 260
            Layout.fillHeight: true
            color: "#0f1115"
            border.color: "#1b1f26"

            Item {
                id: leftSidebarHeader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 44

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    visible: !root.leftSidebarCollapsed

                    Label {
                        text: "Projects"
                        color: "#d7dbe0"
                        font.pixelSize: 16
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        display: AbstractButton.IconOnly
                        icon.source: "qrc:/qt/qml/RefNexus/resources/icon-chevron-left.svg"
                        icon.width: 16
                        icon.height: 16
                        hoverEnabled: true
                        ToolTip.text: "Collapse sidebar"
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        onClicked: root.leftSidebarCollapsed = true
                    }
                }

                ToolButton {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-chevron-right.svg"
                    icon.width: 16
                    icon.height: 16
                    hoverEnabled: true
                    ToolTip.text: "Expand sidebar"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    anchors.centerIn: parent
                    visible: root.leftSidebarCollapsed
                    onClicked: root.leftSidebarCollapsed = false
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: leftSidebarHeader.bottom
                anchors.bottom: parent.bottom
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 8
                anchors.bottomMargin: 16
                spacing: 12
                visible: !root.leftSidebarCollapsed

                Button {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-new-project.svg"
                    icon.width: 18
                    icon.height: 18
                    Layout.fillWidth: true
                    hoverEnabled: true
                    ToolTip.text: "Create a new Untitled project"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: createProject("Untitled")
                }

                Label {
                    text: "Saved Sessions"
                    color: "#8b9098"
                    font.pixelSize: 12
                }

                ListView {
                    id: projectList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: projectModel
                    focus: true
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.editingProjectIndex >= 0) {
                                root.commitRenameProject()
                            } else if (root.selectedProjectIndex >= 0) {
                                root.beginRenameProject(root.selectedProjectIndex)
                            }
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            root.cancelRenameProject()
                            event.accepted = true
                        }
                    }
                    delegate: Item {
                        id: projectRow
                        width: ListView.view.width
                        height: 34
                        property bool editing: index === root.editingProjectIndex

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: index === root.selectedProjectIndex
                                ? "#1b1f26"
                                : "transparent"
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8

                            Item {
                                id: projectHitArea
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Label {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: name
                                    color: "#d7dbe0"
                                    elide: Text.ElideRight
                                    visible: !projectRow.editing
                                }

                                TextField {
                                    id: projectNameEditor
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: projectRow.editing ? root.editingProjectName : ""
                                    visible: projectRow.editing
                                    selectByMouse: true
                                    onVisibleChanged: {
                                        if (visible) {
                                            forceActiveFocus()
                                            selectAll()
                                        }
                                    }
                                    onTextChanged: {
                                        if (activeFocus) {
                                            root.editingProjectName = text
                                        }
                                    }
                                    Keys.onPressed: {
                                        if (event.key === Qt.Key_Return
                                            || event.key === Qt.Key_Enter) {
                                            root.commitRenameProject()
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Escape) {
                                            root.cancelRenameProject()
                                            event.accepted = true
                                        }
                                    }
                                    onEditingFinished: {
                                        if (projectRow.editing) {
                                            root.commitRenameProject()
                                        }
                                    }
                                }

                                MouseArea {
                                    id: projectSelectArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: !projectRow.editing
                                    onClicked: {
                                        projectList.forceActiveFocus()
                                        root.loadProject(index)
                                    }
                                    onDoubleClicked: {
                                        projectList.forceActiveFocus()
                                        root.beginRenameProject(index)
                                    }
                                }

                                ToolTip.text: "Load project: " + name
                                ToolTip.delay: 1000
                                ToolTip.visible: projectSelectArea.containsMouse
                            }

                            ToolButton {
                                hoverEnabled: true
                                display: AbstractButton.IconOnly
                                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-trash.svg"
                                icon.width: 16
                                icon.height: 16
                                onClicked: root.deleteProject(index)
                                ToolTip.text: "Delete project"
                                ToolTip.delay: 1000
                                ToolTip.visible: hovered
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar { }

                    Text {
                        anchors.centerIn: parent
                        visible: projectModel.count === 0
                        text: "No saved projects yet"
                        color: "#8b9098"
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
                        var baseX = drop.x
                        var baseY = drop.y
                        for (var i = 0; i < drop.urls.length; i += 1) {
                            root.addImage(drop.urls[i], baseX + i * 24, baseY + i * 24)
                        }
                    }
                }

                TapHandler {
                    onTapped: root.selectedId = ""
                }

                Repeater {
                    model: canvasModel
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
                        onActivated: root.selectItem(uid)
                        onCloseRequested: root.removeItemById(uid)
                        onCollapseRequested: function(collapsedState) {
                            root.toggleCollapse(uid, collapsedState)
                        }
                        onLayoutMetricsReady: function(extraWidth, extraHeight) {
                            root.updateCanvasItem(index, {
                                contentExtraWidth: extraWidth,
                                contentExtraHeight: extraHeight
                            })
                        }
                        onDisplaySizeReady: function(width, height) {
                            root.updateCanvasItem(index, {
                                displayWidth: width,
                                displayHeight: height
                            })
                        }
                        onTitleEdited: function(text) {
                            root.updateCanvasItem(index, { title: text })
                        }
                        onDescriptionEdited: function(text) {
                            root.updateCanvasItem(index, { description: text })
                        }
                        onPositionRequested: function(x, y) {
                            root.updateCanvasItem(index, { xPos: x, yPos: y })
                        }
                        onResizeRequested: function(width, height) {
                            root.updateCanvasItem(index, {
                                itemWidth: width,
                                itemHeight: height
                            })
                        }
                        onAutoSizeApplied: root.updateCanvasItem(index, { autoSize: false })
                        onDragStarted: {
                            root.selectItem(uid)
                            root.beginCardInteraction()
                        }
                        onDragFinished: root.endCardInteraction()
                    }
                }

                Text {
                    visible: canvasModel.count === 0
                    text: "Drop images here to start your board"
                    color: "#8b9098"
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
                preventStealing: true
                acceptedButtons: Qt.LeftButton
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

        ToolPanel {
            id: toolPanel
            Layout.preferredWidth: root.rightSidebarCollapsed ? 40 : 240
            Layout.minimumWidth: root.rightSidebarCollapsed ? 40 : 240
            Layout.maximumWidth: root.rightSidebarCollapsed ? 40 : 240
            Layout.fillHeight: true
            collapsed: root.rightSidebarCollapsed
            selectedLabel: root.selectedLabel()
            gridEnabled: root.gridEnabled
            snapEnabled: root.snapEnabled
            imageSelected: root.isImageSelected()
            selectionAvailable: root.hasSelection()
            onCollapseRequested: root.rightSidebarCollapsed = collapsedState
            onGridToggled: root.gridEnabled = enabled
            onSnapToggled: root.snapEnabled = enabled
            onFitRequested: root.fitImageToContent()
            onFlipRequested: root.flipSelected(horizontal)
            onRotateRequested: root.rotateSelected(angle)
            onDuplicateRequested: root.duplicateSelected()
            onBringForwardRequested: root.bringSelectionForward()
            onSendBackwardRequested: root.sendSelectionBackward()
            onBringToFrontRequested: root.bringSelectionToFront()
            onSendToBackRequested: root.sendSelectionToBack()
            onDeleteRequested: root.deleteSelected()
        }
    }
}
