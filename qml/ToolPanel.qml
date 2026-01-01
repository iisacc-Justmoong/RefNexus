import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0f141d"
    border.color: "#243145"
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#131a26" }
        GradientStop { position: 1.0; color: "#0f141d" }
    }

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
                id: collapseButton
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-chevron-right.svg"
                icon.width: 16
                icon.height: 16
                hoverEnabled: true
                ToolTip.text: "Collapse sidebar"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                onClicked: root.collapseRequested(true)
                implicitWidth: 30
                implicitHeight: 30
                background: Rectangle {
                    radius: 8
                    color: collapseButton.down
                        ? "#2a3a54"
                        : (collapseButton.hovered ? "#1f2a3a" : "#121826")
                    border.color: "#243145"
                }
            }

            Label {
                text: "Tools"
                color: "#e6edf5"
                font.pixelSize: 16
                Layout.fillWidth: true
            }
        }

        ToolButton {
            id: expandButton
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
            implicitWidth: 30
            implicitHeight: 30
            background: Rectangle {
                radius: 8
                color: expandButton.down
                    ? "#2a3a54"
                    : (expandButton.hovered ? "#1f2a3a" : "#121826")
                border.color: "#243145"
            }
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
            color: "#9aa6b2"
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
                    id: gridButton
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
                    implicitWidth: 34
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: gridButton.checked
                            ? "#23314a"
                            : (gridButton.down
                                ? "#2a3a54"
                                : (gridButton.hovered ? "#1f2a3a" : "#121826"))
                        border.color: gridButton.checked ? "#5c7cfa" : "#243145"
                    }
                }

                ToolButton {
                    id: snapButton
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
                    implicitWidth: 34
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: snapButton.checked
                            ? "#23314a"
                            : (snapButton.down
                                ? "#2a3a54"
                                : (snapButton.hovered ? "#1f2a3a" : "#121826"))
                        border.color: snapButton.checked ? "#5c7cfa" : "#243145"
                    }
                }

                ToolButton {
                    id: fitButton
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
                    implicitWidth: 34
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: fitButton.down
                            ? "#2a3a54"
                            : (fitButton.hovered ? "#1f2a3a" : "#121826")
                        border.color: "#243145"
                        opacity: fitButton.enabled ? 1.0 : 0.5
                    }
                }
            }
        }

        ToolSection {
            title: "Transform"

            Button {
                id: flipHorizontalButton
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
                implicitHeight: 34
                background: Rectangle {
                    radius: 8
                    color: flipHorizontalButton.down
                        ? "#2a3a54"
                        : (flipHorizontalButton.hovered ? "#1f2a3a" : "#121826")
                    border.color: "#243145"
                    opacity: flipHorizontalButton.enabled ? 1.0 : 0.5
                }
            }

            Button {
                id: flipVerticalButton
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
                implicitHeight: 34
                background: Rectangle {
                    radius: 8
                    color: flipVerticalButton.down
                        ? "#2a3a54"
                        : (flipVerticalButton.hovered ? "#1f2a3a" : "#121826")
                    border.color: "#243145"
                    opacity: flipVerticalButton.enabled ? 1.0 : 0.5
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    id: rotateLeftButton
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
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: rotateLeftButton.down
                            ? "#2a3a54"
                            : (rotateLeftButton.hovered ? "#1f2a3a" : "#121826")
                        border.color: "#243145"
                        opacity: rotateLeftButton.enabled ? 1.0 : 0.5
                    }
                }

                Button {
                    id: rotateRightButton
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
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: rotateRightButton.down
                            ? "#2a3a54"
                            : (rotateRightButton.hovered ? "#1f2a3a" : "#121826")
                        border.color: "#243145"
                        opacity: rotateRightButton.enabled ? 1.0 : 0.5
                    }
                }
            }
        }

        ToolSection {
            title: "Actions"

            Button {
                id: duplicateButton
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
                implicitHeight: 34
                background: Rectangle {
                    radius: 8
                    color: duplicateButton.down
                        ? "#2a3a54"
                        : (duplicateButton.hovered ? "#1f2a3a" : "#121826")
                    border.color: "#243145"
                    opacity: duplicateButton.enabled ? 1.0 : 0.5
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    id: forwardButton
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
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: forwardButton.down
                            ? "#2a3a54"
                            : (forwardButton.hovered ? "#1f2a3a" : "#121826")
                        border.color: "#243145"
                        opacity: forwardButton.enabled ? 1.0 : 0.5
                    }
                }

                Button {
                    id: backwardButton
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
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: backwardButton.down
                            ? "#2a3a54"
                            : (backwardButton.hovered ? "#1f2a3a" : "#121826")
                        border.color: "#243145"
                        opacity: backwardButton.enabled ? 1.0 : 0.5
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Button {
                    id: toFrontButton
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
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: toFrontButton.down
                            ? "#2a3a54"
                            : (toFrontButton.hovered ? "#1f2a3a" : "#121826")
                        border.color: "#243145"
                        opacity: toFrontButton.enabled ? 1.0 : 0.5
                    }
                }

                Button {
                    id: toBackButton
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
                    implicitHeight: 34
                    background: Rectangle {
                        radius: 8
                        color: toBackButton.down
                            ? "#2a3a54"
                            : (toBackButton.hovered ? "#1f2a3a" : "#121826")
                        border.color: "#243145"
                        opacity: toBackButton.enabled ? 1.0 : 0.5
                    }
                }
            }

            Button {
                id: deleteButton
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
                implicitHeight: 34
                background: Rectangle {
                    radius: 8
                    color: deleteButton.down
                        ? "#2a3a54"
                        : (deleteButton.hovered ? "#1f2a3a" : "#121826")
                    border.color: "#243145"
                    opacity: deleteButton.enabled ? 1.0 : 0.5
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
