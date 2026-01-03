import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    color: "#0b0f14"
    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0c1118" }
            GradientStop { position: 1.0; color: "#090d12" }
        }
    }

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
    property bool projectRestoring: false
    property int editingProjectIndex: -1
    property string editingProjectName: ""

    ListModel {
        id: canvasModel
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
        if (!projectStore) {
            return
        }
        var projects = projectStore.projects
        if (index < 0 || index >= projects.length) {
            return
        }
        editingProjectIndex = index
        editingProjectName = projects[index].name
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
        selectedProjectIndex = projectStore ? projectStore.currentProjectIndex : -1
    }

    function cancelRenameProject() {
        editingProjectIndex = -1
        editingProjectName = ""
    }

    function selectProjectByName(name) {
        if (!projectStore) {
            selectedProjectIndex = -1
            return
        }
        var projects = projectStore.projects
        for (var i = 0; i < projects.length; i += 1) {
            if (projects[i].name === name) {
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

    function applyLayoutMetrics(index, extraWidth, extraHeight) {
        if (index < 0) {
            return
        }
        var item = canvasModel.get(index)
        var previousExtraHeight = item.contentExtraHeight !== undefined
            ? item.contentExtraHeight
            : 0
        var updates = {
            contentExtraWidth: extraWidth,
            contentExtraHeight: extraHeight
        }
        if (!item.collapsed && !item.autoSize && previousExtraHeight > 0
            && extraHeight > previousExtraHeight && item.itemHeight !== undefined) {
            updates.itemHeight = item.itemHeight + (extraHeight - previousExtraHeight)
        }
        updateCanvasItem(index, updates)
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
        loadCurrentProject()
        canvasView.requestGridPaint()
    }

    Connections {
        target: projectStore
        function onProjectsChanged() {
            loadCurrentProject()
            canvasView.requestGridPaint()
        }
    }

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

    header: MainToolBar {
        alwaysOnTop: root.alwaysOnTop
        onAddImageRequested: imageDialog.open()
        onAlwaysOnTopToggled: root.alwaysOnTop = enabled
    }

    ImageImportDialog {
        id: imageDialog
        onImagesSelected: {
            var center = root.centerPosition()
            for (var i = 0; i < urls.length; i += 1) {
                root.addImage(urls[i], center.x + i * 24, center.y + i * 24)
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ProjectSidebar {
            id: sidebar
            Layout.preferredWidth: root.leftSidebarCollapsed ? 40 : 260
            Layout.minimumWidth: root.leftSidebarCollapsed ? 40 : 260
            Layout.maximumWidth: root.leftSidebarCollapsed ? 40 : 260
            Layout.fillHeight: true
            collapsed: root.leftSidebarCollapsed
            projectModel: projectStore ? projectStore.projects : []
            selectedProjectIndex: root.selectedProjectIndex
            editingProjectIndex: root.editingProjectIndex
            editingProjectName: root.editingProjectName
            onCollapseRequested: root.leftSidebarCollapsed = collapsedState
            onCreateProjectRequested: root.createProject(name)
            onProjectSelected: root.loadProject(index)
            onDeleteProjectRequested: root.deleteProject(index)
            onRenameProjectRequested: root.beginRenameProject(index)
            onRenameCommitted: root.commitRenameProject()
            onRenameCanceled: root.cancelRenameProject()
            onEditingProjectNameUpdated: function(updatedName) {
                root.editingProjectName = updatedName
            }
        }

        CanvasView {
            id: canvasView
            Layout.fillWidth: true
            Layout.fillHeight: true
            canvasWidth: root.canvasWidth
            canvasHeight: root.canvasHeight
            canvasScale: root.canvasScale
            minCanvasScale: root.minCanvasScale
            maxCanvasScale: root.maxCanvasScale
            gridEnabled: root.gridEnabled
            gridSize: root.gridSize
            spacePanning: root.spacePanning
            selectedId: root.selectedId
            canvasModel: canvasModel
            onScaleRequested: root.canvasScale = scale
            onImagesDropped: {
                for (var i = 0; i < urls.length; i += 1) {
                    root.addImage(urls[i], dropX + i * 24, dropY + i * 24)
                }
            }
            onClearSelectionRequested: root.selectedId = ""
            onItemActivated: root.selectItem(uid)
            onCloseRequested: root.removeItemById(uid)
            onCollapseRequested: root.toggleCollapse(uid, collapsedState)
            onLayoutMetricsReady: root.applyLayoutMetrics(index, extraWidth, extraHeight)
            onDisplaySizeReady: root.updateCanvasItem(index, {
                displayWidth: displayWidth,
                displayHeight: displayHeight
            })
            onTitleEdited: root.updateCanvasItem(index, { title: text })
            onDescriptionEdited: root.updateCanvasItem(index, { description: text })
            onPositionRequested: root.updateCanvasItem(index, { xPos: posX, yPos: posY })
            onResizeRequested: root.updateCanvasItem(index, {
                itemWidth: itemWidth,
                itemHeight: itemHeight
            })
            onAutoSizeApplied: root.updateCanvasItem(index, { autoSize: false })
            onDragStarted: {
                root.selectItem(uid)
                root.beginCardInteraction()
            }
            onDragFinished: root.endCardInteraction()
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
