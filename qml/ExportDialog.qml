import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    property bool opened: false
    signal closed()

    modal: true
    title: "Export"
    width: 520
    height: 360
    visible: opened

    onAccepted: {
        opened = false
        closed()
    }

    onRejected: {
        opened = false
        closed()
    }

    onVisibleChanged: {
        if (!visible && opened) {
            opened = false
            closed()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        padding: 16
        spacing: 12

        ComboBox {
            model: ["Canvas image", "PDF review", "Static viewer package", "Selection export"]
            currentIndex: 0
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true

            ComboBox {
                model: ["Full board", "Current selection", "Visible area"]
                Layout.fillWidth: true
            }

            ComboBox {
                model: ["1x", "2x", "4x"]
                Layout.fillWidth: true
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
                    text: "Include"
                    color: "#e2e8f0"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                Switch { text: "Annotations and guides"; checked: true }
                Switch { text: "Metadata summary"; checked: true }
                Switch { text: "Color palettes"; checked: false }
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
                    text: "Output"
                    color: "#e2e8f0"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                TextField {
                    text: "~/Exports/RefNexus"
                    Layout.fillWidth: true
                }

                Button { text: "Choose folder" }
            }
        }

        Button {
            text: "Export"
            Layout.fillWidth: true
        }
    }
}
