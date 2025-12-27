import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1480
    height: 900
    visible: true
    title: "RefNexus"
    color: "#0f172a"

    property bool alwaysOnTop: false
    property bool clickThrough: false
    property bool overlaySelection: false
    property bool desaturateMode: false
    property bool gridEnabled: true
    property bool snapEnabled: true
    property real zoomLevel: 1.0
    property string activeWorkspace: "Concept Sprint 2025"
    property string storageMode: "Embedded"
    property var selectedItem: ({
        title: "No selection",
        type: "—",
        board: "—",
        source: "—",
        capturedAt: "—",
        license: "—",
        tags: "",
        notes: ""
    })
    property string searchQuery: ""
    property bool searchOpen: false
    property bool captureOpen: false
    property bool settingsOpen: false
    property bool importOpen: false
    property bool exportOpen: false
    property bool migrationOpen: false

    flags: Qt.Window
        | (alwaysOnTop ? Qt.WindowStaysOnTopHint : 0)
        | (clickThrough ? Qt.WindowTransparentForInput : 0)

    ListModel {
        id: workspaceModel
        ListElement { name: "Concept Sprint 2025" }
        ListElement { name: "Studio Library" }
        ListElement { name: "Client Decks" }
        ListElement { name: "Personal Archive" }
    }

    ListModel {
        id: boardModel
        ListElement { name: "Inspiration"; count: "128" }
        ListElement { name: "Characters"; count: "64" }
        ListElement { name: "Environments"; count: "92" }
        ListElement { name: "Materials"; count: "41" }
        ListElement { name: "Lighting"; count: "36" }
        ListElement { name: "Inbox"; count: "17" }
    }

    header: AppHeader {
        workspaceName: root.activeWorkspace
        workspaceModel: workspaceModel
        alwaysOnTop: root.alwaysOnTop
        clickThrough: root.clickThrough
        overlaySelection: root.overlaySelection
        desaturateMode: root.desaturateMode
        onWorkspaceChanged: root.activeWorkspace = name
        onSearchRequested: {
            root.searchQuery = query
            root.searchOpen = true
        }
        onImportRequested: root.importOpen = true
        onExportRequested: root.exportOpen = true
        onCaptureRequested: root.captureOpen = true
        onSettingsRequested: root.settingsOpen = true
        onMigrationRequested: root.migrationOpen = true
        onSnapshotRequested: statusBar.pushSnapshot()
        onAlwaysOnTopToggled: root.alwaysOnTop = enabled
        onClickThroughToggled: root.clickThrough = enabled
        onOverlayToggled: root.overlaySelection = enabled
        onDesaturateToggled: root.desaturateMode = enabled
    }

    footer: StatusBar {
        id: statusBar
        zoomLevel: root.zoomLevel
        storageMode: root.storageMode
        activeBoard: boardTabs.currentBoard
        selectedTitle: root.selectedItem.title
        onZoomChanged: root.zoomLevel = value
        onStorageModeChanged: root.storageMode = mode
    }

    SearchDrawer {
        requestedOpen: root.searchOpen
        query: root.searchQuery
        onDismissed: root.searchOpen = false
    }

    CaptureDrawer {
        requestedOpen: root.captureOpen
        onDismissed: root.captureOpen = false
    }

    SettingsDialog {
        opened: root.settingsOpen
        onClosed: root.settingsOpen = false
    }

    ImportDialog {
        opened: root.importOpen
        onClosed: root.importOpen = false
        onMigrationRequested: {
            root.importOpen = false
            root.migrationOpen = true
        }
    }

    ExportDialog {
        opened: root.exportOpen
        onClosed: root.exportOpen = false
    }

    MigrationWizard {
        opened: root.migrationOpen
        onClosed: root.migrationOpen = false
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        LeftSidebar {
            SplitView.preferredWidth: 260
            SplitView.minimumWidth: 220
            workspaceModel: workspaceModel
            boardsModel: boardModel
            activeWorkspace: root.activeWorkspace
            onWorkspaceSelected: root.activeWorkspace = name
        }

        ColumnLayout {
            id: centerColumn
            spacing: 0
            SplitView.fillWidth: true
            SplitView.minimumWidth: 640

            BoardTabs {
                id: boardTabs
                Layout.fillWidth: true
                boardsModel: boardModel
            }

            BoardToolbar {
                Layout.fillWidth: true
                gridEnabled: root.gridEnabled
                snapEnabled: root.snapEnabled
                desaturateMode: root.desaturateMode
                onGridToggled: root.gridEnabled = enabled
                onSnapToggled: root.snapEnabled = enabled
                onDesaturateToggled: root.desaturateMode = enabled
            }

            CanvasView {
                id: canvasView
                Layout.fillWidth: true
                Layout.fillHeight: true
                gridEnabled: root.gridEnabled
                snapEnabled: root.snapEnabled
                desaturateMode: root.desaturateMode
                overlaySelection: root.overlaySelection
                zoomLevel: root.zoomLevel
                activeBoard: boardTabs.currentBoard
                onItemSelected: root.selectedItem = item
            }
        }

        InspectorPanel {
            SplitView.preferredWidth: 320
            SplitView.minimumWidth: 280
            selectedItem: root.selectedItem
            alwaysOnTop: root.alwaysOnTop
            clickThrough: root.clickThrough
            overlaySelection: root.overlaySelection
            desaturateMode: root.desaturateMode
            gridEnabled: root.gridEnabled
            snapEnabled: root.snapEnabled
            onAlwaysOnTopToggled: root.alwaysOnTop = enabled
            onClickThroughToggled: root.clickThrough = enabled
            onOverlayToggled: root.overlaySelection = enabled
            onDesaturateToggled: root.desaturateMode = enabled
            onGridToggled: root.gridEnabled = enabled
            onSnapToggled: root.snapEnabled = enabled
        }
    }
}
