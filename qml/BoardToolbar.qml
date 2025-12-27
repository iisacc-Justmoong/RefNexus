import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: root
    property bool gridEnabled: true
    property bool snapEnabled: true
    property bool desaturateMode: false
    signal gridToggled(bool enabled)
    signal snapToggled(bool enabled)
    signal desaturateToggled(bool enabled)
    signal tidyRequested()
    signal alignRequested()
    signal groupRequested()

    background: Rectangle {
        color: "#101827"
        border.color: "#1e293b"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8
        Layout.leftMargin: 8

        ToolButton {
            text: "Align"
            onClicked: root.alignRequested()
        }

        ToolButton {
            text: "Tidy"
            onClicked: root.tidyRequested()
        }

        ToolButton {
            text: "Group"
            onClicked: root.groupRequested()
        }

        ToolButton {
            text: "Guide"
            checkable: true
            checked: root.gridEnabled
            onToggled: root.gridToggled(checked)
        }

        ToolButton {
            text: "Snap"
            checkable: true
            checked: root.snapEnabled
            onToggled: root.snapToggled(checked)
        }

        ToolButton {
            text: "Lock"
            checkable: true
        }

        ToolButton {
            text: "Note"
        }

        ToolButton {
            text: "Shape"
        }

        ToolButton {
            text: "Measure"
        }

        Item {
            Layout.fillWidth: true
        }

        ToolButton {
            text: "Desat"
            checkable: true
            checked: root.desaturateMode
            onToggled: root.desaturateToggled(checked)
        }
    }
}
