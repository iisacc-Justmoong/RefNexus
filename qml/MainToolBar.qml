import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: root

    property bool alwaysOnTop: false
    property color surfaceColor: "#121826"
    property color borderColor: "#243145"
    property color accentColor: "#5c7cfa"

    signal addImageRequested()
    signal alwaysOnTopToggled(bool enabled)

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#141b28" }
            GradientStop { position: 1.0; color: "#0f141d" }
        }
        border.color: root.borderColor
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        ToolButton {
            id: addButton
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qt/qml/RefNexus/resources/icon-add-image.svg"
            icon.width: 18
            icon.height: 18
            onClicked: root.addImageRequested()
            hoverEnabled: true
            ToolTip.text: "Add images to the canvas"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            Layout.leftMargin: 12
            implicitWidth: 36
            implicitHeight: 36
            background: Rectangle {
                radius: 10
                color: addButton.down
                    ? "#2a3a54"
                    : (addButton.hovered ? "#1f2a3a" : root.surfaceColor)
                border.color: root.borderColor
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ToolButton {
            id: pinButton
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qt/qml/RefNexus/resources/icon-pin.svg"
            icon.width: 18
            icon.height: 18
            checkable: true
            checked: root.alwaysOnTop
            onToggled: root.alwaysOnTopToggled(checked)
            hoverEnabled: true
            ToolTip.text: "Toggle always on top"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            implicitWidth: 36
            implicitHeight: 36
            background: Rectangle {
                radius: 10
                color: pinButton.checked
                    ? "#23314a"
                    : (pinButton.down
                        ? "#2a3a54"
                        : (pinButton.hovered ? "#1f2a3a" : root.surfaceColor))
                border.color: pinButton.checked ? root.accentColor : root.borderColor
            }
        }
    }
}
