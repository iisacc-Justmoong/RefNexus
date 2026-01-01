import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: root

    property bool alwaysOnTop: false

    signal addImageRequested()
    signal alwaysOnTopToggled(bool enabled)

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
            onClicked: root.addImageRequested()
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
            onToggled: root.alwaysOnTopToggled(checked)
            hoverEnabled: true
            ToolTip.text: "Toggle always on top"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
        }
    }
}
