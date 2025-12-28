import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0f1115"
    border.color: "#1b1f26"

    property bool collapsed: false
    property string selectedLabel: ""
    property bool gridEnabled: false
    property bool snapEnabled: false
    property bool imageSelected: false
    property bool selectionAvailable: false

    signal collapseRequested(bool collapsedState)
    signal gridToggled(bool enabled)
    signal snapToggled(bool enabled)
    signal fitRequested()
    signal flipRequested(bool horizontal)
    signal rotateRequested(int angle)
    signal duplicateRequested()
    signal bringForwardRequested()
    signal sendBackwardRequested()
    signal bringToFrontRequested()
    signal sendToBackRequested()
    signal deleteRequested()

    Item {
        id: rightSidebarHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 44

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            visible: !root.collapsed

            ToolButton {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-chevron-right.svg"
                icon.width: 16
                icon.height: 16
                hoverEnabled: true
                ToolTip.text: "Collapse sidebar"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                onClicked: root.collapseRequested(true)
            }

            Label {
                text: "Tools"
                color: "#d7dbe0"
                font.pixelSize: 16
                Layout.fillWidth: true
            }
        }

        ToolButton {
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qt/qml/RefNexus/resources/icon-chevron-left.svg"
            icon.width: 16
            icon.height: 16
            hoverEnabled: true
            ToolTip.text: "Expand sidebar"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            anchors.centerIn: parent
            visible: root.collapsed
            onClicked: root.collapseRequested(false)
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: rightSidebarHeader.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 16
        spacing: 10
        visible: !root.collapsed

        Text {
            text: root.selectedLabel
            color: "#8b9098"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ToolSection {
            title: "Canvas"

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ToolButton {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-grid.svg"
                    icon.width: 18
                    icon.height: 18
                    checkable: true
                    checked: root.gridEnabled
                    hoverEnabled: true
                    ToolTip.text: "Toggle grid"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onToggled: root.gridToggled(checked)
                }

                ToolButton {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-snap.svg"
                    icon.width: 18
                    icon.height: 18
                    checkable: true
                    checked: root.snapEnabled
                    hoverEnabled: true
                    ToolTip.text: "Toggle snap"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onToggled: root.snapToggled(checked)
                }

                ToolButton {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-fit.svg"
                    icon.width: 18
                    icon.height: 18
                    enabled: root.imageSelected
                    hoverEnabled: true
                    ToolTip.text: "Fit card to image"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.fitRequested()
                }
            }
        }

        ToolSection {
            title: "Transform"

            Button {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-flip-h.svg"
                icon.width: 18
                icon.height: 18
                Layout.fillWidth: true
                enabled: root.imageSelected
                hoverEnabled: true
                ToolTip.text: "Flip image horizontally"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                onClicked: root.flipRequested(true)
            }

            Button {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-flip-v.svg"
                icon.width: 18
                icon.height: 18
                Layout.fillWidth: true
                enabled: root.imageSelected
                hoverEnabled: true
                ToolTip.text: "Flip image vertically"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                onClicked: root.flipRequested(false)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-rotate-left.svg"
                    icon.width: 18
                    icon.height: 18
                    Layout.fillWidth: true
                    enabled: root.selectionAvailable
                    hoverEnabled: true
                    ToolTip.text: "Rotate selection -90°"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.rotateRequested(-90)
                }

                Button {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-rotate-right.svg"
                    icon.width: 18
                    icon.height: 18
                    Layout.fillWidth: true
                    enabled: root.selectionAvailable
                    hoverEnabled: true
                    ToolTip.text: "Rotate selection +90°"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.rotateRequested(90)
                }
            }
        }

        ToolSection {
            title: "Actions"

            Button {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-duplicate.svg"
                icon.width: 18
                icon.height: 18
                Layout.fillWidth: true
                enabled: root.selectionAvailable
                hoverEnabled: true
                ToolTip.text: "Duplicate selection"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                onClicked: root.duplicateRequested()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-forward.svg"
                    icon.width: 18
                    icon.height: 18
                    Layout.fillWidth: true
                    enabled: root.selectionAvailable
                    hoverEnabled: true
                    ToolTip.text: "Bring forward (Ctrl/Cmd + ])"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.bringForwardRequested()
                }

                Button {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-backward.svg"
                    icon.width: 18
                    icon.height: 18
                    Layout.fillWidth: true
                    enabled: root.selectionAvailable
                    hoverEnabled: true
                    ToolTip.text: "Send backward (Ctrl/Cmd + [)"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.sendBackwardRequested()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-front.svg"
                    icon.width: 18
                    icon.height: 18
                    Layout.fillWidth: true
                    enabled: root.selectionAvailable
                    hoverEnabled: true
                    ToolTip.text: "Bring to front (Ctrl/Cmd + Shift + ])"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.bringToFrontRequested()
                }

                Button {
                    display: AbstractButton.IconOnly
                    icon.source: "qrc:/qt/qml/RefNexus/resources/icon-back.svg"
                    icon.width: 18
                    icon.height: 18
                    Layout.fillWidth: true
                    enabled: root.selectionAvailable
                    hoverEnabled: true
                    ToolTip.text: "Send to back (Ctrl/Cmd + Shift + [)"
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    onClicked: root.sendToBackRequested()
                }
            }

            Button {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-trash.svg"
                icon.width: 18
                icon.height: 18
                Layout.fillWidth: true
                enabled: root.selectionAvailable
                hoverEnabled: true
                ToolTip.text: "Delete selection"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                onClicked: root.deleteRequested()
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
