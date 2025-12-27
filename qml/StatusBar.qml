import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: root
    property real zoomLevel: 1.0
    property string storageMode: "Embedded"
    property string activeBoard: ""
    property string selectedTitle: ""
    property string lastSnapshot: "—"
    signal zoomChanged(real value)
    signal storageModeChanged(string mode)

    function pushSnapshot() {
        lastSnapshot = Qt.formatDateTime(new Date(), "hh:mm")
    }

    background: Rectangle {
        color: "#0b1220"
        border.color: "#1e293b"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12
        Layout.leftMargin: 8

        Label {
            text: activeBoard !== "" ? activeBoard : "Board"
            color: "#e2e8f0"
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        Label {
            text: selectedTitle !== "" ? "Selected: " + selectedTitle : "Selected: —"
            color: "#94a3b8"
            font.pixelSize: 11
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            text: "Zoom"
            color: "#94a3b8"
            font.pixelSize: 11
        }

        Slider {
            from: 0.2
            to: 2.0
            value: root.zoomLevel
            Layout.preferredWidth: 140
            onMoved: root.zoomChanged(value)
        }

        Label {
            text: Math.round(root.zoomLevel * 100) + "%"
            color: "#94a3b8"
            font.pixelSize: 11
        }

        ComboBox {
            model: ["Embedded", "Linked"]
            currentIndex: root.storageMode === "Embedded" ? 0 : 1
            onActivated: root.storageModeChanged(currentText)
        }

        Label {
            text: "Autosave: On"
            color: "#94a3b8"
            font.pixelSize: 11
        }

        Label {
            text: "Snapshot: " + root.lastSnapshot
            color: "#94a3b8"
            font.pixelSize: 11
        }
    }
}
