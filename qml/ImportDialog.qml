import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    property bool opened: false
    signal closed()
    signal migrationRequested()

    modal: true
    title: "Import"
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

        Label {
            text: "Bring in PureRef or RefNexus data"
            color: "#94a3b8"
            font.pixelSize: 12
        }

        ComboBox {
            model: [".rnxpack workspace", "PureRef .pur", "Folder import", "Single images"]
            currentIndex: 1
            Layout.fillWidth: true
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
                    text: "PureRef compatibility"
                    color: "#e2e8f0"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                RadioButton {
                    text: "Try direct .pur import"
                    checked: true
                }

                RadioButton {
                    text: "Use migration wizard"
                }

                Button {
                    text: "Open migration wizard"
                    onClicked: root.migrationRequested()
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

                Switch { text: "Import source URLs"; checked: true }
                Switch { text: "Preserve tags and notes"; checked: true }
                Switch { text: "Detect duplicates"; checked: true }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "Browse file"
                Layout.fillWidth: true
            }

            Button {
                text: "Import"
                Layout.fillWidth: true
            }
        }
    }
}
