import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: root
    property string workspaceName: ""
    property var workspaceModel
    property bool alwaysOnTop: false
    property bool clickThrough: false
    property bool overlaySelection: false
    property bool desaturateMode: false
    signal workspaceChanged(string name)
    signal searchRequested(string query)
    signal importRequested()
    signal exportRequested()
    signal captureRequested()
    signal settingsRequested()
    signal migrationRequested()
    signal snapshotRequested()
    signal alwaysOnTopToggled(bool enabled)
    signal clickThroughToggled(bool enabled)
    signal overlayToggled(bool enabled)
    signal desaturateToggled(bool enabled)

    background: Rectangle {
        color: "#0b1220"
        border.color: "#1e293b"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Label {
            text: "RefNexus"
            color: "#f8fafc"
            font.pixelSize: 20
            font.weight: Font.DemiBold
            Layout.leftMargin: 8
        }

        ComboBox {
            id: workspaceSelector
            model: root.workspaceModel
            textRole: "name"
            onActivated: root.workspaceChanged(currentText)
            Layout.preferredWidth: 220
        }

        ToolButton {
            text: "Open"
            onClicked: root.workspaceChanged(workspaceSelector.currentText)
        }

        ToolButton {
            text: "Migrate"
            onClicked: root.migrationRequested()
        }

        Item {
            Layout.fillWidth: true
        }

        TextField {
            id: searchField
            placeholderText: "Search boards, tags, and metadata"
            Layout.preferredWidth: 320
            onAccepted: root.searchRequested(text)
        }

        ToolButton {
            text: "Search"
            onClicked: root.searchRequested(searchField.text)
        }

        ToolButton {
            text: "Capture"
            onClicked: root.captureRequested()
        }

        ToolButton {
            text: "Import"
            onClicked: root.importRequested()
        }

        ToolButton {
            text: "Export"
            onClicked: root.exportRequested()
        }

        ToolButton {
            text: "Snapshot"
            onClicked: root.snapshotRequested()
        }

        ToolButton {
            text: "Overlay"
            checkable: true
            checked: root.overlaySelection
            onToggled: root.overlayToggled(checked)
        }

        ToolButton {
            text: "Top"
            checkable: true
            checked: root.alwaysOnTop
            onToggled: root.alwaysOnTopToggled(checked)
        }

        ToolButton {
            text: "Click-Through"
            checkable: true
            checked: root.clickThrough
            onToggled: root.clickThroughToggled(checked)
        }

        ToolButton {
            text: "Desat"
            checkable: true
            checked: root.desaturateMode
            onToggled: root.desaturateToggled(checked)
        }

        ToolButton {
            text: "Settings"
            onClicked: root.settingsRequested()
        }
    }
}
