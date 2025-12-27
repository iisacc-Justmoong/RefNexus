import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Pane {
    id: root
    property var selectedItem
    property bool alwaysOnTop: false
    property bool clickThrough: false
    property bool overlaySelection: false
    property bool desaturateMode: false
    property bool gridEnabled: true
    property bool snapEnabled: true
    signal alwaysOnTopToggled(bool enabled)
    signal clickThroughToggled(bool enabled)
    signal overlayToggled(bool enabled)
    signal desaturateToggled(bool enabled)
    signal gridToggled(bool enabled)
    signal snapToggled(bool enabled)

    background: Rectangle {
        color: "#0b1120"
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            padding: 16
            spacing: 16

            ColumnLayout {
                spacing: 4

                Label {
                    text: "Selection"
                    color: "#cbd5f5"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                Label {
                    text: root.selectedItem.title
                    color: "#f8fafc"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                Label {
                    text: "Type: " + root.selectedItem.type + " · Board: " + root.selectedItem.board
                    color: "#94a3b8"
                    font.pixelSize: 11
                }
            }

            Frame {
                Layout.fillWidth: true
                background: Rectangle {
                    color: "#111c34"
                    radius: 12
                    border.color: "#1e293b"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Behavior"
                        color: "#e2e8f0"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Switch {
                        text: "Always on top"
                        checked: root.alwaysOnTop
                        onToggled: root.alwaysOnTopToggled(checked)
                    }

                    Switch {
                        text: "Transparent to mouse"
                        checked: root.clickThrough
                        onToggled: root.clickThroughToggled(checked)
                    }

                    Switch {
                        text: "Overlay selection"
                        checked: root.overlaySelection
                        onToggled: root.overlayToggled(checked)
                    }

                    Switch {
                        text: "Desaturate preview"
                        checked: root.desaturateMode
                        onToggled: root.desaturateToggled(checked)
                    }
                }
            }

            Frame {
                Layout.fillWidth: true
                background: Rectangle {
                    color: "#111c34"
                    radius: 12
                    border.color: "#1e293b"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Transform"
                        color: "#e2e8f0"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    RowLayout {
                        Label {
                            text: "Scale"
                            color: "#94a3b8"
                            font.pixelSize: 11
                        }

                        Slider {
                            from: 0.2
                            to: 2.0
                            value: 1.0
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label {
                            text: "Rotation"
                            color: "#94a3b8"
                            font.pixelSize: 11
                        }

                        Slider {
                            from: -45
                            to: 45
                            value: 0
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Label {
                            text: "Opacity"
                            color: "#94a3b8"
                            font.pixelSize: 11
                        }

                        Slider {
                            from: 0.2
                            to: 1.0
                            value: 1.0
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Frame {
                Layout.fillWidth: true
                background: Rectangle {
                    color: "#111c34"
                    radius: 12
                    border.color: "#1e293b"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Label {
                        text: "Board Layout"
                        color: "#e2e8f0"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Switch {
                        text: "Grid guides"
                        checked: root.gridEnabled
                        onToggled: root.gridToggled(checked)
                    }

                    Switch {
                        text: "Snap constraints"
                        checked: root.snapEnabled
                        onToggled: root.snapToggled(checked)
                    }

                    ComboBox {
                        model: ["Freeform", "Grid", "Columns", "Masonry"]
                        currentIndex: 0
                        Layout.fillWidth: true
                    }
                }
            }

            Frame {
                Layout.fillWidth: true
                background: Rectangle {
                    color: "#111c34"
                    radius: 12
                    border.color: "#1e293b"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Metadata"
                        color: "#e2e8f0"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: "Source: " + root.selectedItem.source
                        color: "#94a3b8"
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }

                    Label {
                        text: "Captured: " + root.selectedItem.capturedAt
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }

                    Label {
                        text: "License: " + root.selectedItem.license
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }

                    Flow {
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: root.selectedItem.tags !== ""
                                ? root.selectedItem.tags.split(",")
                                : []

                            Rectangle {
                                radius: 10
                                height: 20
                                color: "#1e293b"
                                border.color: "#334155"

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData.trim()
                                    color: "#e2e8f0"
                                    font.pixelSize: 10
                                    padding: 6
                                }
                            }
                        }
                    }

                    TextArea {
                        text: root.selectedItem.notes
                        placeholderText: "Selection notes"
                        wrapMode: TextEdit.WordWrap
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                    }
                }
            }

            Frame {
                Layout.fillWidth: true
                background: Rectangle {
                    color: "#111c34"
                    radius: 12
                    border.color: "#1e293b"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Quick Actions"
                        color: "#e2e8f0"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Button {
                            text: "Duplicate"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Link to board"
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Button {
                            text: "Export selection"
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Add to palette"
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}
