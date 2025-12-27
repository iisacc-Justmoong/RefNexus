import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property string title: ""
    property string subtitle: ""
    property string kind: "image"
    property string tags: ""
    property color accentColor: "#38bdf8"
    property bool selected: false
    property bool locked: false
    property real rotationAngle: 0
    property real scaleFactor: 1.0
    signal clicked()

    width: 280
    height: 200
    scale: scaleFactor

    transform: Rotation {
        origin.x: root.width / 2
        origin.y: root.height / 2
        angle: root.rotationAngle
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: 14
        color: root.kind === "note" ? "#1e293b" : "#111827"
        border.color: root.selected ? root.accentColor : "#334155"
        border.width: root.selected ? 2 : 1
    }

    Rectangle {
        id: preview
        width: parent.width - 16
        height: root.kind === "note" ? 40 : parent.height - 70
        x: 8
        y: 8
        radius: 10
        color: root.kind === "note" ? "#0f172a" : root.accentColor
        opacity: root.kind === "note" ? 0.35 : 0.25
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 12
        spacing: 4

        Label {
            text: root.title
            color: "#f8fafc"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }

        Label {
            text: root.subtitle
            color: "#94a3b8"
            font.pixelSize: 11
        }

        Label {
            text: root.tags
            color: "#64748b"
            font.pixelSize: 10
            visible: root.tags !== ""
        }
    }

    Rectangle {
        width: 76
        height: 20
        radius: 10
        color: root.kind === "note" ? "#334155" : "#1d4ed8"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.rightMargin: 8
        visible: root.kind !== "image"

        Label {
            anchors.centerIn: parent
            text: root.kind === "note" ? "Note" : "Group"
            color: "#e2e8f0"
            font.pixelSize: 10
        }
    }

    Label {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.bottomMargin: 10
        text: root.locked ? "Locked" : ""
        color: "#fbbf24"
        font.pixelSize: 10
    }

    MouseArea {
        anchors.fill: parent
        drag.target: root.locked ? null : root
        drag.axis: Drag.XAndYAxis
        cursorShape: root.locked ? Qt.ArrowCursor : Qt.OpenHandCursor
        onPressed: root.clicked()
    }
}
